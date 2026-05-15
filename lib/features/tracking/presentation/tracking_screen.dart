import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/gps_accuracy_indicator.dart';
import '../../../core/widgets/stat_block.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Tracking screen — placeholder UI mengikuti DESIGN.md §11.2.
///
/// Phase 3-4 (PLANNING §7) akan menambahkan GPS service, foreground service,
/// dan integrasi flutter_map. Untuk Phase 1, ini layout shell saja.
class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: s.background,
      body: Stack(
        children: <Widget>[
          // Map placeholder (penuh layar)
          Container(
            color: s.surfaceMuted,
            child: Center(
              child: Icon(Icons.map_outlined, size: 64, color: s.borderDefault),
            ),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(HSpacing.s4),
              child: Row(
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
            ),
          ),

          // Bottom sheet — collapsed by default (DESIGN.md §6.6 + §11.2)
          DraggableScrollableSheet(
            initialChildSize: 0.32,
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
                          l.trackingStart,
                          style: HTypography.headingLg.copyWith(color: s.textPrimary),
                        ),
                        const GpsAccuracyIndicator(level: GpsAccuracyLevel.noSignal),
                      ],
                    ),
                    const SizedBox(height: HSpacing.s5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: StatBlock(
                            label: l.trackingDistance,
                            value: '0,0',
                            unit: 'km',
                          ),
                        ),
                        Expanded(
                          child: StatBlock(
                            label: l.trackingDuration,
                            value: '00m 00s',
                          ),
                        ),
                        Expanded(
                          child: StatBlock(
                            label: l.trackingElevation,
                            value: '-',
                            unit: 'm',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: HSpacing.s6),
                    AppButton(
                      label: l.trackingStart,
                      icon: Icons.play_arrow_rounded,
                      size: AppButtonSize.hero,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.commonComingSoon)),
                        );
                      },
                    ),
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
        color: s.surface.withOpacity(0.95),
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
