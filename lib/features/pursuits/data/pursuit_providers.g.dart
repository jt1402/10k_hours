// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pursuit_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pursuitRepository)
final pursuitRepositoryProvider = PursuitRepositoryProvider._();

final class PursuitRepositoryProvider
    extends
        $FunctionalProvider<
          PursuitRepository,
          PursuitRepository,
          PursuitRepository
        >
    with $Provider<PursuitRepository> {
  PursuitRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pursuitRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pursuitRepositoryHash();

  @$internal
  @override
  $ProviderElement<PursuitRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PursuitRepository create(Ref ref) {
    return pursuitRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PursuitRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PursuitRepository>(value),
    );
  }
}

String _$pursuitRepositoryHash() => r'34f835ed14a0b0ec476be1080442c3f4cc607143';

@ProviderFor(pursuitList)
final pursuitListProvider = PursuitListProvider._();

final class PursuitListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Pursuit>>,
          List<Pursuit>,
          Stream<List<Pursuit>>
        >
    with $FutureModifier<List<Pursuit>>, $StreamProvider<List<Pursuit>> {
  PursuitListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pursuitListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pursuitListHash();

  @$internal
  @override
  $StreamProviderElement<List<Pursuit>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Pursuit>> create(Ref ref) {
    return pursuitList(ref);
  }
}

String _$pursuitListHash() => r'a726cdca37c49ab392bb0acda457ad9b82fe9850';

@ProviderFor(pursuitById)
final pursuitByIdProvider = PursuitByIdFamily._();

final class PursuitByIdProvider
    extends
        $FunctionalProvider<AsyncValue<Pursuit?>, Pursuit?, FutureOr<Pursuit?>>
    with $FutureModifier<Pursuit?>, $FutureProvider<Pursuit?> {
  PursuitByIdProvider._({
    required PursuitByIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'pursuitByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pursuitByIdHash();

  @override
  String toString() {
    return r'pursuitByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Pursuit?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Pursuit?> create(Ref ref) {
    final argument = this.argument as int;
    return pursuitById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PursuitByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pursuitByIdHash() => r'15cf88d9ccc5688a3ca550991ae7c4b9f0109cb4';

final class PursuitByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Pursuit?>, int> {
  PursuitByIdFamily._()
    : super(
        retry: null,
        name: r'pursuitByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PursuitByIdProvider call(int id) =>
      PursuitByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'pursuitByIdProvider';
}
