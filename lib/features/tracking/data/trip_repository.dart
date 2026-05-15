import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../../../data/local/tables.dart';
import '../domain/trip.dart';

/// Repository untuk Trip — wrapper di atas Drift database.
class TripRepository {
  TripRepository(this._db);

  final HikeIdDatabase _db;

  Future<void> insert(Trip trip) async {
    await _db.into(_db.trips).insert(_toCompanion(trip));
  }

  Future<void> update(Trip trip) async {
    await (_db.update(_db.trips)..where(($TripsTable t) => t.id.equals(trip.id)))
        .write(_toCompanion(trip));
  }

  Future<void> delete(String tripId) async {
    await (_db.delete(_db.trips)..where(($TripsTable t) => t.id.equals(tripId))).go();
  }

  Future<Trip?> findById(String id) async {
    final TripData? row = await (_db.select(_db.trips)
          ..where(($TripsTable t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  /// Stream semua trip non-discarded, terurut terbaru dulu.
  Stream<List<Trip>> watchAll({int? limit}) {
    final SimpleSelectStatement<$TripsTable, TripData> q = _db.select(_db.trips)
      ..where(($TripsTable t) => t.status.isNotValue(TripStatus.discarded.name))
      ..orderBy(<OrderClauseGenerator<$TripsTable>>[
        ($TripsTable t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc),
      ]);
    if (limit != null) q.limit(limit);
    return q.watch().map((List<TripData> rows) => rows.map(_fromRow).toList());
  }

  /// Trip yang masih aktif/paused (untuk crash recovery — PRD US-TRK-05).
  Future<Trip?> findActiveOrPaused() async {
    final TripData? row = await (_db.select(_db.trips)
          ..where(($TripsTable t) =>
              t.status.equals(TripStatus.active.name) |
              t.status.equals(TripStatus.paused.name))
          ..orderBy(<OrderClauseGenerator<$TripsTable>>[
            ($TripsTable t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  TripsCompanion _toCompanion(Trip trip) {
    return TripsCompanion(
      id: Value<String>(trip.id),
      name: Value<String>(trip.name),
      mountainName: Value<String?>(trip.mountainName),
      difficulty: Value<int?>(trip.difficulty),
      coverPhotoUri: Value<String?>(trip.coverPhotoUri),
      startedAt: Value<int>(trip.startedAt.millisecondsSinceEpoch),
      endedAt: Value<int?>(trip.endedAt?.millisecondsSinceEpoch),
      totalDistance: Value<double>(trip.totalDistance),
      totalDuration: Value<int>(trip.totalDuration.inSeconds),
      elevationGain: Value<double>(trip.elevationGain),
      elevationLoss: Value<double>(trip.elevationLoss),
      maxElevation: Value<double?>(trip.maxElevation),
      minElevation: Value<double?>(trip.minElevation),
      avgSpeed: Value<double>(trip.avgSpeed),
      maxSpeed: Value<double>(trip.maxSpeed),
      status: Value<String>(trip.status.name),
      trackingMode: Value<String>(trip.trackingMode.name),
      source: Value<String>(trip.source.name),
      createdAt: Value<int>(trip.createdAt.millisecondsSinceEpoch),
      updatedAt: Value<int>(trip.updatedAt.millisecondsSinceEpoch),
    );
  }

  Trip _fromRow(TripData row) {
    return Trip(
      id: row.id,
      name: row.name,
      mountainName: row.mountainName,
      difficulty: row.difficulty,
      coverPhotoUri: row.coverPhotoUri,
      startedAt: DateTime.fromMillisecondsSinceEpoch(row.startedAt),
      endedAt: row.endedAt == null ? null : DateTime.fromMillisecondsSinceEpoch(row.endedAt!),
      totalDistance: row.totalDistance,
      totalDuration: Duration(seconds: row.totalDuration),
      elevationGain: row.elevationGain,
      elevationLoss: row.elevationLoss,
      maxElevation: row.maxElevation,
      minElevation: row.minElevation,
      avgSpeed: row.avgSpeed,
      maxSpeed: row.maxSpeed,
      status: TripStatus.fromName(row.status),
      trackingMode: TrackingMode.fromName(row.trackingMode),
      source: TripSource.fromName(row.source),
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
    );
  }
}

final Provider<TripRepository> tripRepositoryProvider = Provider<TripRepository>((Ref ref) {
  return TripRepository(ref.watch(databaseProvider));
});
