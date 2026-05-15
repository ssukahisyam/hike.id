import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables.dart';

part 'database.g.dart';

/// Drift database — Phase 2 dari PLANNING_HIKEID.md.
///
/// Migration framework di-include sejak v1 supaya schema bisa berkembang
/// tanpa kehilangan data user (PLANNING §7 Phase 2 acceptance criteria).
@DriftDatabase(
  tables: <Type>[
    Trips,
    TrackPoints,
    Checkpoints,
    Notes,
    EmergencyContacts,
    SosLogs,
    AppSettingsTable,
  ],
)
class HikeIdDatabase extends _$HikeIdDatabase {
  HikeIdDatabase() : super(_open());

  HikeIdDatabase.executor(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          // Slot ini untuk migration di versi mendatang.
        },
      );
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File(p.join(dir.path, 'hike_id.sqlite'));
    return NativeDatabase.createInBackground(file, logStatements: false);
  });
}

/// Provider sentral untuk akses database. Override-able di test.
final Provider<HikeIdDatabase> databaseProvider = Provider<HikeIdDatabase>((Ref ref) {
  final HikeIdDatabase db = HikeIdDatabase();
  ref.onDispose(db.close);
  return db;
});
