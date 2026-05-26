import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';

@freezed
abstract class Session with _$Session {
  const factory Session({
    required int id,
    required int pursuitId,
    required DateTime startedAt,
    required DateTime endedAt,
    required Duration duration,
  }) = _Session;
}
