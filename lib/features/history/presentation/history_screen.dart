import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../tracking/data/trip_repository.dart';
import '../../tracking/domain/trip.dart';
import 'gpx_import_action.dart';

final StreamProvider<List<Trip>> tripsStreamProvider =
    StreamProvider<List<Trip>>((Ref ref) {
  return ref.watch(tripRepositoryProvider).watchAll();
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);
    final AsyncValue<List<Trip>> trips = ref.watch(tripsStreamProvider);

    return Scaffold(
      backgroundColor: s.background,
      appBar: AppBar(
        title: Text(l.historyTitle),
        actions: const <Widget>[
          GpxImportButton(),
          SizedBox(width: HSpacing.s2),
        ],
      ),
      body: SafeArea(
        child: trips.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, StackTrace st) => Center(child: Text('Error: $e')),
          data: (List<Trip> list) => list.isEmpty
              ? EmptyState(
                  icon: Icons.terrain_outlined,
                  headline: l.historyEmptyHeadline,
                  body: l.historyEmptyBody,
                  action: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AppButton(
                        label: l.homeStartHike,
                        icon: Icons.play_arrow_rounded,
                        fullWidth: false,
                        onPressed: () => context.push(AppRoute.tracking),
                      ),
                      const SizedBox(height: HSpacing.s2),
                      const _ImportGpxTextButton(),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HSpacing.screenPaddingH,
                    vertical: HSpacing.s4,
                  ),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: HSpacing.cardGap),
                  itemBuilder: (BuildContext c, int i) => _TripCard(trip: list[i]),
                ),
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return AppCard(
      onTap: () => context.push('/trip/${trip.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  trip.name,
                  style: HTypography.headingMd.copyWith(color: s.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trip.source == TripSource.importedGpx)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HSpacing.s2,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: HColors.info.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(HRadius.sm),
                  ),
                  child: Text(
                    'GPX',
                    style: HTypography.labelMd.copyWith(color: HColors.info),
                  ),
                ),
              if (trip.status == TripStatus.active ||
                  trip.status == TripStatus.paused)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HSpacing.s2,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: HColors.alpenglow400.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(HRadius.sm),
                  ),
                  child: Text(
                    trip.status == TripStatus.active ? 'AKTIF' : 'JEDA',
                    style: HTypography.labelMd.copyWith(color: HColors.alpenglow500),
                  ),
                ),
            ],
          ),
          if (trip.mountainName != null) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              trip.mountainName!,
              style: HTypography.bodySm.copyWith(color: s.textSecondary),
            ),
          ],
          const SizedBox(height: HSpacing.s3),
          Row(
            children: <Widget>[
              _InlineStat(label: 'Jarak', value: Format.distance(trip.totalDistance)),
              const SizedBox(width: HSpacing.s5),
              _InlineStat(label: 'Durasi', value: Format.duration(trip.totalDuration)),
              const SizedBox(width: HSpacing.s5),
              _InlineStat(
                label: 'Elev gain',
                value: '${trip.elevationGain.round()} m',
              ),
            ],
          ),
          const SizedBox(height: HSpacing.s2),
          Text(
            _formatDate(trip.startedAt),
            style: HTypography.bodySm.copyWith(color: s.textTertiary),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const List<String> months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _InlineStat extends StatelessWidget {
  const _InlineStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: HTypography.bodySm.copyWith(color: s.textTertiary),
        ),
        const SizedBox(height: 2),
        Text(value, style: HTypography.monoMd.copyWith(color: s.textPrimary)),
      ],
    );
  }
}


/// Tombol text-style 'Import GPX' di empty state — lebih obvious daripada
/// icon kecil di app bar. Memanggil GpxImportButton.pickAndPreview
/// (static helper) supaya UI logic tidak duplikat.
class _ImportGpxTextButton extends ConsumerWidget {
  const _ImportGpxTextButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () => GpxImportButton.pickAndPreview(context, ref),
      icon: const Icon(Icons.file_upload_outlined),
      label: const Text('Import dari GPX'),
    );
  }
}
