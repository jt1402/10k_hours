import 'package:ten_k_hours/features/pursuits/domain/pursuit.dart';

abstract class PursuitRepository {
  Future<Pursuit> create({
    required String name,
    required int accentColor,
    int targetMinutes,
  });

  Future<Pursuit?> getById(int id);

  Stream<List<Pursuit>> watchAll();

  Future<void> delete(int id);

  Future<void> markCompleted(int id, DateTime at);
}
