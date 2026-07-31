// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slot_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SlotDto {

 String get id;@JsonKey(name: 'slot_date') DateTime get slotDate;@JsonKey(name: 'start_time') DateTime get startTime;@JsonKey(name: 'end_time') DateTime get endTime; String get status;@JsonKey(name: 'isBooked') bool get isBooked; String? get bookedBy;
/// Create a copy of SlotDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlotDtoCopyWith<SlotDto> get copyWith => _$SlotDtoCopyWithImpl<SlotDto>(this as SlotDto, _$identity);

  /// Serializes this SlotDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlotDto&&(identical(other.id, id) || other.id == id)&&(identical(other.slotDate, slotDate) || other.slotDate == slotDate)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.isBooked, isBooked) || other.isBooked == isBooked)&&(identical(other.bookedBy, bookedBy) || other.bookedBy == bookedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slotDate,startTime,endTime,status,isBooked,bookedBy);

@override
String toString() {
  return 'SlotDto(id: $id, slotDate: $slotDate, startTime: $startTime, endTime: $endTime, status: $status, isBooked: $isBooked, bookedBy: $bookedBy)';
}


}

/// @nodoc
abstract mixin class $SlotDtoCopyWith<$Res>  {
  factory $SlotDtoCopyWith(SlotDto value, $Res Function(SlotDto) _then) = _$SlotDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'slot_date') DateTime slotDate,@JsonKey(name: 'start_time') DateTime startTime,@JsonKey(name: 'end_time') DateTime endTime, String status,@JsonKey(name: 'isBooked') bool isBooked, String? bookedBy
});




}
/// @nodoc
class _$SlotDtoCopyWithImpl<$Res>
    implements $SlotDtoCopyWith<$Res> {
  _$SlotDtoCopyWithImpl(this._self, this._then);

  final SlotDto _self;
  final $Res Function(SlotDto) _then;

/// Create a copy of SlotDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slotDate = null,Object? startTime = null,Object? endTime = null,Object? status = null,Object? isBooked = null,Object? bookedBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slotDate: null == slotDate ? _self.slotDate : slotDate // ignore: cast_nullable_to_non_nullable
as DateTime,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isBooked: null == isBooked ? _self.isBooked : isBooked // ignore: cast_nullable_to_non_nullable
as bool,bookedBy: freezed == bookedBy ? _self.bookedBy : bookedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SlotDto].
extension SlotDtoPatterns on SlotDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SlotDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SlotDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SlotDto value)  $default,){
final _that = this;
switch (_that) {
case _SlotDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SlotDto value)?  $default,){
final _that = this;
switch (_that) {
case _SlotDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'slot_date')  DateTime slotDate, @JsonKey(name: 'start_time')  DateTime startTime, @JsonKey(name: 'end_time')  DateTime endTime,  String status, @JsonKey(name: 'isBooked')  bool isBooked,  String? bookedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SlotDto() when $default != null:
return $default(_that.id,_that.slotDate,_that.startTime,_that.endTime,_that.status,_that.isBooked,_that.bookedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'slot_date')  DateTime slotDate, @JsonKey(name: 'start_time')  DateTime startTime, @JsonKey(name: 'end_time')  DateTime endTime,  String status, @JsonKey(name: 'isBooked')  bool isBooked,  String? bookedBy)  $default,) {final _that = this;
switch (_that) {
case _SlotDto():
return $default(_that.id,_that.slotDate,_that.startTime,_that.endTime,_that.status,_that.isBooked,_that.bookedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'slot_date')  DateTime slotDate, @JsonKey(name: 'start_time')  DateTime startTime, @JsonKey(name: 'end_time')  DateTime endTime,  String status, @JsonKey(name: 'isBooked')  bool isBooked,  String? bookedBy)?  $default,) {final _that = this;
switch (_that) {
case _SlotDto() when $default != null:
return $default(_that.id,_that.slotDate,_that.startTime,_that.endTime,_that.status,_that.isBooked,_that.bookedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SlotDto implements SlotDto {
  const _SlotDto({required this.id, @JsonKey(name: 'slot_date') required this.slotDate, @JsonKey(name: 'start_time') required this.startTime, @JsonKey(name: 'end_time') required this.endTime, required this.status, @JsonKey(name: 'isBooked') required this.isBooked, this.bookedBy});
  factory _SlotDto.fromJson(Map<String, dynamic> json) => _$SlotDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'slot_date') final  DateTime slotDate;
@override@JsonKey(name: 'start_time') final  DateTime startTime;
@override@JsonKey(name: 'end_time') final  DateTime endTime;
@override final  String status;
@override@JsonKey(name: 'isBooked') final  bool isBooked;
@override final  String? bookedBy;

/// Create a copy of SlotDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlotDtoCopyWith<_SlotDto> get copyWith => __$SlotDtoCopyWithImpl<_SlotDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SlotDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SlotDto&&(identical(other.id, id) || other.id == id)&&(identical(other.slotDate, slotDate) || other.slotDate == slotDate)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.isBooked, isBooked) || other.isBooked == isBooked)&&(identical(other.bookedBy, bookedBy) || other.bookedBy == bookedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slotDate,startTime,endTime,status,isBooked,bookedBy);

@override
String toString() {
  return 'SlotDto(id: $id, slotDate: $slotDate, startTime: $startTime, endTime: $endTime, status: $status, isBooked: $isBooked, bookedBy: $bookedBy)';
}


}

/// @nodoc
abstract mixin class _$SlotDtoCopyWith<$Res> implements $SlotDtoCopyWith<$Res> {
  factory _$SlotDtoCopyWith(_SlotDto value, $Res Function(_SlotDto) _then) = __$SlotDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'slot_date') DateTime slotDate,@JsonKey(name: 'start_time') DateTime startTime,@JsonKey(name: 'end_time') DateTime endTime, String status,@JsonKey(name: 'isBooked') bool isBooked, String? bookedBy
});




}
/// @nodoc
class __$SlotDtoCopyWithImpl<$Res>
    implements _$SlotDtoCopyWith<$Res> {
  __$SlotDtoCopyWithImpl(this._self, this._then);

  final _SlotDto _self;
  final $Res Function(_SlotDto) _then;

/// Create a copy of SlotDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slotDate = null,Object? startTime = null,Object? endTime = null,Object? status = null,Object? isBooked = null,Object? bookedBy = freezed,}) {
  return _then(_SlotDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slotDate: null == slotDate ? _self.slotDate : slotDate // ignore: cast_nullable_to_non_nullable
as DateTime,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isBooked: null == isBooked ? _self.isBooked : isBooked // ignore: cast_nullable_to_non_nullable
as bool,bookedBy: freezed == bookedBy ? _self.bookedBy : bookedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
