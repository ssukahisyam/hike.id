import 'package:flutter_test/flutter_test.dart';
import 'package:hike_id/core/utils/distance.dart';

void main() {
  group('Geo.haversineMeters', () {
    test('returns 0 for identical points', () {
      expect(
        Geo.haversineMeters(-7.532, 110.443, -7.532, 110.443),
        equals(0),
      );
    });

    test('Jakarta to Bandung is roughly 120 km', () {
      // Monas, Jakarta -> Gedung Sate, Bandung. ~120 km secara jalur burung.
      final double meters = Geo.haversineMeters(
        -6.1754, 106.8272,
        -6.9024, 107.6189,
      );
      expect(meters, greaterThan(110000));
      expect(meters, lessThan(130000));
    });

    test('1 degree latitude is ~111 km', () {
      final double meters = Geo.haversineMeters(0, 0, 1, 0);
      expect(meters, greaterThan(110000));
      expect(meters, lessThan(112000));
    });
  });

  group('Geo.polylineLengthMeters', () {
    test('returns 0 for empty / single-point polyline', () {
      expect(Geo.polylineLengthMeters(<LatLng>[]), equals(0));
      expect(Geo.polylineLengthMeters(const <LatLng>[LatLng(0, 0)]), equals(0));
    });

    test('sums segment lengths along a polyline', () {
      const List<LatLng> points = <LatLng>[
        LatLng(0, 0),
        LatLng(0, 1),
        LatLng(1, 1),
      ];
      final double total = Geo.polylineLengthMeters(points);
      // ~111 km untuk 1 derajat lng di equator + ~111 km untuk 1 derajat lat.
      expect(total, greaterThan(220000));
      expect(total, lessThan(230000));
    });
  });

  group('Geo.isTeleport', () {
    test('flags impossibly fast jumps', () {
      // 100 km dalam 1 detik.
      const LatLng a = LatLng(0, 0);
      const LatLng b = LatLng(0, 1);
      expect(
        Geo.isTeleport(a, 0, b, 1000),
        isTrue,
      );
    });

    test('does not flag normal walking pace', () {
      // ~5 m dalam 3 detik = 1.6 m/s walking pace.
      const LatLng a = LatLng(0, 0);
      const LatLng b = LatLng(0.000045, 0); // ~5 meters
      expect(
        Geo.isTeleport(a, 0, b, 3000),
        isFalse,
      );
    });
  });
}
