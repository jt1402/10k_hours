import 'package:drift/drift.dart';

@DataClassName('PursuitRow')
class Pursuits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get accentColor => integer()();
  // Stored as minutes to support sub-hour targets. Default = 10,000 hours.
  IntColumn get targetMinutes =>
      integer().withDefault(const Constant(600000))();
  DateTimeColumn get createdAt => dateTime()();
}
