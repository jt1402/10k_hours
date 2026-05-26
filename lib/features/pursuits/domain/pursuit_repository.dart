import 'package:ten_k_hours/features/pursuits/domain/pursuit.dart';

abstract class PursuitRepository {
  Future<Pursuit> create({
    required String name,
    required int accentColor,
    int targetHours,
  });

  Future<Pursuit?> getById(int id);

  Stream<List<Pursuit>> watchAll();
}
