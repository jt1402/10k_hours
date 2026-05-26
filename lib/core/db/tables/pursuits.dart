import 'package:drift/drift.dart';

@DataClassName('PursuitRow')
class Pursuits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get accentColor => integer()();
  IntColumn get targetHours => integer().withDefault(const Constant(10000))();
  DateTimeColumn get createdAt => dateTime()();
}
