// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Booking {

 String get id;@JsonKey(name: 'booking_code') String get bookingCode;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'turf_id') String get turfId;@JsonKey(name: 'slot_id') String get slotId;// Money fields are Prisma `Decimal`s which serialize as JSON strings
// (e.g. `"1000.00"`); [_amountToDouble] accepts both string and number.
@JsonKey(name: 'total_amount', fromJson: _amountToDouble) double get totalAmount;@JsonKey(name: 'advance_amount', fromJson: _amountToDouble) double get advanceAmount;@JsonKey(name: 'remaining_amount', fromJson: _amountToDouble) double get remainingAmount; BookingStatus get status; String? get customerPhone;
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingCopyWith<Booking> get copyWith => _$BookingCopyWithImpl<Booking>(this as Booking, _$identity);

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.bookingCode, bookingCode) || other.bookingCode == bookingCode)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.turfId, turfId) || other.turfId == turfId)&&(identical(other.slotId, slotId) || other.slotId == slotId)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.advanceAmount, advanceAmount) || other.advanceAmount == advanceAmount)&&(identical(other.remainingAmount, remainingAmount) || other.remainingAmount == remainingAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bookingCode,userId,turfId,slotId,totalAmount,advanceAmount,remainingAmount,status,customerPhone);

@override
String toString() {
  return 'Booking(id: $id, bookingCode: $bookingCode, userId: $userId, turfId: $turfId, slotId: $slotId, totalAmount: $totalAmount, advanceAmount: $advanceAmount, remainingAmount: $remainingAmount, status: $status, customerPhone: $customerPhone)';
}


}

/// @nodoc
abstract mixin class $BookingCopyWith<$Res>  {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) _then) = _$BookingCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'booking_code') String bookingCode,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'turf_id') String turfId,@JsonKey(name: 'slot_id') String slotId,@JsonKey(name: 'total_amount', fromJson: _amountToDouble) double totalAmount,@JsonKey(name: 'advance_amount', fromJson: _amountToDouble) double advanceAmount,@JsonKey(name: 'remaining_amount', fromJson: _amountToDouble) double remainingAmount, BookingStatus status, String? customerPhone
});




}
/// @nodoc
class _$BookingCopyWithImpl<$Res>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._self, this._then);

  final Booking _self;
  final $Res Function(Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bookingCode = null,Object? userId = null,Object? turfId = null,Object? slotId = null,Object? totalAmount = null,Object? advanceAmount = null,Object? remainingAmount = null,Object? status = null,Object? customerPhone = freezed,}) {
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
as BookingStatus,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Booking].
extension BookingPatterns on Booking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Booking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Booking value)  $default,){
final _that = this;
switch (_that) {
case _Booking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Booking value)?  $default,){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'booking_code')  String bookingCode, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'turf_id')  String turfId, @JsonKey(name: 'slot_id')  String slotId, @JsonKey(name: 'total_amount', fromJson: _amountToDouble)  double totalAmount, @JsonKey(name: 'advance_amount', fromJson: _amountToDouble)  double advanceAmount, @JsonKey(name: 'remaining_amount', fromJson: _amountToDouble)  double remainingAmount,  BookingStatus status,  String? customerPhone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.bookingCode,_that.userId,_that.turfId,_that.slotId,_that.totalAmount,_that.advanceAmount,_that.remainingAmount,_that.status,_that.customerPhone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'booking_code')  String bookingCode, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'turf_id')  String turfId, @JsonKey(name: 'slot_id')  String slotId, @JsonKey(name: 'total_amount', fromJson: _amountToDouble)  double totalAmount, @JsonKey(name: 'advance_amount', fromJson: _amountToDouble)  double advanceAmount, @JsonKey(name: 'remaining_amount', fromJson: _amountToDouble)  double remainingAmount,  BookingStatus status,  String? customerPhone)  $default,) {final _that = this;
switch (_that) {
case _Booking():
return $default(_that.id,_that.bookingCode,_that.userId,_that.turfId,_that.slotId,_that.totalAmount,_that.advanceAmount,_that.remainingAmount,_that.status,_that.customerPhone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'booking_code')  String bookingCode, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'turf_id')  String turfId, @JsonKey(name: 'slot_id')  String slotId, @JsonKey(name: 'total_amount', fromJson: _amountToDouble)  double totalAmount, @JsonKey(name: 'advance_amount', fromJson: _amountToDouble)  double advanceAmount, @JsonKey(name: 'remaining_amount', fromJson: _amountToDouble)  double remainingAmount,  BookingStatus status,  String? customerPhone)?  $default,) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.bookingCode,_that.userId,_that.turfId,_that.slotId,_that.totalAmount,_that.advanceAmount,_that.remainingAmount,_that.status,_that.customerPhone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Booking implements Booking {
  const _Booking({required this.id, @JsonKey(name: 'booking_code') required this.bookingCode, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'turf_id') required this.turfId, @JsonKey(name: 'slot_id') required this.slotId, @JsonKey(name: 'total_amount', fromJson: _amountToDouble) required this.totalAmount, @JsonKey(name: 'advance_amount', fromJson: _amountToDouble) required this.advanceAmount, @JsonKey(name: 'remaining_amount', fromJson: _amountToDouble) required this.remainingAmount, required this.status, this.customerPhone});
  factory _Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

@override final  String id;
@override@JsonKey(name: 'booking_code') final  String bookingCode;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'turf_id') final  String turfId;
@override@JsonKey(name: 'slot_id') final  String slotId;
// Money fields are Prisma `Decimal`s which serialize as JSON strings
// (e.g. `"1000.00"`); [_amountToDouble] accepts both string and number.
@override@JsonKey(name: 'total_amount', fromJson: _amountToDouble) final  double totalAmount;
@override@JsonKey(name: 'advance_amount', fromJson: _amountToDouble) final  double advanceAmount;
@override@JsonKey(name: 'remaining_amount', fromJson: _amountToDouble) final  double remainingAmount;
@override final  BookingStatus status;
@override final  String? customerPhone;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingCopyWith<_Booking> get copyWith => __$BookingCopyWithImpl<_Booking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.bookingCode, bookingCode) || other.bookingCode == bookingCode)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.turfId, turfId) || other.turfId == turfId)&&(identical(other.slotId, slotId) || other.slotId == slotId)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.advanceAmount, advanceAmount) || other.advanceAmount == advanceAmount)&&(identical(other.remainingAmount, remainingAmount) || other.remainingAmount == remainingAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bookingCode,userId,turfId,slotId,totalAmount,advanceAmount,remainingAmount,status,customerPhone);

@override
String toString() {
  return 'Booking(id: $id, bookingCode: $bookingCode, userId: $userId, turfId: $turfId, slotId: $slotId, totalAmount: $totalAmount, advanceAmount: $advanceAmount, remainingAmount: $remainingAmount, status: $status, customerPhone: $customerPhone)';
}


}

/// @nodoc
abstract mixin class _$BookingCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$BookingCopyWith(_Booking value, $Res Function(_Booking) _then) = __$BookingCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'booking_code') String bookingCode,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'turf_id') String turfId,@JsonKey(name: 'slot_id') String slotId,@JsonKey(name: 'total_amount', fromJson: _amountToDouble) double totalAmount,@JsonKey(name: 'advance_amount', fromJson: _amountToDouble) double advanceAmount,@JsonKey(name: 'remaining_amount', fromJson: _amountToDouble) double remainingAmount, BookingStatus status, String? customerPhone
});




}
/// @nodoc
class __$BookingCopyWithImpl<$Res>
    implements _$BookingCopyWith<$Res> {
  __$BookingCopyWithImpl(this._self, this._then);

  final _Booking _self;
  final $Res Function(_Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bookingCode = null,Object? userId = null,Object? turfId = null,Object? slotId = null,Object? totalAmount = null,Object? advanceAmount = null,Object? remainingAmount = null,Object? status = null,Object? customerPhone = freezed,}) {
  return _then(_Booking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,bookingCode: null == bookingCode ? _self.bookingCode : bookingCode // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,turfId: null == turfId ? _self.turfId : turfId // ignore: cast_nullable_to_non_nullable
as String,slotId: null == slotId ? _self.slotId : slotId // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,advanceAmount: null == advanceAmount ? _self.advanceAmount : advanceAmount // ignore: cast_nullable_to_non_nullable
as double,remainingAmount: null == remainingAmount ? _self.remainingAmount : remainingAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
