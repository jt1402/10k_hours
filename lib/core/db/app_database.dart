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
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ten_k_hours.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
