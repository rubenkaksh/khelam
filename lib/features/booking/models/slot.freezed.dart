// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Slot {

 String get id;@JsonKey(name: 'turf_id') String get turfId;@JsonKey(name: 'slot_date') DateTime get slotDate;@JsonKey(name: 'start_time') DateTime get startTime;@JsonKey(name: 'end_time') DateTime get endTime; SlotStatus get status; String? get lockedBy; DateTime? get lockedAt;
/// Create a copy of Slot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlotCopyWith<Slot> get copyWith => _$SlotCopyWithImpl<Slot>(this as Slot, _$identity);

  /// Serializes this Slot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Slot&&(identical(other.id, id) || other.id == id)&&(identical(other.turfId, turfId) || other.turfId == turfId)&&(identical(other.slotDate, slotDate) || other.slotDate == slotDate)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.lockedBy, lockedBy) || other.lockedBy == lockedBy)&&(identical(other.lockedAt, lockedAt) || other.lockedAt == lockedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,turfId,slotDate,startTime,endTime,status,lockedBy,lockedAt);

@override
String toString() {
  return 'Slot(id: $id, turfId: $turfId, slotDate: $slotDate, startTime: $startTime, endTime: $endTime, status: $status, lockedBy: $lockedBy, lockedAt: $lockedAt)';
}


}

/// @nodoc
abstract mixin class $SlotCopyWith<$Res>  {
  factory $SlotCopyWith(Slot value, $Res Function(Slot) _then) = _$SlotCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'turf_id') String turfId,@JsonKey(name: 'slot_date') DateTime slotDate,@JsonKey(name: 'start_time') DateTime startTime,@JsonKey(name: 'end_time') DateTime endTime, SlotStatus status, String? lockedBy, DateTime? lockedAt
});




}
/// @nodoc
class _$SlotCopyWithImpl<$Res>
    implements $SlotCopyWith<$Res> {
  _$SlotCopyWithImpl(this._self, this._then);

  final Slot _self;
  final $Res Function(Slot) _then;

/// Create a copy of Slot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? turfId = null,Object? slotDate = null,Object? startTime = null,Object? endTime = null,Object? status = null,Object? lockedBy = freezed,Object? lockedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,turfId: null == turfId ? _self.turfId : turfId // ignore: cast_nullable_to_non_nullable
as String,slotDate: null == slotDate ? _self.slotDate : slotDate // ignore: cast_nullable_to_non_nullable
as DateTime,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SlotStatus,lockedBy: freezed == lockedBy ? _self.lockedBy : lockedBy // ignore: cast_nullable_to_non_nullable
as String?,lockedAt: freezed == lockedAt ? _self.lockedAt : lockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Slot].
extension SlotPatterns on Slot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Slot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Slot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Slot value)  $default,){
final _that = this;
switch (_that) {
case _Slot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Slot value)?  $default,){
final _that = this;
switch (_that) {
case _Slot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'turf_id')  String turfId, @JsonKey(name: 'slot_date')  DateTime slotDate, @JsonKey(name: 'start_time')  DateTime startTime, @JsonKey(name: 'end_time')  DateTime endTime,  SlotStatus status,  String? lockedBy,  DateTime? lockedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Slot() when $default != null:
return $default(_that.id,_that.turfId,_that.slotDate,_that.startTime,_that.endTime,_that.status,_that.lockedBy,_that.lockedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'turf_id')  String turfId, @JsonKey(name: 'slot_date')  DateTime slotDate, @JsonKey(name: 'start_time')  DateTime startTime, @JsonKey(name: 'end_time')  DateTime endTime,  SlotStatus status,  String? lockedBy,  DateTime? lockedAt)  $default,) {final _that = this;
switch (_that) {
case _Slot():
return $default(_that.id,_that.turfId,_that.slotDate,_that.startTime,_that.endTime,_that.status,_that.lockedBy,_that.lockedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'turf_id')  String turfId, @JsonKey(name: 'slot_date')  DateTime slotDate, @JsonKey(name: 'start_time')  DateTime startTime, @JsonKey(name: 'end_time')  DateTime endTime,  SlotStatus status,  String? lockedBy,  DateTime? lockedAt)?  $default,) {final _that = this;
switch (_that) {
case _Slot() when $default != null:
return $default(_that.id,_that.turfId,_that.slotDate,_that.startTime,_that.endTime,_that.status,_that.lockedBy,_that.lockedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Slot implements Slot {
  const _Slot({required this.id, @JsonKey(name: 'turf_id') required this.turfId, @JsonKey(name: 'slot_date') required this.slotDate, @JsonKey(name: 'start_time') required this.startTime, @JsonKey(name: 'end_time') required this.endTime, required this.status, this.lockedBy, this.lockedAt});
  factory _Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);

@override final  String id;
@override@JsonKey(name: 'turf_id') final  String turfId;
@override@JsonKey(name: 'slot_date') final  DateTime slotDate;
@override@JsonKey(name: 'start_time') final  DateTime startTime;
@override@JsonKey(name: 'end_time') final  DateTime endTime;
@override final  SlotStatus status;
@override final  String? lockedBy;
@override final  DateTime? lockedAt;

/// Create a copy of Slot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlotCopyWith<_Slot> get copyWith => __$SlotCopyWithImpl<_Slot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SlotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Slot&&(identical(other.id, id) || other.id == id)&&(identical(other.turfId, turfId) || other.turfId == turfId)&&(identical(other.slotDate, slotDate) || other.slotDate == slotDate)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.lockedBy, lockedBy) || other.lockedBy == lockedBy)&&(identical(other.lockedAt, lockedAt) || other.lockedAt == lockedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,turfId,slotDate,startTime,endTime,status,lockedBy,lockedAt);

@override
String toString() {
  return 'Slot(id: $id, turfId: $turfId, slotDate: $slotDate, startTime: $startTime, endTime: $endTime, status: $status, lockedBy: $lockedBy, lockedAt: $lockedAt)';
}


}

/// @nodoc
abstract mixin class _$SlotCopyWith<$Res> implements $SlotCopyWith<$Res> {
  factory _$SlotCopyWith(_Slot value, $Res Function(_Slot) _then) = __$SlotCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'turf_id') String turfId,@JsonKey(name: 'slot_date') DateTime slotDate,@JsonKey(name: 'start_time') DateTime startTime,@JsonKey(name: 'end_time') DateTime endTime, SlotStatus status, String? lockedBy, DateTime? lockedAt
});




}
/// @nodoc
class __$SlotCopyWithImpl<$Res>
    implements _$SlotCopyWith<$Res> {
  __$SlotCopyWithImpl(this._self, this._then);

  final _Slot _self;
  final $Res Function(_Slot) _then;

/// Create a copy of Slot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? turfId = null,Object? slotDate = null,Object? startTime = null,Object? endTime = null,Object? status = null,Object? lockedBy = freezed,Object? lockedAt = freezed,}) {
  return _then(_Slot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,turfId: null == turfId ? _self.turfId : turfId // ignore: cast_nullable_to_non_nullable
as String,slotDate: null == slotDate ? _self.slotDate : slotDate // ignore: cast_nullable_to_non_nullable
as DateTime,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SlotStatus,lockedBy: freezed == lockedBy ? _self.lockedBy : lockedBy // ignore: cast_nullable_to_non_nullable
as String?,lockedAt: freezed == lockedAt ? _self.lockedAt : lockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
