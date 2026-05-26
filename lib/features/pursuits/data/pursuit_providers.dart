import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ten_k_hours/core/db/database_provider.dart';
import 'package:ten_k_hours/features/pursuits/data/pursuit_repository_impl.dart';
import 'package:ten_k_hours/features/pursuits/domain/pursuit.dart';
import 'package:ten_k_hours/features/pursuits/domain/pursuit_repository.dart';

part 'pursuit_providers.g.dart';

@Riverpod(keepAlive: true)
PursuitRepository pursuitRepository(Ref ref) {
  return DriftPursuitRepository(ref.watch(appDatabaseProvider));
}

@riverpod
Stream<List<Pursuit>> pursuitList(Ref ref) {
  return ref.watch(pursuitRepositoryProvider).watchAll();
}

@riverpod
Future<Pursuit?> pursuitById(Ref ref, int id) {
  return ref.watch(pursuitRepositoryProvider).getById(id);
}
