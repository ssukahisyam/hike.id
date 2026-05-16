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

/// Status permission yang dipakai oleh UI untuk render state berbeda.
enum LocationPermissionStatus {
  /// User sudah grant — tracking bisa start.
  granted,

  /// User belum pernah ditanya, atau pernah denied non-permanent.
  denied,

  /// User pilih "Don't ask again" / system block — harus buka pengaturan.
  deniedForever,

  /// GPS device dimatikan di system settings.
  serviceDisabled,
}

/// Abstraksi GPS service supaya bisa di-mock di test.
abstract class GpsService {
  /// Cek status permission tanpa request — aman dipanggil dari widget build.
  Future<LocationPermissionStatus> checkPermission();

  /// Request permission ke OS (popup system). Return status setelah dialog
  /// di-dismiss. Aman dipanggil berkali-kali — kalau sudah granted akan
  /// langsung return tanpa popup.
  Future<LocationPermissionStatus> requestPermission();

  /// Buka pengaturan app supaya user bisa enable permission manual saat
  /// status `deniedForever`. Return true kalau pengaturan terbuka.
  Future<bool> openLocationSettings();

  /// Pastikan permission diberikan & service aktif. Throw jika tidak bisa.
  /// Dipanggil oleh tracking controller saat start.
  Future<void> ensureReady();

  /// Stream live update sesuai mode tracking.
  Stream<GpsFix> stream(TrackingMode mode);

  /// Snapshot terakhir yang diketahui (untuk SOS screen).
  Future<GpsFix?> lastKnown();
}

class GeolocatorGpsService implements GpsService {
  GeolocatorGpsService();

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationPermissionStatus.serviceDisabled;
    final LocationPermission p = await Geolocator.checkPermission();
    return _mapStatus(p);
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationPermissionStatus.serviceDisabled;
    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    return _mapStatus(p);
  }

  @override
  Future<bool> openLocationSettings() async {
    return Geolocator.openAppSettings();
  }

  LocationPermissionStatus _mapStatus(LocationPermission p) {
    switch (p) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
    }
  }

  @override
  Future<void> ensureReady() async {
    final LocationPermissionStatus status = await requestPermission();
    switch (status) {
      case LocationPermissionStatus.granted:
        return;
      case LocationPermissionStatus.serviceDisabled:
        throw const GpsUnavailable(
          'GPS device dimatikan. Aktifkan lokasi di pengaturan sistem.',
        );
      case LocationPermissionStatus.deniedForever:
        throw const GpsUnavailable(
          'Izin lokasi ditolak permanen. Buka pengaturan untuk mengaktifkan.',
        );
      case LocationPermissionStatus.denied:
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
