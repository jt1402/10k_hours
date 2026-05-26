import 'package:freezed_annotation/freezed_annotation.dart';

part 'pursuit.freezed.dart';

@freezed
abstract class Pursuit with _$Pursuit {
  const factory Pursuit({
    required int id,
    required String name,
    required int accentColor,
    required int targetMinutes,
    required DateTime createdAt,
  }) = _Pursuit;
}
