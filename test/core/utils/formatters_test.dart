import 'package:flutter_test/flutter_test.dart';
import 'package:hike_id/core/utils/formatters.dart';

void main() {
  group('Format.distance', () {
    test('formats sub-kilometer in meters', () {
      expect(Format.distance(845), equals('845 m'));
      expect(Format.distance(0), equals('0 m'));
    });

    test('formats kilometers with comma decimal', () {
      expect(Format.distance(12345), equals('12,3 km'));
      expect(Format.distance(1500), equals('1,5 km'));
    });
  });

  group('Format.duration', () {
    test('shows hours when present', () {
      expect(
        Format.duration(const Duration(hours: 2, minutes: 5, seconds: 9)),
        equals('2j 05m 09s'),
      );
    });

    test('skips hours when zero', () {
      expect(
        Format.duration(const Duration(minutes: 5, seconds: 9)),
        equals('05m 09s'),
      );
    });
  });

  group('Format.elevation', () {
    test('groups thousands with dot separator', () {
      expect(Format.elevation(2345), equals('2.345 m'));
      expect(Format.elevation(987), equals('987 m'));
    });
  });
}
