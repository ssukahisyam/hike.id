/// Formatters untuk display angka di UI.
///
/// Selalu pakai mono font untuk angka stat — DESIGN.md §4.4.
class Format {
  Format._();

  /// 12345 m -> "12,3 km" atau 845 m -> "845 m".
  static String distance(double meters) {
    if (meters >= 1000) {
      final double km = meters / 1000;
      return '${_oneDecimal(km)} km';
    }
    return '${meters.round()} m';
  }

  /// 7321 detik -> "2j 02m 01s" / 121 detik -> "02m 01s".
  static String duration(Duration d) {
    final int totalSeconds = d.inSeconds;
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;
    if (hours > 0) {
      return '${hours}j ${_pad(minutes)}m ${_pad(seconds)}s';
    }
    return '${_pad(minutes)}m ${_pad(seconds)}s';
  }

  /// 2.5 m/s -> "9,0 km/jam".
  static String speedKmh(double mps) {
    final double kmh = mps * 3.6;
    return '${_oneDecimal(kmh)} km/jam';
  }

  /// Pace mnt/km dari kecepatan m/s.
  static String paceMinKm(double mps) {
    if (mps <= 0) return '-';
    final double secPerKm = 1000 / mps;
    final int minutes = secPerKm ~/ 60;
    final int seconds = (secPerKm % 60).round();
    return '${minutes}:${_pad(seconds)} /km';
  }

  /// 2345 m elev -> "2.345 m"
  static String elevation(double meters) {
    final int rounded = meters.round();
    final String s = rounded.abs().toString();
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) out.write('.');
      out.write(s[i]);
    }
    final String prefix = rounded < 0 ? '-' : '';
    return '$prefix${out.toString()} m';
  }

  /// Coordinate formatting — DD with 6 decimals.
  static String latLng(double lat, double lng) {
    return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
  static String _oneDecimal(double n) {
    final String fixed = n.toStringAsFixed(1);
    return fixed.replaceAll('.', ',');
  }
}
