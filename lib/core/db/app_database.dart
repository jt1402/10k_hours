import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:ten_k_hours/core/db/tables/active_session.dart';
import 'package:ten_k_hours/core/db/tables/pursuits.dart';
import 'package:ten_k_hours/core/db/tables/sessions.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Pursuits, Sessions, ActiveSession])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.fromExecutor(super.e);

  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // v1 stored target_hours (int). v2 stores target_minutes (int).
        // Rename the column in place and convert existing values *60.
        await customStatement(
          'ALTER TABLE pursuits RENAME COLUMN target_hours TO target_minutes',
        );
        await customStatement(
          'UPDATE pursuits SET target_minutes = target_minutes * 60',
        );
      }
      if (from < 3) {
        // v3: add completed_at, backfill for pursuits already past target
        // (using counted sessions >= 60s, mirroring totalCountedDurationFor).
        await m.addColumn(pursuits, pursuits.completedAt);
        await customStatement('''
          UPDATE pursuits
          SET completed_at = (
            SELECT MAX(s.ended_at)
            FROM sessions s
            WHERE s.pursuit_id = pursuits.id
              AND s.duration_ms >= 60000
          )
          WHERE (
            SELECT COALESCE(SUM(s.duration_ms), 0)
            FROM sessions s
            WHERE s.pursuit_id = pursuits.id
              AND s.duration_ms >= 60000
          ) >= (target_minutes * 60 * 1000)
        ''');
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ten_k_hours.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
