import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_block.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../map/presentation/hike_map_view.dart';
import '../data/gpx_service.dart';
import '../domain/imported_route.dart';

/// Preview rute GPX sebelum disimpan ke local storage — PRD US-GPX-01.
class GpxImportPreviewScreen extends ConsumerStatefulWidget {
  const GpxImportPreviewScreen({super.key, required this.route});

  final ImportedRoute route;

  @override
  ConsumerState<GpxImportPreviewScreen> createState() => _GpxImportPreviewScreenState();
}

class _GpxImportPreviewScreenState extends ConsumerState<GpxImportPreviewScreen> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);
    final ImportedRoute route = widget.route;

    final List<LatLng> latlngs = <LatLng>[
      for (final RoutePoint p in route.points) LatLng(p.latitude, p.longitude),
    ];

    return Scaffold(
      backgroundColor: s.background,
      appBar: AppBar(
        title: Text(route.name),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: HikeMapView(
              importedRoute: latlngs,
              initialCenter: latlngs.isNotEmpty ? latlngs.first : null,
              initialZoom: 12,
            ),
          ),
          Expanded(
            flex: 2,
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: HSpacing.screenPaddingH,
                  vertical: HSpacing.s4,
                ),
                children: <Widget>[
                  if (route.description != null) ...<Widget>[
                    Text(
                      route.description!,
                      style: HTypography.bodyMd.copyWith(color: s.textSecondary),
                    ),
                    const SizedBox(height: HSpacing.s4),
                  ],
                  SectionHeader(label: l.tripDetailStats),
                  const SizedBox(height: HSpacing.s3),
                  AppCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: StatBlock(
                            label: l.statTotalDistance,
                            value: Format.distance(route.totalDistanceMeters)
                                .replaceAll(' km', '')
                                .replaceAll(' m', ''),
                            unit: route.totalDistanceMeters >= 1000 ? 'km' : 'm',
                          ),
                        ),
                        Expanded(
                          child: StatBlock(
                            label: l.statTotalElevation,
                            value: route.elevationGainMeters > 0
                                ? Format.elevation(route.elevationGainMeters)
                                    .replaceAll(' m', '')
                                : '-',
                            unit: route.elevationGainMeters > 0 ? 'm' : null,
                          ),
                        ),
                        Expanded(
                          child: StatBlock(
                            label: 'Titik',
                            value: route.points.length.toString(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: HSpacing.s5),
                  AppButton(
                    label: l.actionSave,
                    icon: Icons.save_outlined,
                    size: AppButtonSize.hero,
                    isLoading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                  const SizedBox(height: HSpacing.s8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final GpxService service = ref.read(gpxServiceProvider);
      await service.importToDatabase(widget.route);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rute tersimpan')),
      );
      context.pop();
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
