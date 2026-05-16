import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/theme_mode_controller.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../tracking/application/tracking_preferences.dart';
import '../../tracking/domain/trip.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);
    final HThemeMode currentMode = ref.watch(themeModeProvider);

    final List<({HThemeMode mode, String label})> options = <({HThemeMode mode, String label})>[
      (mode: HThemeMode.system, label: l.settingsThemeSystem),
      (mode: HThemeMode.light, label: l.settingsThemeLight),
      (mode: HThemeMode.dark, label: l.settingsThemeDark),
      (mode: HThemeMode.outdoor, label: l.settingsThemeOutdoor),
    ];

    return Scaffold(
      backgroundColor: s.background,
      appBar: AppBar(
        title: Text(l.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: HSpacing.screenPaddingH,
            vertical: HSpacing.s4,
          ),
          children: <Widget>[
            SectionHeader(label: l.settingsTheme),
            const SizedBox(height: HSpacing.s3),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < options.length; i++) ...<Widget>[
                    if (i != 0) Divider(color: s.divider, height: 1),
                    InkWell(
                      onTap: () => ref.read(themeModeProvider.notifier).set(options[i].mode),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: HSpacing.s4,
                          vertical: HSpacing.s4,
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                options[i].label,
                                style: HTypography.bodyLg.copyWith(color: s.textPrimary),
                              ),
                            ),
                            if (currentMode == options[i].mode)
                              Icon(Icons.check_rounded, color: s.actionPrimary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: HSpacing.sectionGap),
            SectionHeader(label: 'Tracking'),
            const SizedBox(height: HSpacing.s3),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < TrackingMode.values.length; i++) ...<Widget>[
                    if (i != 0) Divider(color: s.divider, height: 1),
                    _TrackingModeRow(mode: TrackingMode.values[i]),
                  ],
                ],
              ),
            ),
            const SizedBox(height: HSpacing.sectionGap),
            SectionHeader(label: l.settingsAbout),
            const SizedBox(height: HSpacing.s3),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(l.appName, style: HTypography.headingMd.copyWith(color: s.textPrimary)),
                  const SizedBox(height: 2),
                  Text(
                    'v0.1.0 — ${l.tagline}',
                    style: HTypography.bodySm.copyWith(color: s.textSecondary),
                  ),
                  const SizedBox(height: HSpacing.s3),
                  Text(
                    'Map © OpenStreetMap contributors (ODbL)',
                    style: HTypography.bodySm.copyWith(color: s.textTertiary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _TrackingModeRow extends ConsumerWidget {
  const _TrackingModeRow({required this.mode});

  final TrackingMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final TrackingMode current =
        ref.watch(trackingPreferencesProvider).defaultMode;
    final bool selected = current == mode;
    return InkWell(
      onTap: () => ref
          .read(trackingPreferencesProvider.notifier)
          .setDefaultMode(mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: HSpacing.s4,
          vertical: HSpacing.s4,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          trackingModeLabel(mode),
                          style: HTypography.bodyLg.copyWith(color: s.textPrimary),
                        ),
                      ),
                      Text(
                        batteryEstimateLabel(mode),
                        style: HTypography.monoSm.copyWith(color: s.textTertiary),
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
            const SizedBox(width: HSpacing.s2),
            if (selected) Icon(Icons.check_rounded, color: s.actionPrimary),
          ],
        ),
      ),
    );
  }
}
