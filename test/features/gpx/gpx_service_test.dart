import 'package:flutter_test/flutter_test.dart';
import 'package:hike_id/features/gpx/data/gpx_service.dart';
import 'package:hike_id/features/gpx/domain/imported_route.dart';

void main() {
  group('GpxService.parse', () {
    test('parses a simple track', () {
      const String xml = '''<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="Hike.id Test"
     xmlns="http://www.topografix.com/GPX/1/1">
  <metadata>
    <name>Cikuray</name>
    <desc>Test trip</desc>
  </metadata>
  <trk>
    <name>Cikuray</name>
    <trkseg>
      <trkpt lat="-7.4" lon="107.8"><ele>1500</ele></trkpt>
      <trkpt lat="-7.41" lon="107.81"><ele>1700</ele></trkpt>
      <trkpt lat="-7.42" lon="107.82"><ele>1900</ele></trkpt>
    </trkseg>
  </trk>
</gpx>''';

      final ImportedRoute route = GpxService.parse(xml, sourceFile: 'cikuray.gpx');
      expect(route.name, equals('Cikuray'));
      expect(route.points.length, equals(3));
      expect(route.points.first.elevation, equals(1500));
      expect(route.elevationGainMeters, closeTo(400, 1));
      expect(route.maxElevation, equals(1900));
      expect(route.minElevation, equals(1500));
    });

    test('throws readable error on empty content', () {
      expect(
        () => GpxService.parse(''),
        throwsA(isA<GpxImportException>()),
      );
    });

    test('throws readable error when no track points', () {
      const String xml = '''<?xml version="1.0"?>
<gpx version="1.1" xmlns="http://www.topografix.com/GPX/1/1">
  <wpt lat="-7.4" lon="107.8"><name>Just a waypoint</name></wpt>
</gpx>''';
      expect(
        () => GpxService.parse(xml),
        throwsA(isA<GpxImportException>()),
      );
    });

    test('throws readable error on invalid XML', () {
      expect(
        () => GpxService.parse('this is not xml'),
        throwsA(isA<GpxImportException>()),
      );
    });
  });
}
