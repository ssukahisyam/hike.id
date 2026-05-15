import 'package:drift/drift.dart';

/// Drift table definitions sesuai PRD §5 — Data Model.
///
/// File besar (foto, voice) disimpan di file storage; di tabel hanya path.

class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get mountainName => text().nullable()();
  IntColumn get difficulty => integer().nullable()();
  TextColumn get coverPhotoUri => text().nullable()();
  IntColumn get startedAt => integer()(); // epoch ms
  IntColumn get endedAt => integer().nullable()();
  RealColumn get totalDistance => real().withDefault(const Constant<double>(0))();
  IntColumn get totalDuration => integer().withDefault(const Constant<int>(0))(); // detik
  RealColumn get elevationGain => real().withDefault(const Constant<double>(0))();
  RealColumn get elevationLoss => real().withDefault(const Constant<double>(0))();
  RealColumn get maxElevation => real().nullable()();
  RealColumn get minElevation => real().nullable()();
  RealColumn get avgSpeed => real().withDefault(const Constant<double>(0))();
  RealColumn get maxSpeed => real().withDefault(const Constant<double>(0))();
  TextColumn get status => text()();
  TextColumn get trackingMode => text()();
  TextColumn get source => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class TrackPoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tripId => text().references(Trips, #id, onDelete: KeyAction.cascade)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get elevation => real().nullable()();
  RealColumn get accuracy => real().nullable()();
  RealColumn get speed => real().nullable()();
  RealColumn get heading => real().nullable()();
  IntColumn get timestamp => integer()(); // epoch ms
  BoolColumn get isPaused => boolean().withDefault(const Constant<bool>(false))();
}

class Checkpoints extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text().nullable().references(Trips, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get elevation => real().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get tripId =>
      text().nullable().references(Trips, #id, onDelete: KeyAction.cascade)();
  TextColumn get checkpointId =>
      text().nullable().references(Checkpoints, #id, onDelete: KeyAction.setNull)();
  TextColumn get type => text()();
  TextColumn get content => text().nullable()();
  TextColumn get filePath => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class EmergencyContacts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get relation => text().nullable()();
  IntColumn get priority => integer().withDefault(const Constant<int>(1))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class SosLogs extends Table {
  TextColumn get id => text()();
  IntColumn get openedAt => integer()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get accuracy => real().nullable()();
  TextColumn get action => text()();
  TextColumn get shareVia => text().nullable()();
  TextColumn get tripId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class AppSettingsTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  String? get tableName => 'app_settings';

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}
