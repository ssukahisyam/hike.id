import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../../../data/local/tables.dart';
import '../domain/emergency_contact.dart';

class EmergencyContactRepository {
  EmergencyContactRepository(this._db);

  final HikeIdDatabase _db;

  Future<void> insert(EmergencyContact c) async {
    await _db.into(_db.emergencyContacts).insert(_toCompanion(c));
  }

  Future<void> update(EmergencyContact c) async {
    await (_db.update(_db.emergencyContacts)
          ..where(($EmergencyContactsTable t) => t.id.equals(c.id)))
        .write(_toCompanion(c));
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.emergencyContacts)
          ..where(($EmergencyContactsTable t) => t.id.equals(id)))
        .go();
  }

  Stream<List<EmergencyContact>> watchAll() {
    return (_db.select(_db.emergencyContacts)
          ..orderBy(<OrderClauseGenerator<$EmergencyContactsTable>>[
            ($EmergencyContactsTable t) => OrderingTerm(expression: t.priority),
            ($EmergencyContactsTable t) => OrderingTerm(expression: t.createdAt),
          ]))
        .watch()
        .map((List<EmergencyContactData> rows) => rows.map(_fromRow).toList());
  }

  Future<List<EmergencyContact>> findAll() async {
    final List<EmergencyContactData> rows = await (_db.select(_db.emergencyContacts)
          ..orderBy(<OrderClauseGenerator<$EmergencyContactsTable>>[
            ($EmergencyContactsTable t) => OrderingTerm(expression: t.priority),
          ]))
        .get();
    return rows.map(_fromRow).toList();
  }

  EmergencyContactsCompanion _toCompanion(EmergencyContact c) {
    return EmergencyContactsCompanion(
      id: Value<String>(c.id),
      name: Value<String>(c.name),
      phone: Value<String>(c.phone),
      relation: Value<String?>(c.relation),
      priority: Value<int>(c.priority),
      createdAt: Value<int>(c.createdAt.millisecondsSinceEpoch),
    );
  }

  EmergencyContact _fromRow(EmergencyContactData row) {
    return EmergencyContact(
      id: row.id,
      name: row.name,
      phone: row.phone,
      relation: row.relation,
      priority: row.priority,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    );
  }
}

final Provider<EmergencyContactRepository> emergencyContactRepositoryProvider =
    Provider<EmergencyContactRepository>((Ref ref) {
  return EmergencyContactRepository(ref.watch(databaseProvider));
});

/// Stream daftar kontak darurat — dipakai SOS screen.
final StreamProvider<List<EmergencyContact>> emergencyContactsProvider =
    StreamProvider<List<EmergencyContact>>((Ref ref) {
  return ref.watch(emergencyContactRepositoryProvider).watchAll();
});
