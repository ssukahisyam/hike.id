import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/router.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/gps_accuracy_indicator.dart';
import '../../../core/widgets/stat_block.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../checkpoint/data/checkpoint_repository.dart';
import '../../checkpoint/domain/checkpoint.dart';
import '../../checkpoint/presentation/add_checkpoint_sheet.dart';
import '../../map/presentation/hike_map_view.dart';
import '../application/tracking_controller.dart';
import '../application/tracking_preferences.dart';
import '../application/tracking_state.dart';
import '../domain/trip.dart';
import 'start_tracking_sheet.dart';

/// Tracking screen — full implementation per DESIGN.md §11.2.
class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  final MapController _mapController = MapController();
  final List<LatLng> _polyline = <LatLng>[];

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);
    final TrackingSession session = ref.watch(trackingControllerProvider);

    // Append fix terbaru ke polyline lokal supaya rendering smooth.
    if (session.lastFix != null) {
      final LatLng latest = LatLng(session.lastFix!.latitude, session.lastFix!.longitude);
      if (_polyline.isEmpty || _polyline.last != latest) {
        _polyline.add(latest);
        if (session.isRunning) {
          // Auto-follow user (DESIGN.md §11.2 / PRD US-MAP-01).
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _mapController.move(latest, _mapController.camera.zoom);
          });
        }
      }
    }

    final LatLng? currentPos = session.lastFix == null
        ? null
        : LatLng(session.lastFix!.latitude, session.lastFix!.longitude);

    final Trip? activeTrip = session.activeTrip;
    final AsyncValue<List<Checkpoint>> checkpointsAsync = activeTrip == null
        ? const AsyncData<List<Checkpoint>>(<Checkpoint>[])
        : ref.watch(_tripCheckpointsProvider(activeTrip.id));

    return Scaffold(
      backgroundColor: s.background,
      body: Stack(
        children: <Widget>[
          HikeMapView(
            controller: _mapController,
            initialCenter: currentPos,
            activeTrack: _polyline,
            currentPosition: currentPos,
            heading: session.lastFix?.heading,
            checkpoints: checkpointsAsync.value ?? const <Checkpoint>[],
            onLongPress: session.isActive
                ? (LatLng pos) => _addCheckpointAt(pos.latitude, pos.longitude)
                : null,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(HSpacing.s4),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _RoundIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => context.pop(),
                      ),
                      const Spacer(),
                      _RoundIconButton(
                        icon: Icons.health_and_safety_outlined,
                        color: HColors.alpenglow500,
                        onTap: () => context.push(AppRoute.sos),
                        semanticLabel: l.sosTitle,
                      ),
                    ],
                  ),
                  if (session.offRouteDistanceMeters != null) ...<Widget>[
                    const SizedBox(height: HSpacing.s2),
                    _OffRouteBanner(
                      meters: session.offRouteDistanceMeters!,
                      onMute: () => ref
                          .read(trackingControllerProvider.notifier)
                          .muteOffRouteWarning(),
                      onDismiss: () => ref
                          .read(trackingControllerProvider.notifier)
                          .dismissOffRouteWarning(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // FAB tambah checkpoint — DESIGN.md §11.2.
          if (session.isActive && session.lastFix != null)
            Positioned(
              right: HSpacing.s4,
              bottom: MediaQuery.of(context).size.height * 0.4 + HSpacing.s4,
              child: FloatingActionButton(
                heroTag: 'add-checkpoint',
                backgroundColor: s.actionPrimary,
                foregroundColor: s.actionPrimaryFg,
                onPressed: () => _addCheckpointAt(
                  session.lastFix!.latitude,
                  session.lastFix!.longitude,
                  elevation: session.lastFix!.elevation,
                ),
                child: const Icon(Icons.add_location_alt_outlined),
              ),
            ),
          DraggableScrollableSheet(
            initialChildSize: 0.36,
            minChildSize: 0.18,
            maxChildSize: 0.85,
            builder: (BuildContext context, ScrollController controller) {
              return Container(
                decoration: BoxDecoration(
                  color: s.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(HRadius.xl),
                  ),
                  border: Border.all(color: s.borderSubtle),
                ),
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(HSpacing.s5),
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: s.borderDefault,
                          borderRadius: BorderRadius.circular(HRadius.full),
                        ),
                      ),
                    ),
                    const SizedBox(height: HSpacing.s4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          _phaseLabel(session, l),
                          style: HTypography.headingLg.copyWith(color: s.textPrimary),
                        ),
                        GpsAccuracyIndicator(level: session.gpsAccuracy),
                      ],
                    ),
                    if (session.errorMessage != null) ...<Widget>[
                      const SizedBox(height: HSpacing.s3),
                      Container(
                        padding: const EdgeInsets.all(HSpacing.s3),
                        decoration: BoxDecoration(
                          color: HColors.dangerBg.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(HRadius.md),
                          border: Border.all(color: HColors.danger),
                        ),
                        child: Text(
                          session.errorMessage!,
                          style: HTypography.bodySm.copyWith(color: HColors.danger),
                        ),
                      ),
                    ],
                    const SizedBox(height: HSpacing.s5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: StatBlock(
                            label: l.trackingDistance,
                            value: session.distanceMeters >= 1000
                                ? (session.distanceMeters / 1000)
                                    .toStringAsFixed(2)
                                    .replaceAll('.', ',')
                                : session.distanceMeters.round().toString(),
                            unit: session.distanceMeters >= 1000 ? 'km' : 'm',
                          ),
                        ),
                        Expanded(
                          child: StatBlock(
                            label: l.trackingDuration,
                            value: Format.duration(session.activeDuration),
                          ),
                        ),
                        Expanded(
                          child: StatBlock(
                            label: l.trackingElevation,
                            value: session.lastFix?.elevation == null
                                ? '-'
                                : session.lastFix!.elevation!.round().toString(),
                            unit: session.lastFix?.elevation == null ? null : 'm',
                          ),
                        ),
                      ],
                    ),
                    if (session.elevationGain > 0 || session.maxSpeed > 0) ...<Widget>[
                      const SizedBox(height: HSpacing.s4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: StatBlock(
                              label: 'Elevation Gain',
                              value: session.elevationGain.round().toString(),
                              unit: 'm',
                              size: StatBlockSize.small,
                            ),
                          ),
                          Expanded(
                            child: StatBlock(
                              label: 'Max Speed',
                              value: (session.maxSpeed * 3.6)
                                  .toStringAsFixed(1)
                                  .replaceAll('.', ','),
                              unit: 'km/jam',
                              size: StatBlockSize.small,
                            ),
                          ),
                          Expanded(
                            child: StatBlock(
                              label: 'Pace',
                              value: Format.paceMinKm(session.avgSpeed),
                              size: StatBlockSize.small,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: HSpacing.s4),
                    _ModeSelector(currentMode: session.mode),
                    const SizedBox(height: HSpacing.s6),
                    _ActionButtons(session: session, onSaved: _afterStopSaved),
                    const SizedBox(height: HSpacing.s10),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _afterStopSaved(Trip trip) {
    _polyline.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trip "${trip.name}" tersimpan')),
      );
      context.go(AppRoute.history);
    }
  }

  Future<void> _addCheckpointAt(double lat, double lng, {double? elevation}) async {
    HapticFeedback.mediumImpact();
    final Trip? trip = ref.read(trackingControllerProvider).activeTrip;
    if (trip == null) return;
    await showAddCheckpointSheet(
      context,
      latitude: lat,
      longitude: lng,
      elevation: elevation,
      tripId: trip.id,
    );
  }

  String _phaseLabel(TrackingSession session, AppLocalizations l) {
    switch (session.phase) {
      case TrackingPhase.idle:
        return l.trackingStart;
      case TrackingPhase.running:
        return 'Tracking aktif';
      case TrackingPhase.paused:
        return 'Dijeda';
      case TrackingPhase.saving:
        return 'Menyimpan...';
      case TrackingPhase.error:
        return 'Ada masalah';
    }
  }
}

class _ActionButtons extends ConsumerStatefulWidget {
  const _ActionButtons({required this.session, required this.onSaved});

  final TrackingSession session;
  final void Function(Trip) onSaved;

  @override
  ConsumerState<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends ConsumerState<_ActionButtons> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TrackingController ctrl = ref.read(trackingControllerProvider.notifier);
    final TrackingSession session = widget.session;

    if (session.phase == TrackingPhase.idle ||
        session.phase == TrackingPhase.error) {
      return AppButton(
        label: l.trackingStart,
        icon: Icons.play_arrow_rounded,
        size: AppButtonSize.hero,
        isLoading: _busy,
        onPressed: _busy
            ? null
            : () async {
                setState(() => _busy = true);
                try {
                  // PRD US-TRK-04 — pilih mode dulu lewat start sheet.
                  final StartTrackingChoice? choice =
                      await showStartTrackingSheet(context);
                  if (choice == null || !mounted) return;
                  if (choice.saveAsDefault) {
                    await ref
                        .read(trackingPreferencesProvider.notifier)
                        .setDefaultMode(choice.mode);
                  }
                  await ctrl.start(mode: choice.mode);
                } finally {
                  if (mounted) setState(() => _busy = false);
                }
              },
      );
    }

    if (session.phase == TrackingPhase.running) {
      return Row(
        children: <Widget>[
          Expanded(
            child: AppButton(
              label: l.trackingPause,
              variant: AppButtonVariant.secondary,
              icon: Icons.pause_rounded,
              onPressed: ctrl.pause,
            ),
          ),
          const SizedBox(width: HSpacing.s3),
          Expanded(
            child: AppButton(
              label: l.trackingStop,
              variant: AppButtonVariant.primary,
              icon: Icons.stop_rounded,
              isLoading: _busy,
              onPressed: () => _confirmStop(ctrl),
            ),
          ),
        ],
      );
    }

    if (session.phase == TrackingPhase.paused) {
      return Row(
        children: <Widget>[
          Expanded(
            child: AppButton(
              label: l.trackingResume,
              variant: AppButtonVariant.primary,
              icon: Icons.play_arrow_rounded,
              onPressed: ctrl.resume,
            ),
          ),
          const SizedBox(width: HSpacing.s3),
          Expanded(
            child: AppButton(
              label: l.trackingStop,
              variant: AppButtonVariant.secondary,
              icon: Icons.stop_rounded,
              isLoading: _busy,
              onPressed: () => _confirmStop(ctrl),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _confirmStop(TrackingController ctrl) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        title: const Text('Selesaikan trip?'),
        content: const Text('Trip akan disimpan ke riwayat.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _busy = true);
    try {
      final Trip? trip = await ctrl.stopAndSave();
      if (trip != null) widget.onSaved(trip);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.color,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: s.surface.withValues(alpha: 0.95),
        shape: const CircleBorder(),
        elevation: 1,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(HSpacing.s3),
            child: Icon(icon, color: color ?? s.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// Stream provider untuk daftar checkpoint trip — auto-update saat tambah baru.
final _tripCheckpointsProvider = StreamProvider.family<List<Checkpoint>, String>(
    (Ref ref, String tripId) {
  return ref.watch(checkpointRepositoryProvider).watchByTripId(tripId);
});

class _ModeSelector extends ConsumerWidget {
  const _ModeSelector({required this.currentMode});
  final TrackingMode currentMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'MODE TRACKING',
          style: HTypography.labelMd.copyWith(color: s.textTertiary),
        ),
        const SizedBox(height: HSpacing.s2),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: s.surfaceMuted,
            borderRadius: BorderRadius.circular(HRadius.full),
            border: Border.all(color: s.borderSubtle),
          ),
          child: Row(
            children: <Widget>[
              for (final TrackingMode mode in TrackingMode.values)
                Expanded(
                  child: _ModePill(
                    mode: mode,
                    selected: currentMode == mode,
                    onTap: () => ref
                        .read(trackingControllerProvider.notifier)
                        .switchMode(mode),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({required this.mode, required this.selected, required this.onTap});
  final TrackingMode mode;
  final bool selected;
  final VoidCallback onTap;

  String get _label => switch (mode) {
        TrackingMode.highAccuracy => 'Akurat',
        TrackingMode.balanced => 'Seimbang',
        TrackingMode.batterySaver => 'Hemat',
      };

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return Material(
      color: selected ? s.actionPrimary : Colors.transparent,
      borderRadius: BorderRadius.circular(HRadius.full),
      child: InkWell(
        borderRadius: BorderRadius.circular(HRadius.full),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: HSpacing.s2),
          child: Center(
            child: Text(
              _label,
              style: HTypography.labelLg.copyWith(
                color: selected ? s.actionPrimaryFg : s.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OffRouteBanner extends StatelessWidget {
  const _OffRouteBanner({
    required this.meters,
    required this.onMute,
    required this.onDismiss,
  });

  final double meters;
  final VoidCallback onMute;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HSpacing.s3,
        vertical: HSpacing.s3,
      ),
      decoration: BoxDecoration(
        color: HColors.warningBg,
        borderRadius: BorderRadius.circular(HRadius.md),
        border: Border.all(color: HColors.warningBorder),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.alt_route_rounded, color: HColors.alpenglow300, size: 18),
          const SizedBox(width: HSpacing.s2),
          Expanded(
            child: Text(
              'Off-route ±${meters.round()}m dari jalur',
              style: HTypography.bodyMd.copyWith(color: HColors.alpenglow300),
            ),
          ),
          TextButton(
            onPressed: onDismiss,
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: onMute,
            child: const Text('Sengaja'),
          ),
        ],
      ),
    );
  }
}
