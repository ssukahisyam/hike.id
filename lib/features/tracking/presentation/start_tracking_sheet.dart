import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/battery_service.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_button.dart';
import '../application/tracking_preferences.dart';
import '../domain/trip.dart';

/// Hasil dari [showStartTrackingSheet] — null kalau user batal.
class StartTrackingChoice {
  const StartTrackingChoice({required this.mode, required this.saveAsDefault});
  final TrackingMode mode;
  final bool saveAsDefault;
}

/// Bottom sheet pemilih mode tracking sebelum mulai hike.
///
/// PRD US-TRK-04 — pendaki bisa pilih mode (Akurat / Seimbang / Hemat)
/// supaya seimbangkan akurasi vs daya tahan baterai.
///
/// Workflow:
/// 1. Sheet open dengan mode default dari [TrackingPreferences].
/// 2. User pilih mode — lihat estimasi konsumsi baterai per pilihan.
/// 3. (Opsional) "Simpan sebagai default" — preferensi di-persist.
/// 4. Confirm → return [StartTrackingChoice].
///
/// Kalau baterai rendah (<30%) dan user pilih High Accuracy, tampilkan
/// warning lembut — tidak block, hanya remind.
Future<StartTrackingChoice?> showStartTrackingSheet(BuildContext context) {
  return showModalBottomSheet<StartTrackingChoice>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).extension<HSurface>()!.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(HRadius.xl)),
    ),
    builder: (BuildContext c) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
      child: const _StartTrackingSheet(),
    ),
  );
}

class _StartTrackingSheet extends ConsumerStatefulWidget {
  const _StartTrackingSheet();

  @override
  ConsumerState<_StartTrackingSheet> createState() => _StartTrackingSheetState();
}

class _StartTrackingSheetState extends ConsumerState<_StartTrackingSheet> {
  TrackingMode? _selected;
  bool _saveAsDefault = false;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final TrackingPreferences prefs = ref.watch(trackingPreferencesProvider);
    final TrackingMode current = _selected ?? prefs.defaultMode;
    final AsyncValue<BatterySnapshot> batteryAsync =
        ref.watch(batterySnapshotProvider);
    final BatterySnapshot? battery = batteryAsync.valueOrNull;
    final bool batteryLowForHighAccuracy = battery != null &&
        battery.level < 30 &&
        battery.isOnBattery &&
        current == TrackingMode.highAccuracy;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        HSpacing.s5,
        0,
        HSpacing.s5,
        HSpacing.s5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Mulai hike',
            style: HTypography.headingLg.copyWith(color: s.textPrimary),
          ),
          const SizedBox(height: HSpacing.s2),
          Text(
            'Pilih mode tracking sesuai kebutuhanmu.',
            style: HTypography.bodyMd.copyWith(color: s.textSecondary),
          ),
          if (battery != null) ...<Widget>[
            const SizedBox(height: HSpacing.s3),
            _BatteryStatusChip(battery: battery),
          ],
          const SizedBox(height: HSpacing.s4),
          for (final TrackingMode mode in TrackingMode.values) ...<Widget>[
            _ModeOptionTile(
              mode: mode,
              selected: current == mode,
              onTap: () => setState(() => _selected = mode),
            ),
            const SizedBox(height: HSpacing.s2),
          ],
          if (batteryLowForHighAccuracy) ...<Widget>[
            const SizedBox(height: HSpacing.s2),
            _BatteryWarning(level: battery.level),
            const SizedBox(height: HSpacing.s2),
          ],
          const SizedBox(height: HSpacing.s2),
          InkWell(
            borderRadius: BorderRadius.circular(HRadius.md),
            onTap: () => setState(() => _saveAsDefault = !_saveAsDefault),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: HSpacing.s2),
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: _saveAsDefault,
                    onChanged: (bool? v) =>
                        setState(() => _saveAsDefault = v ?? false),
                  ),
                  const SizedBox(width: HSpacing.s1),
                  Expanded(
                    child: Text(
                      'Simpan sebagai default',
                      style: HTypography.bodyMd.copyWith(color: s.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: HSpacing.s4),
          AppButton(
            label: 'Mulai Hike',
            icon: Icons.play_arrow_rounded,
            size: AppButtonSize.hero,
            onPressed: () {
              Navigator.of(context).pop(
                StartTrackingChoice(
                  mode: current,
                  saveAsDefault: _saveAsDefault,
                ),
              );
            },
          ),
          const SizedBox(height: HSpacing.s2),
          AppButton(
            label: 'Batal',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _ModeOptionTile extends StatelessWidget {
  const _ModeOptionTile({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final TrackingMode mode;
  final bool selected;
  final VoidCallback onTap;

  IconData get _icon {
    switch (mode) {
      case TrackingMode.highAccuracy:
        return Icons.gps_fixed_rounded;
      case TrackingMode.balanced:
        return Icons.speed_rounded;
      case TrackingMode.batterySaver:
        return Icons.battery_saver_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final Color borderColor = selected ? s.actionPrimary : s.borderSubtle;
    final Color bg = selected ? s.actionPrimary.withOpacity(0.06) : s.surface;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(HRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(HRadius.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(HSpacing.s4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(HRadius.lg),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                _icon,
                color: selected ? s.actionPrimary : s.textSecondary,
                size: 24,
              ),
              const SizedBox(width: HSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            trackingModeLabel(mode),
                            style: HTypography.headingMd
                                .copyWith(color: s.textPrimary),
                          ),
                        ),
                        Text(
                          batteryEstimateLabel(mode),
                          style: HTypography.monoSm
                              .copyWith(color: s.textTertiary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trackingModeDescription(mode),
                      style: HTypography.bodySm.copyWith(color: s.textSecondary),
                    ),
                  ],
                ),
              ),
              if (selected) ...<Widget>[
                const SizedBox(width: HSpacing.s2),
                Icon(Icons.check_circle_rounded, color: s.actionPrimary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BatteryStatusChip extends StatelessWidget {
  const _BatteryStatusChip({required this.battery});
  final BatterySnapshot battery;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final IconData icon = battery.isCritical
        ? Icons.battery_alert_rounded
        : battery.isLow
            ? Icons.battery_2_bar_rounded
            : Icons.battery_full_rounded;
    final Color color = battery.isLow ? HColors.alpenglow500 : s.textSecondary;
    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: color),
        const SizedBox(width: HSpacing.s1),
        Text(
          'Baterai ${battery.level}%${battery.isOnBattery ? '' : ' (charging)'}',
          style: HTypography.labelMd.copyWith(color: color),
        ),
      ],
    );
  }
}

class _BatteryWarning extends StatelessWidget {
  const _BatteryWarning({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(HSpacing.s3),
      decoration: BoxDecoration(
        color: HColors.warningBg,
        borderRadius: BorderRadius.circular(HRadius.md),
        border: Border.all(color: HColors.warningBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.battery_alert_rounded,
            color: HColors.alpenglow300,
            size: 18,
          ),
          const SizedBox(width: HSpacing.s2),
          Expanded(
            child: Text(
              'Baterai $level%. Mode Akurat menguras daya cepat — pertimbangkan Seimbang atau Hemat.',
              style: HTypography.bodySm.copyWith(color: HColors.alpenglow300),
            ),
          ),
        ],
      ),
    );
  }
}
