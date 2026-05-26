import 'package:drift/drift.dart';
import 'package:ten_k_hours/core/constants.dart';
import 'package:ten_k_hours/core/db/app_database.dart';
import 'package:ten_k_hours/features/pursuits/domain/pursuit.dart';
import 'package:ten_k_hours/features/pursuits/domain/pursuit_repository.dart';

class DriftPursuitRepository implements PursuitRepository {
  DriftPursuitRepository(this._db);

  final AppDatabase _db;

  @override
  Future<Pursuit> create({
    required String name,
    required int accentColor,
    int targetHours = kDefaultTargetHours,
  }) async {
    final row = await _db.into(_db.pursuits).insertReturning(
          PursuitsCompanion.insert(
            name: name,
            accentColor: accentColor,
            targetHours: Value(targetHours),
            createdAt: DateTime.now().toUtc(),
          ),
        );
    return _toDomain(row);
  }

  @override
  Future<Pursuit?> getById(int id) async {
    final row = await (_db.select(_db.pursuits)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Stream<List<Pursuit>> watchAll() {
    final query = _db.select(_db.pursuits)
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Pursuit _toDomain(PursuitRow row) => Pursuit(
        id: row.id,
        name: row.name,
        accentColor: row.accentColor,
        targetHours: row.targetHours,
        createdAt: row.createdAt.toUtc(),
      );
}
