import 'package:flutter_test/flutter_test.dart';
import 'package:hike_id/core/utils/distance.dart';
import 'package:hike_id/core/utils/off_route.dart';

void main() {
  group('OffRouteDetector', () {
    test('returns null when on route', () {
      final OffRouteDetector det = OffRouteDetector(thresholdMeters: 100);
      const List<LatLng> route = <LatLng>[
        LatLng(-7.5, 110.4),
        LatLng(-7.5005, 110.4005),
        LatLng(-7.501, 110.401),
      ];
      // User berada tepat di waypoint pertama.
      final OffRouteResult? r = det.evaluate(
        userPosition: const LatLng(-7.5, 110.4),
        route: route,
      );
      expect(r, isNull);
    });

    test('returns warning when far from route', () {
      final OffRouteDetector det = OffRouteDetector(thresholdMeters: 100);
      const List<LatLng> route = <LatLng>[
        LatLng(-7.5, 110.4),
        LatLng(-7.501, 110.401),
      ];
      // User ~5km dari route.
      final OffRouteResult? r = det.evaluate(
        userPosition: const LatLng(-7.55, 110.45),
        route: route,
      );
      expect(r, isNotNull);
      expect(r!.distanceMeters, greaterThan(100));
    });

    test('respects cooldown after warning fires', () {
      final OffRouteDetector det = OffRouteDetector(
        thresholdMeters: 100,
        cooldown: const Duration(seconds: 60),
      );
      const List<LatLng> route = <LatLng>[
        LatLng(-7.5, 110.4),
        LatLng(-7.501, 110.401),
      ];
      const LatLng off = LatLng(-7.55, 110.45);

      final OffRouteResult? first = det.evaluate(userPosition: off, route: route);
      expect(first, isNotNull);

      // Kedua segera setelah pertama harus null karena cooldown.
      final OffRouteResult? second = det.evaluate(userPosition: off, route: route);
      expect(second, isNull);
    });

    test('returns null for short polyline', () {
      final OffRouteDetector det = OffRouteDetector();
      final OffRouteResult? r = det.evaluate(
        userPosition: const LatLng(-7.5, 110.4),
        route: const <LatLng>[LatLng(-7.5, 110.4)],
      );
      expect(r, isNull);
    });
  });
}
