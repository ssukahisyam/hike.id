import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpx/gpx.dart' as gpx_pkg;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../checkpoint/domain/checkpoint.dart';
import '../../tracking/data/track_point_repository.dart';
import '../../tracking/data/trip_repository.dart';
import '../../tracking/domain/track_point.dart';
import '../../tracking/domain/trip.dart';
import '../domain/imported_route.dart';

/// Eksepsi yang readable saat import GPX gagal — PRD US-GPX-01.
class GpxImportException implements Exception {
  GpxImportException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Service untuk read/write GPX file.
///
/// Di-decouple dari UI supaya bisa di-test tanpa flutter_test.
class GpxService {
  GpxService({
    required TripRepository tripRepository,
    required TrackPointRepository trackPointRepository,
  })  : _tripRepo = tripRepository,
        _trackRepo = trackPointRepository;

  final TripRepository _tripRepo;
  final TrackPointRepository _trackRepo;

  /// Parse XML string menjadi `ImportedRoute`. Tidak menyimpan ke DB.
  ///
  /// Static supaya bisa dipakai dari unit test tanpa Drift dependency.
  static ImportedRoute parse(String xmlContent, {String? sourceFile}) {
    if (xmlContent.trim().isEmpty) {
      throw GpxImportException('File kosong.');
    }
    final gpx_pkg.Gpx parsed;
    try {
      parsed = gpx_pkg.GpxReader().fromString(xmlContent);
    } on Object catch (e) {
      throw GpxImportException(
        'File tidak terbaca sebagai GPX. Pastikan format benar.\n($e)',
      );
    }

    final List<RoutePoint> points = <RoutePoint>[];
    // Track points
    for (final gpx_pkg.Trk trk in parsed.trks) {
      for (final gpx_pkg.Trkseg seg in trk.trksegs) {
        for (final gpx_pkg.Wpt wp in seg.trkpts) {
          if (wp.lat == null || wp.lon == null) continue;
          points.add(RoutePoint(
            latitude: wp.lat!,
            longitude: wp.lon!,
            elevation: wp.ele,
            timestamp: wp.time,
          ),);
        }
      }
    }
    // Route points (jarang dipakai oleh tools modern, tapi tetap support)
    for (final gpx_pkg.Rte rte in parsed.rtes) {
      for (final gpx_pkg.Wpt wp in rte.rtepts) {
        if (wp.lat == null || wp.lon == null) continue;
        points.add(RoutePoint(
          latitude: wp.lat!,
          longitude: wp.lon!,
          elevation: wp.ele,
          timestamp: wp.time,
        ),);
      }
    }

    if (points.isEmpty) {
      throw GpxImportException(
        'GPX ini tidak punya track. Apakah file waypoint?',
      );
    }

    final List<RouteWaypoint> waypoints = <RouteWaypoint>[
      for (final gpx_pkg.Wpt wp in parsed.wpts)
        if (wp.lat != null && wp.lon != null)
          RouteWaypoint(
            name: wp.name ?? 'Waypoint',
            description: wp.desc,
            latitude: wp.lat!,
            longitude: wp.lon!,
            elevation: wp.ele,
          ),
    ];

    final String name = parsed.metadata?.name ??
        (parsed.trks.isNotEmpty ? (parsed.trks.first.name ?? 'Imported route') : 'Imported route');

    return ImportedRoute(
      name: name,
      description: parsed.metadata?.desc,
      sourceFile: sourceFile,
      points: points,
      waypoints: waypoints,
    );
  }

  /// Convenience: parse + simpan sebagai Trip dengan source = importedGpx.
  ///
  /// Dipakai supaya rute yang diimport bisa difollow & ditampilkan di
  /// History sama seperti rekaman biasa, sambil ditandai sumbernya.
  Future<Trip> importToDatabase(ImportedRoute route) async {
    final DateTime now = DateTime.now();
    final DateTime startedAt = route.points.first.timestamp ?? now;
    final DateTime endedAt = route.points.last.timestamp ?? now;
    final String tripId = 'gpx-${now.microsecondsSinceEpoch}';

    final List<TrackPoint> points = <TrackPoint>[
      for (final RoutePoint rp in route.points)
        TrackPoint(
          tripId: tripId,
          latitude: rp.latitude,
          longitude: rp.longitude,
          elevation: rp.elevation,
          timestamp: rp.timestamp ?? now,
        ),
    ];

    final Trip trip = Trip(
      id: tripId,
      name: route.name,
      startedAt: startedAt,
      endedAt: endedAt,
      totalDistance: route.totalDistanceMeters,
      totalDuration: endedAt.difference(startedAt),
      elevationGain: route.elevationGainMeters,
      maxElevation: route.maxElevation,
      minElevation: route.minElevation,
      status: TripStatus.completed,
      source: TripSource.importedGpx,
      createdAt: now,
      updatedAt: now,
    );
    await _tripRepo.insert(trip);
    await _trackRepo.insertBatch(points);
    return trip;
  }

  /// Render Trip + checkpoints ke GPX 1.1 string.
  String render({
    required Trip trip,
    required List<TrackPoint> points,
    List<Checkpoint> checkpoints = const <Checkpoint>[],
  }) {
    final gpx_pkg.Gpx out = gpx_pkg.Gpx()
      ..creator = 'Hike.id (id.hike.app)'
      ..version = '1.1'
      ..metadata = (gpx_pkg.Metadata()
        ..name = trip.name
        ..desc = trip.mountainName
        ..time = trip.startedAt);

    // Waypoints from checkpoints (PRD US-GPX-02 — opsional toggle).
    if (checkpoints.isNotEmpty) {
      out.wpts = <gpx_pkg.Wpt>[
        for (final Checkpoint cp in checkpoints)
          gpx_pkg.Wpt()
            ..lat = cp.latitude
            ..lon = cp.longitude
            ..ele = cp.elevation
            ..name = cp.name
            ..desc = cp.description
            ..type = cp.type.name
            ..time = cp.createdAt,
      ];
    }

    // Track segment from track points.
    final gpx_pkg.Trk trk = gpx_pkg.Trk()
      ..name = trip.name
      ..trksegs = <gpx_pkg.Trkseg>[
        gpx_pkg.Trkseg()
          ..trkpts = <gpx_pkg.Wpt>[
            for (final TrackPoint p in points)
              if (!p.isPaused)
                gpx_pkg.Wpt()
                  ..lat = p.latitude
                  ..lon = p.longitude
                  ..ele = p.elevation
                  ..time = p.timestamp,
          ],
      ];
    out.trks = <gpx_pkg.Trk>[trk];

    return gpx_pkg.GpxWriter().asString(out, pretty: true);
  }

  /// Tulis konten GPX ke file di scoped storage; return File path.
  Future<File> writeToFile(String content, {required String filename}) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final Directory exportDir = Directory(p.join(dir.path, 'gpx_export'));
    if (!exportDir.existsSync()) {
      await exportDir.create(recursive: true);
    }
    final File file = File(p.join(exportDir.path, _sanitizeFilename(filename)));
    await file.writeAsString(content);
    return file;
  }

  String _sanitizeFilename(String input) {
    final String safe = input
        .replaceAll(RegExp(r'[^A-Za-z0-9 _.-]'), '_')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    return safe.endsWith('.gpx') ? safe : '$safe.gpx';
  }
}

final Provider<GpxService> gpxServiceProvider = Provider<GpxService>((Ref ref) {
  return GpxService(
    tripRepository: ref.watch(tripRepositoryProvider),
    trackPointRepository: ref.watch(trackPointRepositoryProvider),
  );
});
