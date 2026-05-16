import 'distance.dart';

/// Off-route detection helper — PRD §4.9.
///
/// Hanya aktif saat user follow imported GPX route. Threshold default 100m
/// dengan cooldown 60 detik agar tidak terlalu banyak false alert.
class OffRouteDetector {
  OffRouteDetector({
    this.thresholdMeters = 100,
    this.cooldown = const Duration(seconds: 60),
  });

  final double thresholdMeters;
  final Duration cooldown;
  DateTime? _lastWarningAt;

  /// Cek posisi user terhadap polyline rute. Return alasan + jarak kalau
  /// off-route, atau null kalau aman / cooldown belum reset.
  ///
  /// Algoritma: cari titik nearest pada polyline, hitung jarak Haversine
  /// (cukup akurat untuk rentang sub-km — tidak butuh true cross-track).
  OffRouteResult? evaluate({
    required LatLng userPosition,
    required List<LatLng> route,
  }) {
    if (route.length < 2) return null;
    final DateTime now = DateTime.now();
    if (_lastWarningAt != null && now.difference(_lastWarningAt!) < cooldown) {
      return null;
    }
    double minDist = double.infinity;
    for (final LatLng p in route) {
      final double d = Geo.haversineMeters(
        userPosition.lat,
        userPosition.lng,
        p.lat,
        p.lng,
      );
      if (d < minDist) minDist = d;
      if (minDist <= thresholdMeters) return null; // dekat ke route, aman
    }
    _lastWarningAt = now;
    return OffRouteResult(distanceMeters: minDist);
  }

  /// Manual reset — dipakai user yang secara sengaja off-route.
  void mute() {
    _lastWarningAt = DateTime.now().add(const Duration(days: 1));
  }
}

class OffRouteResult {
  const OffRouteResult({required this.distanceMeters});
  final double distanceMeters;
}
