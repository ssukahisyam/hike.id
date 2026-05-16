import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/gps_service.dart';

/// Controller status permission lokasi — dipakai UI untuk render state
/// berbeda (granted / denied / deniedForever / serviceDisabled).
///
/// Auto-check status saat init; UI bisa trigger request via `request()`
/// dan kembali ke pengaturan via `openSettings()`.
class LocationPermissionController extends StateNotifier<LocationPermissionStatus> {
  LocationPermissionController(this._service)
      : super(LocationPermissionStatus.denied) {
    refresh();
  }

  final GpsService _service;

  /// Cek ulang status saat ini (mis. setelah user kembali dari pengaturan).
  Future<void> refresh() async {
    state = await _service.checkPermission();
  }

  /// Trigger system permission dialog. Aman dipanggil berkali-kali.
  Future<LocationPermissionStatus> request() async {
    final LocationPermissionStatus s = await _service.requestPermission();
    state = s;
    return s;
  }

  /// Buka app settings di OS supaya user bisa enable permission manual.
  /// Setelah user kembali ke app, panggil `refresh()` untuk re-check.
  Future<bool> openSettings() => _service.openLocationSettings();
}

final StateNotifierProvider<LocationPermissionController,
    LocationPermissionStatus> locationPermissionProvider = StateNotifierProvider<
    LocationPermissionController, LocationPermissionStatus>(
  (Ref ref) => LocationPermissionController(ref.watch(gpsServiceProvider)),
);
