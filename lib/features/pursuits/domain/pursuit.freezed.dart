// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pursuit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Pursuit {

 int get id; String get name; int get accentColor; int get targetMinutes; DateTime get createdAt;
/// Create a copy of Pursuit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PursuitCopyWith<Pursuit> get copyWith => _$PursuitCopyWithImpl<Pursuit>(this as Pursuit, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pursuit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.targetMinutes, targetMinutes) || other.targetMinutes == targetMinutes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,accentColor,targetMinutes,createdAt);

@override
String toString() {
  return 'Pursuit(id: $id, name: $name, accentColor: $accentColor, targetMinutes: $targetMinutes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PursuitCopyWith<$Res>  {
  factory $PursuitCopyWith(Pursuit value, $Res Function(Pursuit) _then) = _$PursuitCopyWithImpl;
@useResult
$Res call({
 int id, String name, int accentColor, int targetMinutes, DateTime createdAt
});




}
/// @nodoc
class _$PursuitCopyWithImpl<$Res>
    implements $PursuitCopyWith<$Res> {
  _$PursuitCopyWithImpl(this._self, this._then);

  final Pursuit _self;
  final $Res Function(Pursuit) _then;

/// Create a copy of Pursuit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? accentColor = null,Object? targetMinutes = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,accentColor: null == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as int,targetMinutes: null == targetMinutes ? _self.targetMinutes : targetMinutes // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Pursuit].
extension PursuitPatterns on Pursuit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Pursuit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Pursuit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Pursuit value)  $default,){
final _that = this;
switch (_that) {
case _Pursuit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Pursuit value)?  $default,){
final _that = this;
switch (_that) {
case _Pursuit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  int accentColor,  int targetMinutes,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Pursuit() when $default != null:
return $default(_that.id,_that.name,_that.accentColor,_that.targetMinutes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  int accentColor,  int targetMinutes,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Pursuit():
return $default(_that.id,_that.name,_that.accentColor,_that.targetMinutes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  int accentColor,  int targetMinutes,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Pursuit() when $default != null:
return $default(_that.id,_that.name,_that.accentColor,_that.targetMinutes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _Pursuit implements Pursuit {
  const _Pursuit({required this.id, required this.name, required this.accentColor, required this.targetMinutes, required this.createdAt});
  

@override final  int id;
@override final  String name;
@override final  int accentColor;
@override final  int targetMinutes;
@override final  DateTime createdAt;

/// Create a copy of Pursuit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PursuitCopyWith<_Pursuit> get copyWith => __$PursuitCopyWithImpl<_Pursuit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pursuit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.targetMinutes, targetMinutes) || other.targetMinutes == targetMinutes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,accentColor,targetMinutes,createdAt);

@override
String toString() {
  return 'Pursuit(id: $id, name: $name, accentColor: $accentColor, targetMinutes: $targetMinutes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PursuitCopyWith<$Res> implements $PursuitCopyWith<$Res> {
  factory _$PursuitCopyWith(_Pursuit value, $Res Function(_Pursuit) _then) = __$PursuitCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int accentColor, int targetMinutes, DateTime createdAt
});




}
/// @nodoc
class __$PursuitCopyWithImpl<$Res>
    implements _$PursuitCopyWith<$Res> {
  __$PursuitCopyWithImpl(this._self, this._then);

  final _Pursuit _self;
  final $Res Function(_Pursuit) _then;

/// Create a copy of Pursuit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? accentColor = null,Object? targetMinutes = null,Object? createdAt = null,}) {
  return _then(_Pursuit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,accentColor: null == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as int,targetMinutes: null == targetMinutes ? _self.targetMinutes : targetMinutes // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
