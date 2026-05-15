import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../domain/trip.dart';

/// Snapshot data dari GPS untuk satu sample.
///
/// Dipisah dari `TrackPoint` domain entity supaya layer infrastruktur
/// tidak perlu tahu soal trip ID.
class GpsFix {
  const GpsFix({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    this.speed,
    this.heading,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final DateTime timestamp;
}

/// Abstraksi GPS service supaya bisa di-mock di test.
abstract class GpsService {
  /// Pastikan permission diberikan & service aktif. Throw jika tidak bisa.
  Future<void> ensureReady();

  /// Stream live update sesuai mode tracking.
  Stream<GpsFix> stream(TrackingMode mode);

  /// Snapshot terakhir yang diketahui (untuk SOS screen).
  Future<GpsFix?> lastKnown();
}

class GeolocatorGpsService implements GpsService {
  GeolocatorGpsService();

  @override
  Future<void> ensureReady() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const GpsUnavailable('GPS device dimatikan. Aktifkan lokasi di pengaturan sistem.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const GpsUnavailable('Izin lokasi ditolak permanen. Buka pengaturan untuk mengaktifkan.');
    }
    if (permission == LocationPermission.denied) {
      throw const GpsUnavailable('Izin lokasi belum diberikan.');
    }
  }

  @override
  Stream<GpsFix> stream(TrackingMode mode) {
    final LocationSettings settings = _settingsFor(mode);
    return Geolocator.getPositionStream(locationSettings: settings).map(_fixFromPosition);
  }

  @override
  Future<GpsFix?> lastKnown() async {
    try {
      final Position? position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;
      return _fixFromPosition(position);
    } on Object {
      return null;
    }
  }

  /// Build LocationSettings — Android dapat foreground service config
  /// supaya tracking jalan saat layar mati / app di background (PRD US-TRK-02).
  ///
  /// iOS pakai AppleSettings dengan `showBackgroundLocationIndicator` aktif
  /// supaya user tahu app sedang track.
  LocationSettings _settingsFor(TrackingMode mode) {
    final LocationAccuracy accuracy = _accuracyFor(mode);
    final int distanceFilter = _distanceFilterFor(mode);

    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        // Wake lock supaya CPU tetap nyala saat layar mati — wajib untuk
        // tracking pendakian panjang.
        // ignore: avoid_redundant_argument_values
        forceLocationManager: false,
        intervalDuration: _intervalFor(mode),
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: _notificationTitle(mode),
          notificationText: _notificationText(mode),
          notificationChannelName: 'Tracking aktif',
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    }

    if (Platform.isIOS || Platform.isMacOS) {
      return AppleSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        // Indicator persistent di status bar iOS saat di background.
        showBackgroundLocationIndicator: true,
        pauseLocationUpdatesAutomatically: false,
        activityType: ActivityType.fitness,
      );
    }

    return LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );
  }

  // Mapping mode → akurasi (PRD §4.3 / US-TRK-04).
  LocationAccuracy _accuracyFor(TrackingMode mode) {
    switch (mode) {
      case TrackingMode.highAccuracy:
        return LocationAccuracy.bestForNavigation;
      case TrackingMode.balanced:
        return LocationAccuracy.high;
      case TrackingMode.batterySaver:
        return LocationAccuracy.medium;
    }
  }

  /// Distance filter (meter) — buang update yang lebih dekat dari ini
  /// supaya battery hemat. 0 = tidak ada filter.
  int _distanceFilterFor(TrackingMode mode) {
    switch (mode) {
      case TrackingMode.highAccuracy:
        return 0;
      case TrackingMode.balanced:
        return 5;
      case TrackingMode.batterySaver:
        return 15;
    }
  }

  /// Interval polling Android. Native akan tetap respect distance filter,
  /// tapi interval ini batas atas frekuensi sample.
  Duration _intervalFor(TrackingMode mode) {
    switch (mode) {
      case TrackingMode.highAccuracy:
        return const Duration(seconds: 3);
      case TrackingMode.balanced:
        return const Duration(seconds: 10);
      case TrackingMode.batterySaver:
        return const Duration(seconds: 30);
    }
  }

  String _notificationTitle(TrackingMode mode) {
    switch (mode) {
      case TrackingMode.highAccuracy:
        return 'Hike.id — Tracking Akurat';
      case TrackingMode.balanced:
        return 'Hike.id — Tracking Aktif';
      case TrackingMode.batterySaver:
        return 'Hike.id — Tracking Hemat';
    }
  }

  String _notificationText(TrackingMode mode) {
    switch (mode) {
      case TrackingMode.highAccuracy:
        return 'Sample tiap 3–5 detik. Konsumsi daya tinggi.';
      case TrackingMode.balanced:
        return 'Sample tiap 10–15 detik. Mode default.';
      case TrackingMode.batterySaver:
        return 'Sample tiap 30–60 detik. Hemat baterai.';
    }
  }

  GpsFix _fixFromPosition(Position p) {
    return GpsFix(
      latitude: p.latitude,
      longitude: p.longitude,
      altitude: p.altitude,
      accuracy: p.accuracy,
      speed: p.speed,
      heading: p.heading,
      timestamp: p.timestamp,
    );
  }
}

class GpsUnavailable implements Exception {
  const GpsUnavailable(this.message);
  final String message;

  @override
  String toString() => 'GpsUnavailable: $message';
}

/// Override-able provider supaya test bisa pakai fake.
final Provider<GpsService> gpsServiceProvider = Provider<GpsService>((Ref ref) {
  return GeolocatorGpsService();
});
