import 'dart:math' as math;

/// Distance & geo helpers.
///
/// Hike.id memakai sistem koordinat WGS84 (EPSG:4326) — PLANNING §5.
class Geo {
  Geo._();

  /// Bumi rata-rata (mean radius) dalam meter.
  static const double earthRadiusMeters = 6371008.8;

  /// Haversine distance antara dua titik (lat, lng) dalam meter.
  ///
  /// Akurat untuk jarak < ratusan km. Cukup untuk hiking.
  static double haversineMeters(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final double phi1 = _deg2rad(lat1);
    final double phi2 = _deg2rad(lat2);
    final double dPhi = _deg2rad(lat2 - lat1);
    final double dLambda = _deg2rad(lng2 - lng1);

    final double a = math.sin(dPhi / 2) * math.sin(dPhi / 2) +
        math.cos(phi1) * math.cos(phi2) * math.sin(dLambda / 2) * math.sin(dLambda / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  /// Akumulasi jarak total sepanjang sebuah polyline.
  ///
  /// Mengabaikan titik dengan flag `isPaused == true` saat agregasi
  /// dilakukan oleh caller; fungsi ini tidak filter, hanya hitung.
  static double polylineLengthMeters(List<LatLng> points) {
    if (points.length < 2) return 0;
    double total = 0;
    for (int i = 1; i < points.length; i++) {
      final LatLng a = points[i - 1];
      final LatLng b = points[i];
      total += haversineMeters(a.lat, a.lng, b.lat, b.lng);
    }
    return total;
  }

  /// Outlier filter — buang titik yang implies kecepatan > [maxSpeedMps].
  ///
  /// Default 200 m/s = ~720 km/h, jelas teleport bug.
  /// Lihat PRD §9.1.
  static bool isTeleport(
    LatLng prev,
    int prevTimestampMs,
    LatLng next,
    int nextTimestampMs, {
    double maxSpeedMps = 200,
  }) {
    final int dtMs = nextTimestampMs - prevTimestampMs;
    if (dtMs <= 0) return false;
    final double meters = haversineMeters(prev.lat, prev.lng, next.lat, next.lng);
    final double speed = meters / (dtMs / 1000.0);
    return speed > maxSpeedMps;
  }

  static double _deg2rad(double d) => d * math.pi / 180.0;
}

/// Lightweight value type for lat/lng pair. Sengaja tidak depend ke
/// flutter_map/geolocator supaya mudah dipakai di unit test.
class LatLng {
  const LatLng(this.lat, this.lng);
  final double lat;
  final double lng;

  @override
  String toString() => 'LatLng($lat, $lng)';
}
