import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/distance.dart' as geo;
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/elevation_profile_chart.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_block.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../checkpoint/data/checkpoint_repository.dart';
import '../../checkpoint/domain/checkpoint.dart';
import '../../gpx/data/gpx_service.dart';
import '../../map/presentation/hike_map_view.dart';
import '../../tracking/data/track_point_repository.dart';
import '../../tracking/data/trip_repository.dart';
import '../../tracking/domain/track_point.dart';
import '../../tracking/domain/trip.dart';

final _detailProvider = FutureProvider.family<_TripDetailData, String>(
    (Ref ref, String id) async {
  final Trip? trip = await ref.watch(tripRepositoryProvider).findById(id);
  if (trip == null) {
    return const _TripDetailData(trip: null, points: <TrackPoint>[], checkpoints: <Checkpoint>[]);
  }
  final List<TrackPoint> points =
      await ref.watch(trackPointRepositoryProvider).findByTripId(id);
  final List<Checkpoint> cps =
      await ref.watch(checkpointRepositoryProvider).findByTripId(id);
  return _TripDetailData(trip: trip, points: points, checkpoints: cps);
});

class TripDetailScreen extends ConsumerWidget {
  const TripDetailScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);
    final AsyncValue<_TripDetailData> async = ref.watch(_detailProvider(tripId));

    return Scaffold(
      backgroundColor: s.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(async.value?.trip?.name ?? '...'),
        actions: <Widget>[
          if (async.value?.trip != null)
            IconButton(
              tooltip: 'Export GPX',
              icon: const Icon(Icons.file_download_outlined),
              onPressed: () => _exportGpx(context, ref, async.value!),
            ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace st) => Center(child: Text('Error: $e')),
        data: (_TripDetailData data) {
          final Trip? trip = data.trip;
          if (trip == null) {
            return EmptyState(
              icon: Icons.error_outline_rounded,
              headline: 'Trip tidak ditemukan',
              body: l.commonComingSoonBody,
            );
          }
          final List<LatLng> latlngs = <LatLng>[
            for (final TrackPoint p in data.points)
              if (!p.isPaused) LatLng(p.latitude, p.longitude),
          ];
          return Column(
            children: <Widget>[
              SizedBox(
                height: 220,
                child: HikeMapView(
                  activeTrack: latlngs,
                  checkpoints: data.checkpoints,
                  initialCenter: latlngs.isNotEmpty
                      ? LatLng(
                          (latlngs.first.latitude + latlngs.last.latitude) / 2,
                          (latlngs.first.longitude + latlngs.last.longitude) / 2,
                        )
                      : null,
                  initialZoom: 13,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HSpacing.screenPaddingH,
                    vertical: HSpacing.s4,
                  ),
                  children: <Widget>[
                    if (trip.mountainName != null)
                      Text(
                        trip.mountainName!,
                        style: HTypography.bodyMd.copyWith(color: s.textSecondary),
                      ),
                    const SizedBox(height: HSpacing.s4),
                    AppCard(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: StatBlock(
                              label: l.statTotalDistance,
                              value: Format.distance(trip.totalDistance)
                                  .replaceAll(' km', '')
                                  .replaceAll(' m', ''),
                              unit: trip.totalDistance >= 1000 ? 'km' : 'm',
                            ),
                          ),
                          Expanded(
                            child: StatBlock(
                              label: l.statTotalDuration,
                              value: Format.duration(trip.totalDuration),
                            ),
                          ),
                          Expanded(
                            child: StatBlock(
                              label: 'Elev gain',
                              value: trip.elevationGain.round().toString(),
                              unit: 'm',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (data.points.length >= 2) ...<Widget>[
                      const SizedBox(height: HSpacing.sectionGap),
                      const SectionHeader(label: 'Profil elevasi'),
                      const SizedBox(height: HSpacing.s3),
                      AppCard(
                        padding: const EdgeInsets.symmetric(
                          vertical: HSpacing.s3,
                        ),
                        child: ElevationProfileChart(
                          elevations: <double?>[
                            for (final TrackPoint p in data.points)
                              if (!p.isPaused) p.elevation,
                          ],
                          distancesMeters: _cumulativeDistances(data.points),
                        ),
                      ),
                    ],
                    const SizedBox(height: HSpacing.sectionGap),
                    SectionHeader(label: l.tripDetailNotes),
                    const SizedBox(height: HSpacing.s3),
                    if (data.checkpoints.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: HSpacing.s5),
                        child: Text(
                          'Belum ada checkpoint di trip ini.',
                          style: HTypography.bodyMd.copyWith(color: s.textSecondary),
                        ),
                      )
                    else
                      ...data.checkpoints.map((Checkpoint c) => Padding(
                            padding: const EdgeInsets.only(bottom: HSpacing.s2),
                            child: AppCard(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: c.type.color.withValues(alpha: 0.18),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(c.type.icon, size: 18, color: c.type.color),
                                  ),
                                  const SizedBox(width: HSpacing.s3),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          c.name,
                                          style: HTypography.headingMd
                                              .copyWith(color: s.textPrimary),
                                        ),
                                        if (c.description != null)
                                          Text(
                                            c.description!,
                                            style: HTypography.bodySm
                                                .copyWith(color: s.textSecondary),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),),
                    const SizedBox(height: HSpacing.s8),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportGpx(
    BuildContext context,
    WidgetRef ref,
    _TripDetailData data,
  ) async {
    if (data.trip == null) return;
    final GpxService service = ref.read(gpxServiceProvider);
    final String content = service.render(
      trip: data.trip!,
      points: data.points,
      checkpoints: data.checkpoints,
    );
    final String filename = '${data.trip!.name}-${data.trip!.id.substring(0, 6)}';
    final File file = await service.writeToFile(content, filename: filename);
    if (!context.mounted) return;
    await Share.shareXFiles(
      <XFile>[XFile(file.path, mimeType: 'application/gpx+xml')],
      subject: data.trip!.name,
    );
  }
}

class _TripDetailData {
  const _TripDetailData({required this.trip, required this.points, required this.checkpoints});
  final Trip? trip;
  final List<TrackPoint> points;
  final List<Checkpoint> checkpoints;
}

List<double> _cumulativeDistances(List<TrackPoint> points) {
  final List<double> out = <double>[];
  double total = 0;
  TrackPoint? prev;
  for (final TrackPoint p in points) {
    if (p.isPaused) continue;
    if (prev != null) {
      total += geo.Geo.haversineMeters(
        prev.latitude,
        prev.longitude,
        p.latitude,
        p.longitude,
      );
    }
    out.add(total);
    prev = p;
  }
  return out;
}
