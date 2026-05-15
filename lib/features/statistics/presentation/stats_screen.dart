import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_block.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../tracking/domain/trip.dart';
import '../application/personal_stats.dart';

/// Statistik personal kumulatif — PRD §4.8.
///
/// Tampilkan total all-time, personal best, dan monthly heatmap.
/// Untuk MVP, semua user bisa lihat (gating Pro nanti via paywall provider).
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);
    final PersonalStats stats = ref.watch(personalStatsProvider);

    return Scaffold(
      backgroundColor: s.background,
      appBar: AppBar(title: Text(l.navStats)),
      body: stats.totalTrips == 0
          ? EmptyState(
              icon: Icons.bar_chart_outlined,
              headline: l.historyEmptyHeadline,
              body: l.historyEmptyBody,
            )
          : ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: HSpacing.screenPaddingH,
                vertical: HSpacing.s4,
              ),
              children: <Widget>[
                SectionHeader(label: l.homeQuickStatsSection),
                const SizedBox(height: HSpacing.s3),
                AppCard(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: StatBlock(
                          label: l.statTotalTrips,
                          value: stats.totalTrips.toString(),
                          unit: 'trip',
                        ),
                      ),
                      Expanded(
                        child: StatBlock(
                          label: l.statTotalDistance,
                          value: stats.totalDistanceMeters >= 1000
                              ? (stats.totalDistanceMeters / 1000)
                                  .toStringAsFixed(1)
                                  .replaceAll('.', ',')
                              : stats.totalDistanceMeters.round().toString(),
                          unit: stats.totalDistanceMeters >= 1000 ? 'km' : 'm',
                        ),
                      ),
                      Expanded(
                        child: StatBlock(
                          label: l.statTotalElevation,
                          value: stats.totalElevationGain.round().toString(),
                          unit: 'm',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: HSpacing.s3),
                AppCard(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: StatBlock(
                          label: l.statTotalDuration,
                          value: '${stats.totalDuration.inHours}j',
                        ),
                      ),
                      Expanded(
                        child: StatBlock(
                          label: 'Gunung',
                          value: stats.uniqueMountains.toString(),
                        ),
                      ),
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                ),
                const SizedBox(height: HSpacing.sectionGap),
                const SectionHeader(label: 'Personal best'),
                const SizedBox(height: HSpacing.s3),
                if (stats.longestDistanceTrip != null)
                  _BestTripCard(
                    trip: stats.longestDistanceTrip!,
                    label: 'Trip terjauh',
                    metric: Format.distance(
                      stats.longestDistanceTrip!.totalDistance,
                    ),
                  ),
                if (stats.highestElevationTrip != null) ...<Widget>[
                  const SizedBox(height: HSpacing.s2),
                  _BestTripCard(
                    trip: stats.highestElevationTrip!,
                    label: 'Elevasi tertinggi',
                    metric:
                        '${stats.highestElevationTrip!.maxElevation?.round() ?? 0} m',
                  ),
                ],
                if (stats.longestDurationTrip != null) ...<Widget>[
                  const SizedBox(height: HSpacing.s2),
                  _BestTripCard(
                    trip: stats.longestDurationTrip!,
                    label: 'Durasi terlama',
                    metric: Format.duration(
                      stats.longestDurationTrip!.totalDuration,
                    ),
                  ),
                ],
                const SizedBox(height: HSpacing.sectionGap),
                const SectionHeader(label: 'Aktivitas bulanan'),
                const SizedBox(height: HSpacing.s3),
                AppCard(
                  child: _MonthlyActivityHeatmap(months: stats.monthlyActivity),
                ),
                const SizedBox(height: HSpacing.s8),
              ],
            ),
    );
  }
}

class _BestTripCard extends StatelessWidget {
  const _BestTripCard({required this.trip, required this.label, required this.metric});
  final Trip trip;
  final String label;
  final String metric;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return AppCard(
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: HColors.alpenglow400.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              color: HColors.alpenglow500,
              size: 20,
            ),
          ),
          const SizedBox(width: HSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label.toUpperCase(),
                  style: HTypography.labelMd.copyWith(color: s.textTertiary),
                ),
                const SizedBox(height: 2),
                Text(
                  trip.name,
                  style: HTypography.headingMd.copyWith(color: s.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(metric, style: HTypography.monoLg.copyWith(color: s.textPrimary)),
        ],
      ),
    );
  }
}

/// Heatmap durasi per bulan untuk 12 bulan terakhir.
class _MonthlyActivityHeatmap extends StatelessWidget {
  const _MonthlyActivityHeatmap({required this.months});
  final Map<String, Duration> months;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final DateTime now = DateTime.now();
    final List<({String key, String label, Duration duration})> last12 =
        <({String key, String label, Duration duration})>[];

    for (int i = 11; i >= 0; i--) {
      final DateTime d = DateTime(now.year, now.month - i);
      final String key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      last12.add((
        key: key,
        label: _shortMonth(d.month),
        duration: months[key] ?? Duration.zero,
      ),);
    }

    final Duration max = last12
        .map<Duration>((({String key, String label, Duration duration}) m) => m.duration)
        .fold(Duration.zero, (Duration acc, Duration d) => d > acc ? d : acc);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            for (final ({String key, String label, Duration duration}) m in last12)
              Expanded(
                child: Tooltip(
                  message: '${m.label}: ${m.duration.inHours}j ${m.duration.inMinutes.remainder(60)}m',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: _intensity(m.duration, max),
                        borderRadius: BorderRadius.circular(HRadius.sm),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: HSpacing.s2),
        Row(
          children: <Widget>[
            for (final ({String key, String label, Duration duration}) m in last12)
              Expanded(
                child: Center(
                  child: Text(
                    m.label,
                    style: HTypography.bodySm.copyWith(color: s.textTertiary),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Color _intensity(Duration d, Duration max) {
    if (max == Duration.zero || d == Duration.zero) {
      return HColors.mist100;
    }
    final double ratio = d.inSeconds / max.inSeconds;
    if (ratio >= 0.75) return HColors.forest500;
    if (ratio >= 0.5) return HColors.forest400;
    if (ratio >= 0.25) return HColors.forest300;
    return HColors.forest200;
  }

  String _shortMonth(int m) {
    const List<String> labels = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return labels[(m - 1) % 12];
  }
}
