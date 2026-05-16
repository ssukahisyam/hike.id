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
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_block.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../history/presentation/history_screen.dart';
import '../../tracking/domain/trip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);
    final AsyncValue<List<Trip>> tripsAsync = ref.watch(tripsStreamProvider);
    final List<Trip> all = tripsAsync.value ?? const <Trip>[];
    final List<Trip> completed =
        all.where((Trip t) => t.status == TripStatus.completed).toList();
    final List<Trip> recent = completed.take(3).toList();

    final double totalDistance = completed.fold<double>(
      0,
      (double acc, Trip t) => acc + t.totalDistance,
    );
    final double totalElevGain = completed.fold<double>(
      0,
      (double acc, Trip t) => acc + t.elevationGain,
    );

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
            if (recent.isEmpty)
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
              )
            else
              ...recent.map((Trip t) => Padding(
                    padding: const EdgeInsets.only(bottom: HSpacing.s2),
                    child: _RecentTripCard(trip: t),
                  ),),
            const SizedBox(height: HSpacing.sectionGap),
            SectionHeader(label: l.homeQuickStatsSection),
            const SizedBox(height: HSpacing.s3),
            AppCard(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: StatBlock(
                      label: l.statTotalTrips,
                      value: completed.length.toString(),
                      unit: 'trip',
                    ),
                  ),
                  Expanded(
                    child: StatBlock(
                      label: l.statTotalDistance,
                      value: totalDistance >= 1000
                          ? (totalDistance / 1000).toStringAsFixed(1).replaceAll('.', ',')
                          : totalDistance.round().toString(),
                      unit: totalDistance >= 1000 ? 'km' : 'm',
                    ),
                  ),
                  Expanded(
                    child: StatBlock(
                      label: l.statTotalElevation,
                      value: totalElevGain.round().toString(),
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

class _RecentTripCard extends StatelessWidget {
  const _RecentTripCard({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return AppCard(
      onTap: () => context.push('/trip/${trip.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            trip.name,
            style: HTypography.headingMd.copyWith(color: s.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: HSpacing.s2),
          Text(
            '${Format.distance(trip.totalDistance)} · ${Format.duration(trip.totalDuration)}',
            style: HTypography.monoSm.copyWith(color: s.textSecondary),
          ),
        ],
      ),
    );
  }
}
