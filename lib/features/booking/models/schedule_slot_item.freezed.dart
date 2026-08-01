// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_slot_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleSlotItem {

 Slot get slot; Booking? get booking; String? get customerName;
/// Create a copy of ScheduleSlotItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleSlotItemCopyWith<ScheduleSlotItem> get copyWith => _$ScheduleSlotItemCopyWithImpl<ScheduleSlotItem>(this as ScheduleSlotItem, _$identity);

  /// Serializes this ScheduleSlotItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleSlotItem&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.booking, booking) || other.booking == booking)&&(identical(other.customerName, customerName) || other.customerName == customerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slot,booking,customerName);

@override
String toString() {
  return 'ScheduleSlotItem(slot: $slot, booking: $booking, customerName: $customerName)';
}


}

/// @nodoc
abstract mixin class $ScheduleSlotItemCopyWith<$Res>  {
  factory $ScheduleSlotItemCopyWith(ScheduleSlotItem value, $Res Function(ScheduleSlotItem) _then) = _$ScheduleSlotItemCopyWithImpl;
@useResult
$Res call({
 Slot slot, Booking? booking, String? customerName
});


$SlotCopyWith<$Res> get slot;$BookingCopyWith<$Res>? get booking;

}
/// @nodoc
class _$ScheduleSlotItemCopyWithImpl<$Res>
    implements $ScheduleSlotItemCopyWith<$Res> {
  _$ScheduleSlotItemCopyWithImpl(this._self, this._then);

  final ScheduleSlotItem _self;
  final $Res Function(ScheduleSlotItem) _then;

/// Create a copy of ScheduleSlotItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slot = null,Object? booking = freezed,Object? customerName = freezed,}) {
  return _then(_self.copyWith(
slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as Slot,booking: freezed == booking ? _self.booking : booking // ignore: cast_nullable_to_non_nullable
as Booking?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ScheduleSlotItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SlotCopyWith<$Res> get slot {
  
  return $SlotCopyWith<$Res>(_self.slot, (value) {
    return _then(_self.copyWith(slot: value));
  });
}/// Create a copy of ScheduleSlotItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingCopyWith<$Res>? get booking {
    if (_self.booking == null) {
    return null;
  }

  return $BookingCopyWith<$Res>(_self.booking!, (value) {
    return _then(_self.copyWith(booking: value));
  });
}
}


/// Adds pattern-matching-related methods to [ScheduleSlotItem].
extension ScheduleSlotItemPatterns on ScheduleSlotItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleSlotItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleSlotItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleSlotItem value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleSlotItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleSlotItem value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleSlotItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Slot slot,  Booking? booking,  String? customerName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleSlotItem() when $default != null:
return $default(_that.slot,_that.booking,_that.customerName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Slot slot,  Booking? booking,  String? customerName)  $default,) {final _that = this;
switch (_that) {
case _ScheduleSlotItem():
return $default(_that.slot,_that.booking,_that.customerName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Slot slot,  Booking? booking,  String? customerName)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleSlotItem() when $default != null:
return $default(_that.slot,_that.booking,_that.customerName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduleSlotItem implements ScheduleSlotItem {
  const _ScheduleSlotItem({required this.slot, this.booking, this.customerName});
  factory _ScheduleSlotItem.fromJson(Map<String, dynamic> json) => _$ScheduleSlotItemFromJson(json);

@override final  Slot slot;
@override final  Booking? booking;
@override final  String? customerName;

/// Create a copy of ScheduleSlotItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleSlotItemCopyWith<_ScheduleSlotItem> get copyWith => __$ScheduleSlotItemCopyWithImpl<_ScheduleSlotItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleSlotItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleSlotItem&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.booking, booking) || other.booking == booking)&&(identical(other.customerName, customerName) || other.customerName == customerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slot,booking,customerName);

@override
String toString() {
  return 'ScheduleSlotItem(slot: $slot, booking: $booking, customerName: $customerName)';
}


}

/// @nodoc
abstract mixin class _$ScheduleSlotItemCopyWith<$Res> implements $ScheduleSlotItemCopyWith<$Res> {
  factory _$ScheduleSlotItemCopyWith(_ScheduleSlotItem value, $Res Function(_ScheduleSlotItem) _then) = __$ScheduleSlotItemCopyWithImpl;
@override @useResult
$Res call({
 Slot slot, Booking? booking, String? customerName
});


@override $SlotCopyWith<$Res> get slot;@override $BookingCopyWith<$Res>? get booking;

}
/// @nodoc
class __$ScheduleSlotItemCopyWithImpl<$Res>
    implements _$ScheduleSlotItemCopyWith<$Res> {
  __$ScheduleSlotItemCopyWithImpl(this._self, this._then);

  final _ScheduleSlotItem _self;
  final $Res Function(_ScheduleSlotItem) _then;

/// Create a copy of ScheduleSlotItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slot = null,Object? booking = freezed,Object? customerName = freezed,}) {
  return _then(_ScheduleSlotItem(
slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as Slot,booking: freezed == booking ? _self.booking : booking // ignore: cast_nullable_to_non_nullable
as Booking?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ScheduleSlotItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SlotCopyWith<$Res> get slot {
  
  return $SlotCopyWith<$Res>(_self.slot, (value) {
    return _then(_self.copyWith(slot: value));
  });
}/// Create a copy of ScheduleSlotItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingCopyWith<$Res>? get booking {
    if (_self.booking == null) {
    return null;
  }

  return $BookingCopyWith<$Res>(_self.booking!, (value) {
    return _then(_self.copyWith(booking: value));
  });
}
}

// dart format on
