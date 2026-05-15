import 'dart:async';

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

  LocationSettings _settingsFor(TrackingMode mode) {
    // Mapping dari PRD §4.3 (US-TRK-04) — 3 mode tracking.
    switch (mode) {
      case TrackingMode.highAccuracy:
        return const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
        );
      case TrackingMode.balanced:
        return const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        );
      case TrackingMode.batterySaver:
        return const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 15,
        );
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
