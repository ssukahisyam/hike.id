import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../../../data/local/tables.dart';
import '../domain/track_point.dart';

class TrackPointRepository {
  TrackPointRepository(this._db);

  final HikeIdDatabase _db;

  Future<void> insert(TrackPoint p) async {
    await _db.into(_db.trackPoints).insert(_toCompanion(p));
  }

  Future<void> insertBatch(List<TrackPoint> points) async {
    if (points.isEmpty) return;
    await _db.batch((Batch batch) {
      batch.insertAll(_db.trackPoints, points.map(_toCompanion).toList());
    });
  }

  Future<List<TrackPoint>> findByTripId(String tripId) async {
    final List<TrackPointData> rows = await (_db.select(_db.trackPoints)
          ..where(($TrackPointsTable t) => t.tripId.equals(tripId))
          ..orderBy(<OrderClauseGenerator<$TrackPointsTable>>[
            ($TrackPointsTable t) => OrderingTerm(expression: t.timestamp),
          ]))
        .get();
    return rows.map(_fromRow).toList();
  }

  Stream<List<TrackPoint>> watchByTripId(String tripId) {
    return (_db.select(_db.trackPoints)
          ..where(($TrackPointsTable t) => t.tripId.equals(tripId))
          ..orderBy(<OrderClauseGenerator<$TrackPointsTable>>[
            ($TrackPointsTable t) => OrderingTerm(expression: t.timestamp),
          ]))
        .watch()
        .map((List<TrackPointData> rows) => rows.map(_fromRow).toList());
  }

  Future<int> deleteByTripId(String tripId) {
    return (_db.delete(_db.trackPoints)..where(($TrackPointsTable t) => t.tripId.equals(tripId)))
        .go();
  }

  TrackPointsCompanion _toCompanion(TrackPoint p) {
    return TrackPointsCompanion(
      id: p.id == null ? const Value<int>.absent() : Value<int>(p.id!),
      tripId: Value<String>(p.tripId),
      latitude: Value<double>(p.latitude),
      longitude: Value<double>(p.longitude),
      elevation: Value<double?>(p.elevation),
      accuracy: Value<double?>(p.accuracy),
      speed: Value<double?>(p.speed),
      heading: Value<double?>(p.heading),
      timestamp: Value<int>(p.timestamp.millisecondsSinceEpoch),
      isPaused: Value<bool>(p.isPaused),
    );
  }

  TrackPoint _fromRow(TrackPointData row) {
    return TrackPoint(
      id: row.id,
      tripId: row.tripId,
      latitude: row.latitude,
      longitude: row.longitude,
      elevation: row.elevation,
      accuracy: row.accuracy,
      speed: row.speed,
      heading: row.heading,
      timestamp: DateTime.fromMillisecondsSinceEpoch(row.timestamp),
      isPaused: row.isPaused,
    );
  }
}

final Provider<TrackPointRepository> trackPointRepositoryProvider =
    Provider<TrackPointRepository>((Ref ref) {
  return TrackPointRepository(ref.watch(databaseProvider));
});
