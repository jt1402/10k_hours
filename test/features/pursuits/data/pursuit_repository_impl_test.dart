import 'package:flutter_test/flutter_test.dart';
import 'package:ten_k_hours/core/db/app_database.dart';
import 'package:ten_k_hours/features/pursuits/data/pursuit_repository_impl.dart';

void main() {
  late AppDatabase db;
  late DriftPursuitRepository repo;

  setUp(() {
    db = AppDatabase.memory();
    repo = DriftPursuitRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('create then getById round-trips', () async {
    final created = await repo.create(name: 'Guitar', accentColor: 0xFF14B8A6);
    final fetched = await repo.getById(created.id);
    expect(fetched, isNotNull);
    expect(fetched!.name, 'Guitar');
    expect(fetched.accentColor, 0xFF14B8A6);
    expect(fetched.targetHours, 10000);
  });

  test('targetHours can be overridden', () async {
    final created = await repo.create(
      name: 'Sprint',
      accentColor: 0xFF000000,
      targetHours: 500,
    );
    expect(created.targetHours, 500);
  });

  test('getById returns null for missing pursuit', () async {
    expect(await repo.getById(999), isNull);
  });

  test('watchAll emits updates as pursuits are added', () async {
    final stream = repo.watchAll();
    final emissions = <List<int>>[];
    final sub = stream.listen(
      (p) => emissions.add(p.map((e) => e.id).toList()),
    );

    await Future<void>.delayed(Duration.zero);
    await repo.create(name: 'A', accentColor: 0);
    await repo.create(name: 'B', accentColor: 0);
    await Future<void>.delayed(Duration.zero);

    expect(emissions.last, hasLength(2));
    await sub.cancel();
  });
}
