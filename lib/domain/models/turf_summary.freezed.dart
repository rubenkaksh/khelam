// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'turf_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TurfSummary {

 String get id; String get name; String? get address;
/// Create a copy of TurfSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TurfSummaryCopyWith<TurfSummary> get copyWith => _$TurfSummaryCopyWithImpl<TurfSummary>(this as TurfSummary, _$identity);

  /// Serializes this TurfSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TurfSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,address);

@override
String toString() {
  return 'TurfSummary(id: $id, name: $name, address: $address)';
}


}

/// @nodoc
abstract mixin class $TurfSummaryCopyWith<$Res>  {
  factory $TurfSummaryCopyWith(TurfSummary value, $Res Function(TurfSummary) _then) = _$TurfSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? address
});




}
/// @nodoc
class _$TurfSummaryCopyWithImpl<$Res>
    implements $TurfSummaryCopyWith<$Res> {
  _$TurfSummaryCopyWithImpl(this._self, this._then);

  final TurfSummary _self;
  final $Res Function(TurfSummary) _then;

/// Create a copy of TurfSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? address = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TurfSummary].
extension TurfSummaryPatterns on TurfSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TurfSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TurfSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TurfSummary value)  $default,){
final _that = this;
switch (_that) {
case _TurfSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TurfSummary value)?  $default,){
final _that = this;
switch (_that) {
case _TurfSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TurfSummary() when $default != null:
return $default(_that.id,_that.name,_that.address);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? address)  $default,) {final _that = this;
switch (_that) {
case _TurfSummary():
return $default(_that.id,_that.name,_that.address);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? address)?  $default,) {final _that = this;
switch (_that) {
case _TurfSummary() when $default != null:
return $default(_that.id,_that.name,_that.address);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TurfSummary implements TurfSummary {
  const _TurfSummary({required this.id, required this.name, this.address});
  factory _TurfSummary.fromJson(Map<String, dynamic> json) => _$TurfSummaryFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? address;

/// Create a copy of TurfSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TurfSummaryCopyWith<_TurfSummary> get copyWith => __$TurfSummaryCopyWithImpl<_TurfSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TurfSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TurfSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,address);

@override
String toString() {
  return 'TurfSummary(id: $id, name: $name, address: $address)';
}


}

/// @nodoc
abstract mixin class _$TurfSummaryCopyWith<$Res> implements $TurfSummaryCopyWith<$Res> {
  factory _$TurfSummaryCopyWith(_TurfSummary value, $Res Function(_TurfSummary) _then) = __$TurfSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? address
});




}
/// @nodoc
class __$TurfSummaryCopyWithImpl<$Res>
    implements _$TurfSummaryCopyWith<$Res> {
  __$TurfSummaryCopyWithImpl(this._self, this._then);

  final _TurfSummary _self;
  final $Res Function(_TurfSummary) _then;

/// Create a copy of TurfSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? address = freezed,}) {
  return _then(_TurfSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
