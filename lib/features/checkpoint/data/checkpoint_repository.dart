import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../domain/checkpoint.dart';

class CheckpointRepository {
  CheckpointRepository(this._db);

  final HikeIdDatabase _db;

  Future<void> insert(Checkpoint c) async {
    await _db.into(_db.checkpoints).insert(_toCompanion(c));
  }

  Future<void> update(Checkpoint c) async {
    await (_db.update(_db.checkpoints)..where(($CheckpointsTable t) => t.id.equals(c.id)))
        .write(_toCompanion(c));
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.checkpoints)..where(($CheckpointsTable t) => t.id.equals(id))).go();
  }

  Future<List<Checkpoint>> findByTripId(String tripId) async {
    final List<CheckpointRow> rows = await (_db.select(_db.checkpoints)
          ..where(($CheckpointsTable t) => t.tripId.equals(tripId))
          ..orderBy(<OrderClauseGenerator<$CheckpointsTable>>[
            ($CheckpointsTable t) => OrderingTerm(expression: t.createdAt),
          ]))
        .get();
    return rows.map(_fromRow).toList();
  }

  Stream<List<Checkpoint>> watchByTripId(String tripId) {
    return (_db.select(_db.checkpoints)
          ..where(($CheckpointsTable t) => t.tripId.equals(tripId))
          ..orderBy(<OrderClauseGenerator<$CheckpointsTable>>[
            ($CheckpointsTable t) => OrderingTerm(expression: t.createdAt),
          ]))
        .watch()
        .map((List<CheckpointRow> rows) => rows.map(_fromRow).toList());
  }

  Future<int> countByTripId(String tripId) async {
    final Expression<int> total = _db.checkpoints.id.count();
    final List<TypedResult> rows = await (_db.selectOnly(_db.checkpoints)
          ..addColumns(<Expression<Object>>[total])
          ..where(_db.checkpoints.tripId.equals(tripId)))
        .get();
    return rows.first.read(total) ?? 0;
  }

  CheckpointsCompanion _toCompanion(Checkpoint c) {
    return CheckpointsCompanion(
      id: Value<String>(c.id),
      tripId: Value<String?>(c.tripId),
      type: Value<String>(c.type.name),
      name: Value<String>(c.name),
      description: Value<String?>(c.description),
      latitude: Value<double>(c.latitude),
      longitude: Value<double>(c.longitude),
      elevation: Value<double?>(c.elevation),
      createdAt: Value<int>(c.createdAt.millisecondsSinceEpoch),
    );
  }

  Checkpoint _fromRow(CheckpointRow row) {
    return Checkpoint(
      id: row.id,
      tripId: row.tripId,
      type: CheckpointType.fromName(row.type),
      name: row.name,
      description: row.description,
      latitude: row.latitude,
      longitude: row.longitude,
      elevation: row.elevation,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    );
  }
}

final Provider<CheckpointRepository> checkpointRepositoryProvider =
    Provider<CheckpointRepository>((Ref ref) {
  return CheckpointRepository(ref.watch(databaseProvider));
});
