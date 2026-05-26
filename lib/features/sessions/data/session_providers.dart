import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ten_k_hours/core/db/database_provider.dart';
import 'package:ten_k_hours/features/sessions/data/session_repository_impl.dart';
import 'package:ten_k_hours/features/sessions/domain/active_session.dart';
import 'package:ten_k_hours/features/sessions/domain/session_repository.dart';
import 'package:ten_k_hours/features/sessions/domain/session_service.dart';

part 'session_providers.g.dart';

@Riverpod(keepAlive: true)
SessionRepository sessionRepository(Ref ref) {
  return DriftSessionRepository(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
SessionService sessionService(Ref ref) {
  return SessionService(repo: ref.watch(sessionRepositoryProvider));
}

@riverpod
Stream<ActiveSession?> activeSession(Ref ref) {
  return ref.watch(sessionRepositoryProvider).watchActive();
}

@riverpod
Stream<Duration> totalCountedDuration(Ref ref, int pursuitId) async* {
  final repo = ref.watch(sessionRepositoryProvider);
  await for (final sessions in repo.watchForStats(pursuitId)) {
    yield sessions.fold<Duration>(
      Duration.zero,
      (acc, s) => acc + s.duration,
    );
  }
}
