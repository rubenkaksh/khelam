// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingResponseDto {

 BookingDto get booking; BookedSlotDto get slot;
/// Create a copy of BookingResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingResponseDtoCopyWith<BookingResponseDto> get copyWith => _$BookingResponseDtoCopyWithImpl<BookingResponseDto>(this as BookingResponseDto, _$identity);

  /// Serializes this BookingResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingResponseDto&&(identical(other.booking, booking) || other.booking == booking)&&(identical(other.slot, slot) || other.slot == slot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,booking,slot);

@override
String toString() {
  return 'BookingResponseDto(booking: $booking, slot: $slot)';
}


}

/// @nodoc
abstract mixin class $BookingResponseDtoCopyWith<$Res>  {
  factory $BookingResponseDtoCopyWith(BookingResponseDto value, $Res Function(BookingResponseDto) _then) = _$BookingResponseDtoCopyWithImpl;
@useResult
$Res call({
 BookingDto booking, BookedSlotDto slot
});


$BookingDtoCopyWith<$Res> get booking;$BookedSlotDtoCopyWith<$Res> get slot;

}
/// @nodoc
class _$BookingResponseDtoCopyWithImpl<$Res>
    implements $BookingResponseDtoCopyWith<$Res> {
  _$BookingResponseDtoCopyWithImpl(this._self, this._then);

  final BookingResponseDto _self;
  final $Res Function(BookingResponseDto) _then;

/// Create a copy of BookingResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? booking = null,Object? slot = null,}) {
  return _then(_self.copyWith(
booking: null == booking ? _self.booking : booking // ignore: cast_nullable_to_non_nullable
as BookingDto,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as BookedSlotDto,
  ));
}
/// Create a copy of BookingResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingDtoCopyWith<$Res> get booking {
  
  return $BookingDtoCopyWith<$Res>(_self.booking, (value) {
    return _then(_self.copyWith(booking: value));
  });
}/// Create a copy of BookingResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookedSlotDtoCopyWith<$Res> get slot {
  
  return $BookedSlotDtoCopyWith<$Res>(_self.slot, (value) {
    return _then(_self.copyWith(slot: value));
  });
}
}


/// Adds pattern-matching-related methods to [BookingResponseDto].
extension BookingResponseDtoPatterns on BookingResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _BookingResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _BookingResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BookingDto booking,  BookedSlotDto slot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingResponseDto() when $default != null:
return $default(_that.booking,_that.slot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BookingDto booking,  BookedSlotDto slot)  $default,) {final _that = this;
switch (_that) {
case _BookingResponseDto():
return $default(_that.booking,_that.slot);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BookingDto booking,  BookedSlotDto slot)?  $default,) {final _that = this;
switch (_that) {
case _BookingResponseDto() when $default != null:
return $default(_that.booking,_that.slot);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookingResponseDto implements BookingResponseDto {
  const _BookingResponseDto({required this.booking, required this.slot});
  factory _BookingResponseDto.fromJson(Map<String, dynamic> json) => _$BookingResponseDtoFromJson(json);

@override final  BookingDto booking;
@override final  BookedSlotDto slot;

/// Create a copy of BookingResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingResponseDtoCopyWith<_BookingResponseDto> get copyWith => __$BookingResponseDtoCopyWithImpl<_BookingResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingResponseDto&&(identical(other.booking, booking) || other.booking == booking)&&(identical(other.slot, slot) || other.slot == slot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,booking,slot);

@override
String toString() {
  return 'BookingResponseDto(booking: $booking, slot: $slot)';
}


}

/// @nodoc
abstract mixin class _$BookingResponseDtoCopyWith<$Res> implements $BookingResponseDtoCopyWith<$Res> {
  factory _$BookingResponseDtoCopyWith(_BookingResponseDto value, $Res Function(_BookingResponseDto) _then) = __$BookingResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 BookingDto booking, BookedSlotDto slot
});


@override $BookingDtoCopyWith<$Res> get booking;@override $BookedSlotDtoCopyWith<$Res> get slot;

}
/// @nodoc
class __$BookingResponseDtoCopyWithImpl<$Res>
    implements _$BookingResponseDtoCopyWith<$Res> {
  __$BookingResponseDtoCopyWithImpl(this._self, this._then);

  final _BookingResponseDto _self;
  final $Res Function(_BookingResponseDto) _then;

/// Create a copy of BookingResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? booking = null,Object? slot = null,}) {
  return _then(_BookingResponseDto(
booking: null == booking ? _self.booking : booking // ignore: cast_nullable_to_non_nullable
as BookingDto,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as BookedSlotDto,
  ));
}

/// Create a copy of BookingResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingDtoCopyWith<$Res> get booking {
  
  return $BookingDtoCopyWith<$Res>(_self.booking, (value) {
    return _then(_self.copyWith(booking: value));
  });
}/// Create a copy of BookingResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookedSlotDtoCopyWith<$Res> get slot {
  
  return $BookedSlotDtoCopyWith<$Res>(_self.slot, (value) {
    return _then(_self.copyWith(slot: value));
  });
}
}


/// @nodoc
mixin _$BookingDto {

 String get id;@JsonKey(name: 'booking_code') String get bookingCode;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'turf_id') String get turfId;@JsonKey(name: 'slot_id') String get slotId;@JsonKey(name: 'total_amount', fromJson: _amountToDouble) double get totalAmount;@JsonKey(name: 'advance_amount', fromJson: _amountToDouble) double get advanceAmount;@JsonKey(name: 'remaining_amount', fromJson: _amountToDouble) double get remainingAmount; String get status;
/// Create a copy of BookingDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingDtoCopyWith<BookingDto> get copyWith => _$BookingDtoCopyWithImpl<BookingDto>(this as BookingDto, _$identity);

  /// Serializes this BookingDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingDto&&(identical(other.id, id) || other.id == id)&&(identical(other.bookingCode, bookingCode) || other.bookingCode == bookingCode)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.turfId, turfId) || other.turfId == turfId)&&(identical(other.slotId, slotId) || other.slotId == slotId)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.advanceAmount, advanceAmount) || other.advanceAmount == advanceAmount)&&(identical(other.remainingAmount, remainingAmount) || other.remainingAmount == remainingAmount)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bookingCode,userId,turfId,slotId,totalAmount,advanceAmount,remainingAmount,status);

@override
String toString() {
  return 'BookingDto(id: $id, bookingCode: $bookingCode, userId: $userId, turfId: $turfId, slotId: $slotId, totalAmount: $totalAmount, advanceAmount: $advanceAmount, remainingAmount: $remainingAmount, status: $status)';
}


}

/// @nodoc
abstract mixin class $BookingDtoCopyWith<$Res>  {
  factory $BookingDtoCopyWith(BookingDto value, $Res Function(BookingDto) _then) = _$BookingDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'booking_code') String bookingCode,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'turf_id') String turfId,@JsonKey(name: 'slot_id') String slotId,@JsonKey(name: 'total_amount', fromJson: _amountToDouble) double totalAmount,@JsonKey(name: 'advance_amount', fromJson: _amountToDouble) double advanceAmount,@JsonKey(name: 'remaining_amount', fromJson: _amountToDouble) double remainingAmount, String status
});




}
/// @nodoc
class _$BookingDtoCopyWithImpl<$Res>
    implements $BookingDtoCopyWith<$Res> {
  _$BookingDtoCopyWithImpl(this._self, this._then);

  final BookingDto _self;
  final $Res Function(BookingDto) _then;

/// Create a copy of BookingDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bookingCode = null,Object? userId = null,Object? turfId = null,Object? slotId = null,Object? totalAmount = null,Object? advanceAmount = null,Object? remainingAmount = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,bookingCode: null == bookingCode ? _self.bookingCode : bookingCode // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,turfId: null == turfId ? _self.turfId : turfId // ignore: cast_nullable_to_non_nullable
as String,slotId: null == slotId ? _self.slotId : slotId // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,advanceAmount: null == advanceAmount ? _self.advanceAmount : advanceAmount // ignore: cast_nullable_to_non_nullable
as double,remainingAmount: null == remainingAmount ? _self.remainingAmount : remainingAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingDto].
extension BookingDtoPatterns on BookingDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingDto value)  $default,){
final _that = this;
switch (_that) {
case _BookingDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingDto value)?  $default,){
final _that = this;
switch (_that) {
case _BookingDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'booking_code')  String bookingCode, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'turf_id')  String turfId, @JsonKey(name: 'slot_id')  String slotId, @JsonKey(name: 'total_amount', fromJson: _amountToDouble)  double totalAmount, @JsonKey(name: 'advance_amount', fromJson: _amountToDouble)  double advanceAmount, @JsonKey(name: 'remaining_amount', fromJson: _amountToDouble)  double remainingAmount,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingDto() when $default != null:
return $default(_that.id,_that.bookingCode,_that.userId,_that.turfId,_that.slotId,_that.totalAmount,_that.advanceAmount,_that.remainingAmount,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'booking_code')  String bookingCode, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'turf_id')  String turfId, @JsonKey(name: 'slot_id')  String slotId, @JsonKey(name: 'total_amount', fromJson: _amountToDouble)  double totalAmount, @JsonKey(name: 'advance_amount', fromJson: _amountToDouble)  double advanceAmount, @JsonKey(name: 'remaining_amount', fromJson: _amountToDouble)  double remainingAmount,  String status)  $default,) {final _that = this;
switch (_that) {
case _BookingDto():
return $default(_that.id,_that.bookingCode,_that.userId,_that.turfId,_that.slotId,_that.totalAmount,_that.advanceAmount,_that.remainingAmount,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'booking_code')  String bookingCode, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'turf_id')  String turfId, @JsonKey(name: 'slot_id')  String slotId, @JsonKey(name: 'total_amount', fromJson: _amountToDouble)  double totalAmount, @JsonKey(name: 'advance_amount', fromJson: _amountToDouble)  double advanceAmount, @JsonKey(name: 'remaining_amount', fromJson: _amountToDouble)  double remainingAmount,  String status)?  $default,) {final _that = this;
switch (_that) {
case _BookingDto() when $default != null:
return $default(_that.id,_that.bookingCode,_that.userId,_that.turfId,_that.slotId,_that.totalAmount,_that.advanceAmount,_that.remainingAmount,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookingDto implements BookingDto {
  const _BookingDto({required this.id, @JsonKey(name: 'booking_code') required this.bookingCode, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'turf_id') required this.turfId, @JsonKey(name: 'slot_id') required this.slotId, @JsonKey(name: 'total_amount', fromJson: _amountToDouble) required this.totalAmount, @JsonKey(name: 'advance_amount', fromJson: _amountToDouble) required this.advanceAmount, @JsonKey(name: 'remaining_amount', fromJson: _amountToDouble) required this.remainingAmount, required this.status});
  factory _BookingDto.fromJson(Map<String, dynamic> json) => _$BookingDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'booking_code') final  String bookingCode;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'turf_id') final  String turfId;
@override@JsonKey(name: 'slot_id') final  String slotId;
@override@JsonKey(name: 'total_amount', fromJson: _amountToDouble) final  double totalAmount;
@override@JsonKey(name: 'advance_amount', fromJson: _amountToDouble) final  double advanceAmount;
@override@JsonKey(name: 'remaining_amount', fromJson: _amountToDouble) final  double remainingAmount;
@override final  String status;

/// Create a copy of BookingDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingDtoCopyWith<_BookingDto> get copyWith => __$BookingDtoCopyWithImpl<_BookingDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingDto&&(identical(other.id, id) || other.id == id)&&(identical(other.bookingCode, bookingCode) || other.bookingCode == bookingCode)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.turfId, turfId) || other.turfId == turfId)&&(identical(other.slotId, slotId) || other.slotId == slotId)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.advanceAmount, advanceAmount) || other.advanceAmount == advanceAmount)&&(identical(other.remainingAmount, remainingAmount) || other.remainingAmount == remainingAmount)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bookingCode,userId,turfId,slotId,totalAmount,advanceAmount,remainingAmount,status);

@override
String toString() {
  return 'BookingDto(id: $id, bookingCode: $bookingCode, userId: $userId, turfId: $turfId, slotId: $slotId, totalAmount: $totalAmount, advanceAmount: $advanceAmount, remainingAmount: $remainingAmount, status: $status)';
}


}

/// @nodoc
abstract mixin class _$BookingDtoCopyWith<$Res> implements $BookingDtoCopyWith<$Res> {
  factory _$BookingDtoCopyWith(_BookingDto value, $Res Function(_BookingDto) _then) = __$BookingDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'booking_code') String bookingCode,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'turf_id') String turfId,@JsonKey(name: 'slot_id') String slotId,@JsonKey(name: 'total_amount', fromJson: _amountToDouble) double totalAmount,@JsonKey(name: 'advance_amount', fromJson: _amountToDouble) double advanceAmount,@JsonKey(name: 'remaining_amount', fromJson: _amountToDouble) double remainingAmount, String status
});




}
/// @nodoc
class __$BookingDtoCopyWithImpl<$Res>
    implements _$BookingDtoCopyWith<$Res> {
  __$BookingDtoCopyWithImpl(this._self, this._then);

  final _BookingDto _self;
  final $Res Function(_BookingDto) _then;

/// Create a copy of BookingDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bookingCode = null,Object? userId = null,Object? turfId = null,Object? slotId = null,Object? totalAmount = null,Object? advanceAmount = null,Object? remainingAmount = null,Object? status = null,}) {
  return _then(_BookingDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,bookingCode: null == bookingCode ? _self.bookingCode : bookingCode // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,turfId: null == turfId ? _self.turfId : turfId // ignore: cast_nullable_to_non_nullable
as String,slotId: null == slotId ? _self.slotId : slotId // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,advanceAmount: null == advanceAmount ? _self.advanceAmount : advanceAmount // ignore: cast_nullable_to_non_nullable
as double,remainingAmount: null == remainingAmount ? _self.remainingAmount : remainingAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$BookedSlotDto {

 String get id; String get status;
/// Create a copy of BookedSlotDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookedSlotDtoCopyWith<BookedSlotDto> get copyWith => _$BookedSlotDtoCopyWithImpl<BookedSlotDto>(this as BookedSlotDto, _$identity);

  /// Serializes this BookedSlotDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookedSlotDto&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status);

@override
String toString() {
  return 'BookedSlotDto(id: $id, status: $status)';
}


}

/// @nodoc
abstract mixin class $BookedSlotDtoCopyWith<$Res>  {
  factory $BookedSlotDtoCopyWith(BookedSlotDto value, $Res Function(BookedSlotDto) _then) = _$BookedSlotDtoCopyWithImpl;
@useResult
$Res call({
 String id, String status
});




}
/// @nodoc
class _$BookedSlotDtoCopyWithImpl<$Res>
    implements $BookedSlotDtoCopyWith<$Res> {
  _$BookedSlotDtoCopyWithImpl(this._self, this._then);

  final BookedSlotDto _self;
  final $Res Function(BookedSlotDto) _then;

/// Create a copy of BookedSlotDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BookedSlotDto].
extension BookedSlotDtoPatterns on BookedSlotDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookedSlotDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookedSlotDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookedSlotDto value)  $default,){
final _that = this;
switch (_that) {
case _BookedSlotDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookedSlotDto value)?  $default,){
final _that = this;
switch (_that) {
case _BookedSlotDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookedSlotDto() when $default != null:
return $default(_that.id,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status)  $default,) {final _that = this;
switch (_that) {
case _BookedSlotDto():
return $default(_that.id,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status)?  $default,) {final _that = this;
switch (_that) {
case _BookedSlotDto() when $default != null:
return $default(_that.id,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookedSlotDto implements BookedSlotDto {
  const _BookedSlotDto({required this.id, required this.status});
  factory _BookedSlotDto.fromJson(Map<String, dynamic> json) => _$BookedSlotDtoFromJson(json);

@override final  String id;
@override final  String status;

/// Create a copy of BookedSlotDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookedSlotDtoCopyWith<_BookedSlotDto> get copyWith => __$BookedSlotDtoCopyWithImpl<_BookedSlotDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookedSlotDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookedSlotDto&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status);

@override
String toString() {
  return 'BookedSlotDto(id: $id, status: $status)';
}


}

/// @nodoc
abstract mixin class _$BookedSlotDtoCopyWith<$Res> implements $BookedSlotDtoCopyWith<$Res> {
  factory _$BookedSlotDtoCopyWith(_BookedSlotDto value, $Res Function(_BookedSlotDto) _then) = __$BookedSlotDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String status
});




}
/// @nodoc
class __$BookedSlotDtoCopyWithImpl<$Res>
    implements _$BookedSlotDtoCopyWith<$Res> {
  __$BookedSlotDtoCopyWithImpl(this._self, this._then);

  final _BookedSlotDto _self;
  final $Res Function(_BookedSlotDto) _then;

/// Create a copy of BookedSlotDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,}) {
  return _then(_BookedSlotDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
