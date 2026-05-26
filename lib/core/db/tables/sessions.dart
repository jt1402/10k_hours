import 'package:drift/drift.dart';
import 'package:ten_k_hours/core/db/tables/pursuits.dart';

@DataClassName('SessionRow')
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pursuitId => integer().references(
        Pursuits,
        #id,
        onDelete: KeyAction.cascade,
      )();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime()();
  IntColumn get durationMs => integer()();
}
