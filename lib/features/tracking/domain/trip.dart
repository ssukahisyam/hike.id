import 'package:equatable/equatable.dart';

/// Status tracking sebuah Trip.
enum TripStatus {
  active,
  paused,
  completed,
  discarded;

  static TripStatus fromName(String? n) =>
      TripStatus.values.firstWhere((TripStatus e) => e.name == n, orElse: () => TripStatus.active);
}

/// Mode tracking yang dipakai sepanjang trip.
enum TrackingMode {
  highAccuracy,
  balanced,
  batterySaver;

  static TrackingMode fromName(String? n) => TrackingMode.values
      .firstWhere((TrackingMode e) => e.name == n, orElse: () => TrackingMode.balanced);
}

/// Asal data trip.
enum TripSource {
  recorded,
  importedGpx;

  static TripSource fromName(String? n) =>
      TripSource.values.firstWhere((TripSource e) => e.name == n, orElse: () => TripSource.recorded);
}

class Trip extends Equatable {
  const Trip({
    required this.id,
    required this.name,
    this.mountainName,
    this.difficulty,
    this.coverPhotoUri,
    required this.startedAt,
    this.endedAt,
    this.totalDistance = 0,
    this.totalDuration = Duration.zero,
    this.elevationGain = 0,
    this.elevationLoss = 0,
    this.maxElevation,
    this.minElevation,
    this.avgSpeed = 0,
    this.maxSpeed = 0,
    this.status = TripStatus.active,
    this.trackingMode = TrackingMode.balanced,
    this.source = TripSource.recorded,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? mountainName;

  /// 1..5
  final int? difficulty;
  final String? coverPhotoUri;

  final DateTime startedAt;
  final DateTime? endedAt;

  /// meter
  final double totalDistance;

  /// total durasi aktif (exclude pause)
  final Duration totalDuration;

  /// meter
  final double elevationGain;
  final double elevationLoss;
  final double? maxElevation;
  final double? minElevation;

  /// m/s
  final double avgSpeed;
  final double maxSpeed;

  final TripStatus status;
  final TrackingMode trackingMode;
  final TripSource source;

  final DateTime createdAt;
  final DateTime updatedAt;

  Trip copyWith({
    String? name,
    String? mountainName,
    int? difficulty,
    String? coverPhotoUri,
    DateTime? endedAt,
    double? totalDistance,
    Duration? totalDuration,
    double? elevationGain,
    double? elevationLoss,
    double? maxElevation,
    double? minElevation,
    double? avgSpeed,
    double? maxSpeed,
    TripStatus? status,
    TrackingMode? trackingMode,
    DateTime? updatedAt,
  }) {
    return Trip(
      id: id,
      name: name ?? this.name,
      mountainName: mountainName ?? this.mountainName,
      difficulty: difficulty ?? this.difficulty,
      coverPhotoUri: coverPhotoUri ?? this.coverPhotoUri,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      totalDistance: totalDistance ?? this.totalDistance,
      totalDuration: totalDuration ?? this.totalDuration,
      elevationGain: elevationGain ?? this.elevationGain,
      elevationLoss: elevationLoss ?? this.elevationLoss,
      maxElevation: maxElevation ?? this.maxElevation,
      minElevation: minElevation ?? this.minElevation,
      avgSpeed: avgSpeed ?? this.avgSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      status: status ?? this.status,
      trackingMode: trackingMode ?? this.trackingMode,
      source: source,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        name,
        mountainName,
        difficulty,
        coverPhotoUri,
        startedAt,
        endedAt,
        totalDistance,
        totalDuration,
        elevationGain,
        elevationLoss,
        maxElevation,
        minElevation,
        avgSpeed,
        maxSpeed,
        status,
        trackingMode,
        source,
        createdAt,
        updatedAt,
      ];
}
