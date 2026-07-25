// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'local_sample_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocalSampleRecord {

 String get key; String get value;
/// Create a copy of LocalSampleRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalSampleRecordCopyWith<LocalSampleRecord> get copyWith => _$LocalSampleRecordCopyWithImpl<LocalSampleRecord>(this as LocalSampleRecord, _$identity);

  /// Serializes this LocalSampleRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalSampleRecord&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,value);

@override
String toString() {
  return 'LocalSampleRecord(key: $key, value: $value)';
}


}

/// @nodoc
abstract mixin class $LocalSampleRecordCopyWith<$Res>  {
  factory $LocalSampleRecordCopyWith(LocalSampleRecord value, $Res Function(LocalSampleRecord) _then) = _$LocalSampleRecordCopyWithImpl;
@useResult
$Res call({
 String key, String value
});




}
/// @nodoc
class _$LocalSampleRecordCopyWithImpl<$Res>
    implements $LocalSampleRecordCopyWith<$Res> {
  _$LocalSampleRecordCopyWithImpl(this._self, this._then);

  final LocalSampleRecord _self;
  final $Res Function(LocalSampleRecord) _then;

/// Create a copy of LocalSampleRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? value = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalSampleRecord].
extension LocalSampleRecordPatterns on LocalSampleRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalSampleRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalSampleRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalSampleRecord value)  $default,){
final _that = this;
switch (_that) {
case _LocalSampleRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalSampleRecord value)?  $default,){
final _that = this;
switch (_that) {
case _LocalSampleRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalSampleRecord() when $default != null:
return $default(_that.key,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String value)  $default,) {final _that = this;
switch (_that) {
case _LocalSampleRecord():
return $default(_that.key,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String value)?  $default,) {final _that = this;
switch (_that) {
case _LocalSampleRecord() when $default != null:
return $default(_that.key,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocalSampleRecord implements LocalSampleRecord {
  const _LocalSampleRecord({required this.key, required this.value});
  factory _LocalSampleRecord.fromJson(Map<String, dynamic> json) => _$LocalSampleRecordFromJson(json);

@override final  String key;
@override final  String value;

/// Create a copy of LocalSampleRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalSampleRecordCopyWith<_LocalSampleRecord> get copyWith => __$LocalSampleRecordCopyWithImpl<_LocalSampleRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocalSampleRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalSampleRecord&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,value);

@override
String toString() {
  return 'LocalSampleRecord(key: $key, value: $value)';
}


}

/// @nodoc
abstract mixin class _$LocalSampleRecordCopyWith<$Res> implements $LocalSampleRecordCopyWith<$Res> {
  factory _$LocalSampleRecordCopyWith(_LocalSampleRecord value, $Res Function(_LocalSampleRecord) _then) = __$LocalSampleRecordCopyWithImpl;
@override @useResult
$Res call({
 String key, String value
});




}
/// @nodoc
class __$LocalSampleRecordCopyWithImpl<$Res>
    implements _$LocalSampleRecordCopyWith<$Res> {
  __$LocalSampleRecordCopyWithImpl(this._self, this._then);

  final _LocalSampleRecord _self;
  final $Res Function(_LocalSampleRecord) _then;

/// Create a copy of LocalSampleRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? value = null,}) {
  return _then(_LocalSampleRecord(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
