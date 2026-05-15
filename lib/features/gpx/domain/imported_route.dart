import 'package:equatable/equatable.dart';

import '../../../core/utils/distance.dart' as geo;

class RoutePoint extends Equatable {
  const RoutePoint({
    required this.latitude,
    required this.longitude,
    this.elevation,
    this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double? elevation;
  final DateTime? timestamp;

  @override
  List<Object?> get props => <Object?>[latitude, longitude, elevation, timestamp];
}

class RouteWaypoint extends Equatable {
  const RouteWaypoint({
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.elevation,
  });

  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final double? elevation;

  @override
  List<Object?> get props =>
      <Object?>[name, description, latitude, longitude, elevation];
}

/// Hasil parsing GPX yang siap di-preview di UI sebelum disimpan.
class ImportedRoute extends Equatable {
  const ImportedRoute({
    required this.name,
    this.description,
    this.sourceFile,
    required this.points,
    this.waypoints = const <RouteWaypoint>[],
  });

  final String name;
  final String? description;
  final String? sourceFile;
  final List<RoutePoint> points;
  final List<RouteWaypoint> waypoints;

  double get totalDistanceMeters {
    return geo.Geo.polylineLengthMeters(<geo.LatLng>[
      for (final RoutePoint p in points) geo.LatLng(p.latitude, p.longitude),
    ]);
  }

  double get elevationGainMeters {
    double gain = 0;
    double? prev;
    for (final RoutePoint p in points) {
      final double? el = p.elevation;
      if (el == null) continue;
      if (prev != null && el - prev > 1.0) {
        gain += el - prev;
      }
      prev = el;
    }
    return gain;
  }

  double? get maxElevation {
    double? best;
    for (final RoutePoint p in points) {
      if (p.elevation != null) {
        if (best == null || p.elevation! > best) best = p.elevation;
      }
    }
    return best;
  }

  double? get minElevation {
    double? best;
    for (final RoutePoint p in points) {
      if (p.elevation != null) {
        if (best == null || p.elevation! < best) best = p.elevation;
      }
    }
    return best;
  }

  @override
  List<Object?> get props =>
      <Object?>[name, description, sourceFile, points, waypoints];
}
