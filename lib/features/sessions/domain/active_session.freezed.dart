// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'active_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ActiveSession {

 int get pursuitId; DateTime get startedAt; Duration get pausedTotal; DateTime? get pauseStartedAt;
/// Create a copy of ActiveSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActiveSessionCopyWith<ActiveSession> get copyWith => _$ActiveSessionCopyWithImpl<ActiveSession>(this as ActiveSession, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActiveSession&&(identical(other.pursuitId, pursuitId) || other.pursuitId == pursuitId)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.pausedTotal, pausedTotal) || other.pausedTotal == pausedTotal)&&(identical(other.pauseStartedAt, pauseStartedAt) || other.pauseStartedAt == pauseStartedAt));
}


@override
int get hashCode => Object.hash(runtimeType,pursuitId,startedAt,pausedTotal,pauseStartedAt);

@override
String toString() {
  return 'ActiveSession(pursuitId: $pursuitId, startedAt: $startedAt, pausedTotal: $pausedTotal, pauseStartedAt: $pauseStartedAt)';
}


}

/// @nodoc
abstract mixin class $ActiveSessionCopyWith<$Res>  {
  factory $ActiveSessionCopyWith(ActiveSession value, $Res Function(ActiveSession) _then) = _$ActiveSessionCopyWithImpl;
@useResult
$Res call({
 int pursuitId, DateTime startedAt, Duration pausedTotal, DateTime? pauseStartedAt
});




}
/// @nodoc
class _$ActiveSessionCopyWithImpl<$Res>
    implements $ActiveSessionCopyWith<$Res> {
  _$ActiveSessionCopyWithImpl(this._self, this._then);

  final ActiveSession _self;
  final $Res Function(ActiveSession) _then;

/// Create a copy of ActiveSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pursuitId = null,Object? startedAt = null,Object? pausedTotal = null,Object? pauseStartedAt = freezed,}) {
  return _then(_self.copyWith(
pursuitId: null == pursuitId ? _self.pursuitId : pursuitId // ignore: cast_nullable_to_non_nullable
as int,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,pausedTotal: null == pausedTotal ? _self.pausedTotal : pausedTotal // ignore: cast_nullable_to_non_nullable
as Duration,pauseStartedAt: freezed == pauseStartedAt ? _self.pauseStartedAt : pauseStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ActiveSession].
extension ActiveSessionPatterns on ActiveSession {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActiveSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActiveSession() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActiveSession value)  $default,){
final _that = this;
switch (_that) {
case _ActiveSession():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActiveSession value)?  $default,){
final _that = this;
switch (_that) {
case _ActiveSession() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int pursuitId,  DateTime startedAt,  Duration pausedTotal,  DateTime? pauseStartedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActiveSession() when $default != null:
return $default(_that.pursuitId,_that.startedAt,_that.pausedTotal,_that.pauseStartedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int pursuitId,  DateTime startedAt,  Duration pausedTotal,  DateTime? pauseStartedAt)  $default,) {final _that = this;
switch (_that) {
case _ActiveSession():
return $default(_that.pursuitId,_that.startedAt,_that.pausedTotal,_that.pauseStartedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int pursuitId,  DateTime startedAt,  Duration pausedTotal,  DateTime? pauseStartedAt)?  $default,) {final _that = this;
switch (_that) {
case _ActiveSession() when $default != null:
return $default(_that.pursuitId,_that.startedAt,_that.pausedTotal,_that.pauseStartedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ActiveSession extends ActiveSession {
  const _ActiveSession({required this.pursuitId, required this.startedAt, this.pausedTotal = Duration.zero, this.pauseStartedAt}): super._();
  

@override final  int pursuitId;
@override final  DateTime startedAt;
@override@JsonKey() final  Duration pausedTotal;
@override final  DateTime? pauseStartedAt;

/// Create a copy of ActiveSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActiveSessionCopyWith<_ActiveSession> get copyWith => __$ActiveSessionCopyWithImpl<_ActiveSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActiveSession&&(identical(other.pursuitId, pursuitId) || other.pursuitId == pursuitId)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.pausedTotal, pausedTotal) || other.pausedTotal == pausedTotal)&&(identical(other.pauseStartedAt, pauseStartedAt) || other.pauseStartedAt == pauseStartedAt));
}


@override
int get hashCode => Object.hash(runtimeType,pursuitId,startedAt,pausedTotal,pauseStartedAt);

@override
String toString() {
  return 'ActiveSession(pursuitId: $pursuitId, startedAt: $startedAt, pausedTotal: $pausedTotal, pauseStartedAt: $pauseStartedAt)';
}


}

/// @nodoc
abstract mixin class _$ActiveSessionCopyWith<$Res> implements $ActiveSessionCopyWith<$Res> {
  factory _$ActiveSessionCopyWith(_ActiveSession value, $Res Function(_ActiveSession) _then) = __$ActiveSessionCopyWithImpl;
@override @useResult
$Res call({
 int pursuitId, DateTime startedAt, Duration pausedTotal, DateTime? pauseStartedAt
});




}
/// @nodoc
class __$ActiveSessionCopyWithImpl<$Res>
    implements _$ActiveSessionCopyWith<$Res> {
  __$ActiveSessionCopyWithImpl(this._self, this._then);

  final _ActiveSession _self;
  final $Res Function(_ActiveSession) _then;

/// Create a copy of ActiveSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pursuitId = null,Object? startedAt = null,Object? pausedTotal = null,Object? pauseStartedAt = freezed,}) {
  return _then(_ActiveSession(
pursuitId: null == pursuitId ? _self.pursuitId : pursuitId // ignore: cast_nullable_to_non_nullable
as int,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,pausedTotal: null == pausedTotal ? _self.pausedTotal : pausedTotal // ignore: cast_nullable_to_non_nullable
as Duration,pauseStartedAt: freezed == pauseStartedAt ? _self.pauseStartedAt : pauseStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
