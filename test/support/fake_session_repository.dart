import 'dart:async';

import 'package:ten_k_hours/features/sessions/domain/active_session.dart';
import 'package:ten_k_hours/features/sessions/domain/session.dart';
import 'package:ten_k_hours/features/sessions/domain/session_repository.dart';

class FakeSessionRepository implements SessionRepository {
  FakeSessionRepository();

  ActiveSession? _active;
  final List<Session> _sessions = [];
  final StreamController<ActiveSession?> _activeController =
      StreamController<ActiveSession?>.broadcast();
  int _nextSessionId = 1;

  List<Session> get inserted => List.unmodifiable(_sessions);

  @override
  Future<ActiveSession?> getActive() async => _active;

  @override
  Stream<ActiveSession?> watchActive() => _activeController.stream;

  @override
  Future<void> setActive(ActiveSession active) async {
    _active = active;
    _activeController.add(active);
  }

  @override
  Future<void> clearActive() async {
    _active = null;
    _activeController.add(null);
  }

  @override
  Future<Session> insertCompleted({
    required int pursuitId,
    required DateTime startedAt,
    required DateTime endedAt,
    required Duration duration,
  }) async {
    final session = Session(
      id: _nextSessionId++,
      pursuitId: pursuitId,
      startedAt: startedAt,
      endedAt: endedAt,
      duration: duration,
    );
    _sessions.add(session);
    return session;
  }

  @override
  Stream<List<Session>> watchAll(int pursuitId) async* {
    yield _sessions.where((s) => s.pursuitId == pursuitId).toList();
  }

  @override
  Stream<List<Session>> watchForStats(int pursuitId) async* {
    yield _sessions
        .where(
          (s) =>
              s.pursuitId == pursuitId &&
              s.duration >= const Duration(seconds: 60),
        )
        .toList();
  }

  @override
  Future<Duration> totalCountedDurationFor(int pursuitId) async {
    return _sessions
        .where(
          (s) =>
              s.pursuitId == pursuitId &&
              s.duration >= const Duration(seconds: 60),
        )
        .fold<Duration>(Duration.zero, (acc, s) => acc + s.duration);
  }
}
