import 'package:drift/drift.dart';
import 'package:ten_k_hours/core/db/tables/pursuits.dart';

@DataClassName('ActiveSessionRow')
class ActiveSession extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get pursuitId => integer().references(
        Pursuits,
        #id,
        onDelete: KeyAction.cascade,
      )();
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get pausedTotalMs =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get pauseStartedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const ['CHECK (id = 1)'];
}
