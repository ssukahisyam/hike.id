import 'package:equatable/equatable.dart';

/// Sebuah titik GPS individual sepanjang trip.
class TrackPoint extends Equatable {
  const TrackPoint({
    this.id,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    this.elevation,
    this.accuracy,
    this.speed,
    this.heading,
    required this.timestamp,
    this.isPaused = false,
  });

  final int? id;
  final String tripId;
  final double latitude;
  final double longitude;

  /// meter
  final double? elevation;

  /// meter
  final double? accuracy;

  /// m/s
  final double? speed;

  /// degree 0..360
  final double? heading;

  final DateTime timestamp;
  final bool isPaused;

  @override
  List<Object?> get props => <Object?>[
        id,
        tripId,
        latitude,
        longitude,
        elevation,
        accuracy,
        speed,
        heading,
        timestamp,
        isPaused,
      ];
}
