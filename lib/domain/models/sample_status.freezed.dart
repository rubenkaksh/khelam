// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sample_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SampleStatus {

 String get id; String get message; bool get isHealthy;
/// Create a copy of SampleStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SampleStatusCopyWith<SampleStatus> get copyWith => _$SampleStatusCopyWithImpl<SampleStatus>(this as SampleStatus, _$identity);

  /// Serializes this SampleStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SampleStatus&&(identical(other.id, id) || other.id == id)&&(identical(other.message, message) || other.message == message)&&(identical(other.isHealthy, isHealthy) || other.isHealthy == isHealthy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,message,isHealthy);

@override
String toString() {
  return 'SampleStatus(id: $id, message: $message, isHealthy: $isHealthy)';
}


}

/// @nodoc
abstract mixin class $SampleStatusCopyWith<$Res>  {
  factory $SampleStatusCopyWith(SampleStatus value, $Res Function(SampleStatus) _then) = _$SampleStatusCopyWithImpl;
@useResult
$Res call({
 String id, String message, bool isHealthy
});




}
/// @nodoc
class _$SampleStatusCopyWithImpl<$Res>
    implements $SampleStatusCopyWith<$Res> {
  _$SampleStatusCopyWithImpl(this._self, this._then);

  final SampleStatus _self;
  final $Res Function(SampleStatus) _then;

/// Create a copy of SampleStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? message = null,Object? isHealthy = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isHealthy: null == isHealthy ? _self.isHealthy : isHealthy // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SampleStatus].
extension SampleStatusPatterns on SampleStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SampleStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SampleStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SampleStatus value)  $default,){
final _that = this;
switch (_that) {
case _SampleStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SampleStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SampleStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String message,  bool isHealthy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SampleStatus() when $default != null:
return $default(_that.id,_that.message,_that.isHealthy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String message,  bool isHealthy)  $default,) {final _that = this;
switch (_that) {
case _SampleStatus():
return $default(_that.id,_that.message,_that.isHealthy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String message,  bool isHealthy)?  $default,) {final _that = this;
switch (_that) {
case _SampleStatus() when $default != null:
return $default(_that.id,_that.message,_that.isHealthy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SampleStatus implements SampleStatus {
  const _SampleStatus({required this.id, required this.message, required this.isHealthy});
  factory _SampleStatus.fromJson(Map<String, dynamic> json) => _$SampleStatusFromJson(json);

@override final  String id;
@override final  String message;
@override final  bool isHealthy;

/// Create a copy of SampleStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SampleStatusCopyWith<_SampleStatus> get copyWith => __$SampleStatusCopyWithImpl<_SampleStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SampleStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SampleStatus&&(identical(other.id, id) || other.id == id)&&(identical(other.message, message) || other.message == message)&&(identical(other.isHealthy, isHealthy) || other.isHealthy == isHealthy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,message,isHealthy);

@override
String toString() {
  return 'SampleStatus(id: $id, message: $message, isHealthy: $isHealthy)';
}


}

/// @nodoc
abstract mixin class _$SampleStatusCopyWith<$Res> implements $SampleStatusCopyWith<$Res> {
  factory _$SampleStatusCopyWith(_SampleStatus value, $Res Function(_SampleStatus) _then) = __$SampleStatusCopyWithImpl;
@override @useResult
$Res call({
 String id, String message, bool isHealthy
});




}
/// @nodoc
class __$SampleStatusCopyWithImpl<$Res>
    implements _$SampleStatusCopyWith<$Res> {
  __$SampleStatusCopyWithImpl(this._self, this._then);

  final _SampleStatus _self;
  final $Res Function(_SampleStatus) _then;

/// Create a copy of SampleStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? message = null,Object? isHealthy = null,}) {
  return _then(_SampleStatus(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isHealthy: null == isHealthy ? _self.isHealthy : isHealthy // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
