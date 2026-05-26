import 'package:freezed_annotation/freezed_annotation.dart';

part 'streaks.freezed.dart';

@freezed
abstract class Streaks with _$Streaks {
  const factory Streaks({
    required int currentDays,
    required int longestDays,
  }) = _Streaks;

  static const empty = Streaks(currentDays: 0, longestDays: 0);
}
