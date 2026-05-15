import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_block.dart';
import '../../../l10n/generated/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: s.background,
      appBar: AppBar(
        title: const SizedBox.shrink(),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l.settingsTitle,
            onPressed: () => context.push(AppRoute.settings),
          ),
          IconButton(
            icon: const Icon(Icons.health_and_safety_outlined),
            tooltip: l.sosTitle,
            color: HColors.alpenglow500,
            onPressed: () => context.push(AppRoute.sos),
          ),
          const SizedBox(width: HSpacing.s2),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: HSpacing.screenPaddingH,
            vertical: HSpacing.s2,
          ),
          children: <Widget>[
            Text(
              l.homeGreeting,
              style: HTypography.displayLg.copyWith(color: s.textPrimary),
            ),
            const SizedBox(height: HSpacing.s2),
            Text(
              l.homeSubGreeting,
              style: HTypography.bodyLg.copyWith(color: s.textSecondary),
            ),
            const SizedBox(height: HSpacing.s5),
            AppButton(
              label: l.homeStartHike,
              size: AppButtonSize.hero,
              icon: Icons.play_arrow_rounded,
              onPressed: () => context.push(AppRoute.tracking),
            ),
            const SizedBox(height: HSpacing.sectionGap),
            SectionHeader(label: l.homeRecentSection),
            const SizedBox(height: HSpacing.s3),
            EmptyState(
              icon: Icons.terrain_outlined,
              headline: l.historyEmptyHeadline,
              body: l.historyEmptyBody,
              action: AppButton(
                label: l.homeStartHike,
                variant: AppButtonVariant.secondary,
                fullWidth: false,
                onPressed: () => context.push(AppRoute.tracking),
              ),
            ),
            const SizedBox(height: HSpacing.sectionGap),
            SectionHeader(label: l.homeQuickStatsSection),
            const SizedBox(height: HSpacing.s3),
            AppCard(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: StatBlock(
                      label: l.statTotalTrips,
                      value: '0',
                      unit: 'trip',
                    ),
                  ),
                  Expanded(
                    child: StatBlock(
                      label: l.statTotalDistance,
                      value: '0',
                      unit: 'km',
                    ),
                  ),
                  Expanded(
                    child: StatBlock(
                      label: l.statTotalElevation,
                      value: '0',
                      unit: 'm',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: HSpacing.s8),
          ],
        ),
      ),
    );
  }
}
