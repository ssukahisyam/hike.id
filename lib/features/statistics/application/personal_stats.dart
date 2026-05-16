import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../history/presentation/history_screen.dart';
import '../../tracking/domain/trip.dart';

/// Snapshot statistik kumulatif personal — PRD §4.8.
class PersonalStats extends Equatable {
  const PersonalStats({
    required this.totalTrips,
    required this.totalDistanceMeters,
    required this.totalDuration,
    required this.totalElevationGain,
    required this.longestDistanceTrip,
    required this.highestElevationTrip,
    required this.longestDurationTrip,
    required this.monthlyActivity,
    required this.uniqueMountains,
  });

  final int totalTrips;
  final double totalDistanceMeters;
  final Duration totalDuration;
  final double totalElevationGain;

  /// Personal best — nullable kalau belum ada trip selesai.
  final Trip? longestDistanceTrip;
  final Trip? highestElevationTrip;
  final Trip? longestDurationTrip;

  /// Map "YYYY-MM" -> durasi bulan itu. Untuk monthly activity heatmap.
  final Map<String, Duration> monthlyActivity;

  final int uniqueMountains;

  static const PersonalStats empty = PersonalStats(
    totalTrips: 0,
    totalDistanceMeters: 0,
    totalDuration: Duration.zero,
    totalElevationGain: 0,
    longestDistanceTrip: null,
    highestElevationTrip: null,
    longestDurationTrip: null,
    monthlyActivity: <String, Duration>{},
    uniqueMountains: 0,
  );

  @override
  List<Object?> get props => <Object?>[
        totalTrips,
        totalDistanceMeters,
        totalDuration,
        totalElevationGain,
        longestDistanceTrip,
        highestElevationTrip,
        longestDurationTrip,
        monthlyActivity,
        uniqueMountains,
      ];
}

PersonalStats _aggregate(List<Trip> all) {
  final List<Trip> completed =
      all.where((Trip t) => t.status == TripStatus.completed).toList();
  if (completed.isEmpty) return PersonalStats.empty;

  Trip longestDistance = completed.first;
  Trip highestElev = completed.first;
  Trip longestDuration = completed.first;
  double totalDist = 0;
  Duration totalDur = Duration.zero;
  double totalGain = 0;
  final Map<String, Duration> monthly = <String, Duration>{};
  final Set<String> mountains = <String>{};

  for (final Trip t in completed) {
    totalDist += t.totalDistance;
    totalDur += t.totalDuration;
    totalGain += t.elevationGain;
    if (t.totalDistance > longestDistance.totalDistance) longestDistance = t;
    if ((t.maxElevation ?? 0) > (highestElev.maxElevation ?? 0)) highestElev = t;
    if (t.totalDuration > longestDuration.totalDuration) longestDuration = t;
    final String key =
        '${t.startedAt.year}-${t.startedAt.month.toString().padLeft(2, '0')}';
    monthly[key] = (monthly[key] ?? Duration.zero) + t.totalDuration;
    if (t.mountainName != null && t.mountainName!.trim().isNotEmpty) {
      mountains.add(t.mountainName!.trim().toLowerCase());
    }
  }

  return PersonalStats(
    totalTrips: completed.length,
    totalDistanceMeters: totalDist,
    totalDuration: totalDur,
    totalElevationGain: totalGain,
    longestDistanceTrip: longestDistance,
    highestElevationTrip: highestElev,
    longestDurationTrip: longestDuration,
    monthlyActivity: monthly,
    uniqueMountains: mountains.length,
  );
}

final Provider<PersonalStats> personalStatsProvider = Provider<PersonalStats>((Ref ref) {
  final List<Trip> trips = ref.watch(tripsStreamProvider).value ?? const <Trip>[];
  return _aggregate(trips);
});
