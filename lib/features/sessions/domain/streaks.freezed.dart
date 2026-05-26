// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streaks.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Streaks {

 int get currentDays; int get longestDays;
/// Create a copy of Streaks
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreaksCopyWith<Streaks> get copyWith => _$StreaksCopyWithImpl<Streaks>(this as Streaks, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Streaks&&(identical(other.currentDays, currentDays) || other.currentDays == currentDays)&&(identical(other.longestDays, longestDays) || other.longestDays == longestDays));
}


@override
int get hashCode => Object.hash(runtimeType,currentDays,longestDays);

@override
String toString() {
  return 'Streaks(currentDays: $currentDays, longestDays: $longestDays)';
}


}

/// @nodoc
abstract mixin class $StreaksCopyWith<$Res>  {
  factory $StreaksCopyWith(Streaks value, $Res Function(Streaks) _then) = _$StreaksCopyWithImpl;
@useResult
$Res call({
 int currentDays, int longestDays
});




}
/// @nodoc
class _$StreaksCopyWithImpl<$Res>
    implements $StreaksCopyWith<$Res> {
  _$StreaksCopyWithImpl(this._self, this._then);

  final Streaks _self;
  final $Res Function(Streaks) _then;

/// Create a copy of Streaks
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentDays = null,Object? longestDays = null,}) {
  return _then(_self.copyWith(
currentDays: null == currentDays ? _self.currentDays : currentDays // ignore: cast_nullable_to_non_nullable
as int,longestDays: null == longestDays ? _self.longestDays : longestDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Streaks].
extension StreaksPatterns on Streaks {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Streaks value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Streaks() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Streaks value)  $default,){
final _that = this;
switch (_that) {
case _Streaks():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Streaks value)?  $default,){
final _that = this;
switch (_that) {
case _Streaks() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentDays,  int longestDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Streaks() when $default != null:
return $default(_that.currentDays,_that.longestDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentDays,  int longestDays)  $default,) {final _that = this;
switch (_that) {
case _Streaks():
return $default(_that.currentDays,_that.longestDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentDays,  int longestDays)?  $default,) {final _that = this;
switch (_that) {
case _Streaks() when $default != null:
return $default(_that.currentDays,_that.longestDays);case _:
  return null;

}
}

}

/// @nodoc


class _Streaks implements Streaks {
  const _Streaks({required this.currentDays, required this.longestDays});
  

@override final  int currentDays;
@override final  int longestDays;

/// Create a copy of Streaks
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreaksCopyWith<_Streaks> get copyWith => __$StreaksCopyWithImpl<_Streaks>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Streaks&&(identical(other.currentDays, currentDays) || other.currentDays == currentDays)&&(identical(other.longestDays, longestDays) || other.longestDays == longestDays));
}


@override
int get hashCode => Object.hash(runtimeType,currentDays,longestDays);

@override
String toString() {
  return 'Streaks(currentDays: $currentDays, longestDays: $longestDays)';
}


}

/// @nodoc
abstract mixin class _$StreaksCopyWith<$Res> implements $StreaksCopyWith<$Res> {
  factory _$StreaksCopyWith(_Streaks value, $Res Function(_Streaks) _then) = __$StreaksCopyWithImpl;
@override @useResult
$Res call({
 int currentDays, int longestDays
});




}
/// @nodoc
class __$StreaksCopyWithImpl<$Res>
    implements _$StreaksCopyWith<$Res> {
  __$StreaksCopyWithImpl(this._self, this._then);

  final _Streaks _self;
  final $Res Function(_Streaks) _then;

/// Create a copy of Streaks
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentDays = null,Object? longestDays = null,}) {
  return _then(_Streaks(
currentDays: null == currentDays ? _self.currentDays : currentDays // ignore: cast_nullable_to_non_nullable
as int,longestDays: null == longestDays ? _self.longestDays : longestDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
