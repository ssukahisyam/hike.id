import 'package:equatable/equatable.dart';

import '../../../core/widgets/gps_accuracy_indicator.dart';
import '../domain/trip.dart';

/// Status flow tracking dari sudut UI.
enum TrackingPhase {
  idle,
  running,
  paused,
  saving,
  error,
}

class TrackingSession extends Equatable {
  const TrackingSession({
    this.phase = TrackingPhase.idle,
    this.activeTrip,
    this.lastFix,
    this.distanceMeters = 0,
    this.activeDuration = Duration.zero,
    this.elevationGain = 0,
    this.elevationLoss = 0,
    this.maxElevation,
    this.minElevation,
    this.maxSpeed = 0,
    this.errorMessage,
    this.gpsAccuracy = GpsAccuracyLevel.noSignal,
    this.mode = TrackingMode.balanced,
  });

  final TrackingPhase phase;
  final Trip? activeTrip;
  final TrackingFix? lastFix;
  final double distanceMeters;
  final Duration activeDuration;
  final double elevationGain;
  final double elevationLoss;
  final double? maxElevation;
  final double? minElevation;
  final double maxSpeed;
  final String? errorMessage;
  final GpsAccuracyLevel gpsAccuracy;
  final TrackingMode mode;

  bool get isRunning => phase == TrackingPhase.running;
  bool get isPaused => phase == TrackingPhase.paused;
  bool get isActive => phase == TrackingPhase.running || phase == TrackingPhase.paused;

  double get avgSpeed {
    if (activeDuration.inSeconds == 0) return 0;
    return distanceMeters / activeDuration.inSeconds;
  }

  TrackingSession copyWith({
    TrackingPhase? phase,
    Trip? activeTrip,
    TrackingFix? lastFix,
    double? distanceMeters,
    Duration? activeDuration,
    double? elevationGain,
    double? elevationLoss,
    double? maxElevation,
    double? minElevation,
    double? maxSpeed,
    String? errorMessage,
    GpsAccuracyLevel? gpsAccuracy,
    TrackingMode? mode,
    bool clearError = false,
    bool clearTrip = false,
  }) {
    return TrackingSession(
      phase: phase ?? this.phase,
      activeTrip: clearTrip ? null : (activeTrip ?? this.activeTrip),
      lastFix: lastFix ?? this.lastFix,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      activeDuration: activeDuration ?? this.activeDuration,
      elevationGain: elevationGain ?? this.elevationGain,
      elevationLoss: elevationLoss ?? this.elevationLoss,
      maxElevation: maxElevation ?? this.maxElevation,
      minElevation: minElevation ?? this.minElevation,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      gpsAccuracy: gpsAccuracy ?? this.gpsAccuracy,
      mode: mode ?? this.mode,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        phase,
        activeTrip,
        lastFix,
        distanceMeters,
        activeDuration,
        elevationGain,
        elevationLoss,
        maxElevation,
        minElevation,
        maxSpeed,
        errorMessage,
        gpsAccuracy,
        mode,
      ];
}

/// Subset GpsFix yang dibutuhkan UI (tanpa lib infra).
class TrackingFix extends Equatable {
  const TrackingFix({
    required this.latitude,
    required this.longitude,
    this.elevation,
    this.accuracy,
    this.speed,
    this.heading,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double? elevation;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final DateTime timestamp;

  @override
  List<Object?> get props =>
      <Object?>[latitude, longitude, elevation, accuracy, speed, heading, timestamp];
}
