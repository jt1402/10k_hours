// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionRepository)
final sessionRepositoryProvider = SessionRepositoryProvider._();

final class SessionRepositoryProvider
    extends
        $FunctionalProvider<
          SessionRepository,
          SessionRepository,
          SessionRepository
        >
    with $Provider<SessionRepository> {
  SessionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionRepositoryHash();

  @$internal
  @override
  $ProviderElement<SessionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SessionRepository create(Ref ref) {
    return sessionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionRepository>(value),
    );
  }
}

String _$sessionRepositoryHash() => r'e7e8bcf924175eb205f0d2a9b3c038a60a3f1eca';

@ProviderFor(sessionService)
final sessionServiceProvider = SessionServiceProvider._();

final class SessionServiceProvider
    extends $FunctionalProvider<SessionService, SessionService, SessionService>
    with $Provider<SessionService> {
  SessionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionServiceHash();

  @$internal
  @override
  $ProviderElement<SessionService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionService create(Ref ref) {
    return sessionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionService>(value),
    );
  }
}

String _$sessionServiceHash() => r'6a6e5e3b5dd6f308fa6f8b994d0087d10e0e7b04';

@ProviderFor(activeSession)
final activeSessionProvider = ActiveSessionProvider._();

final class ActiveSessionProvider
    extends
        $FunctionalProvider<
          AsyncValue<ActiveSession?>,
          ActiveSession?,
          Stream<ActiveSession?>
        >
    with $FutureModifier<ActiveSession?>, $StreamProvider<ActiveSession?> {
  ActiveSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeSessionHash();

  @$internal
  @override
  $StreamProviderElement<ActiveSession?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ActiveSession?> create(Ref ref) {
    return activeSession(ref);
  }
}

String _$activeSessionHash() => r'44b5f6a2d24891f3ef5f73d6ad0e423e67c8e355';

@ProviderFor(totalCountedDuration)
final totalCountedDurationProvider = TotalCountedDurationFamily._();

final class TotalCountedDurationProvider
    extends
        $FunctionalProvider<AsyncValue<Duration>, Duration, Stream<Duration>>
    with $FutureModifier<Duration>, $StreamProvider<Duration> {
  TotalCountedDurationProvider._({
    required TotalCountedDurationFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'totalCountedDurationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$totalCountedDurationHash();

  @override
  String toString() {
    return r'totalCountedDurationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Duration> create(Ref ref) {
    final argument = this.argument as int;
    return totalCountedDuration(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TotalCountedDurationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$totalCountedDurationHash() =>
    r'e02a937a8484fd8cd490fc6368fb8fe450dfcecb';

final class TotalCountedDurationFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Duration>, int> {
  TotalCountedDurationFamily._()
    : super(
        retry: null,
        name: r'totalCountedDurationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TotalCountedDurationProvider call(int pursuitId) =>
      TotalCountedDurationProvider._(argument: pursuitId, from: this);

  @override
  String toString() => r'totalCountedDurationProvider';
}
