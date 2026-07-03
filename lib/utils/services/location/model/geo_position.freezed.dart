// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'geo_position.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GeoPosition {

 double get latitude; double get longitude; double get accuracy; DateTime? get timestamp;
/// Create a copy of GeoPosition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeoPositionCopyWith<GeoPosition> get copyWith => _$GeoPositionCopyWithImpl<GeoPosition>(this as GeoPosition, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeoPosition&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}


@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,accuracy,timestamp);

@override
String toString() {
  return 'GeoPosition(latitude: $latitude, longitude: $longitude, accuracy: $accuracy, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $GeoPositionCopyWith<$Res>  {
  factory $GeoPositionCopyWith(GeoPosition value, $Res Function(GeoPosition) _then) = _$GeoPositionCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude, double accuracy, DateTime? timestamp
});




}
/// @nodoc
class _$GeoPositionCopyWithImpl<$Res>
    implements $GeoPositionCopyWith<$Res> {
  _$GeoPositionCopyWithImpl(this._self, this._then);

  final GeoPosition _self;
  final $Res Function(GeoPosition) _then;

/// Create a copy of GeoPosition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = null,Object? longitude = null,Object? accuracy = null,Object? timestamp = freezed,}) {
  return _then(_self.copyWith(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GeoPosition].
extension GeoPositionPatterns on GeoPosition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeoPosition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeoPosition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeoPosition value)  $default,){
final _that = this;
switch (_that) {
case _GeoPosition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeoPosition value)?  $default,){
final _that = this;
switch (_that) {
case _GeoPosition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitude,  double longitude,  double accuracy,  DateTime? timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeoPosition() when $default != null:
return $default(_that.latitude,_that.longitude,_that.accuracy,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitude,  double longitude,  double accuracy,  DateTime? timestamp)  $default,) {final _that = this;
switch (_that) {
case _GeoPosition():
return $default(_that.latitude,_that.longitude,_that.accuracy,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitude,  double longitude,  double accuracy,  DateTime? timestamp)?  $default,) {final _that = this;
switch (_that) {
case _GeoPosition() when $default != null:
return $default(_that.latitude,_that.longitude,_that.accuracy,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc


class _GeoPosition implements GeoPosition {
  const _GeoPosition({required this.latitude, required this.longitude, required this.accuracy, this.timestamp});
  

@override final  double latitude;
@override final  double longitude;
@override final  double accuracy;
@override final  DateTime? timestamp;

/// Create a copy of GeoPosition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeoPositionCopyWith<_GeoPosition> get copyWith => __$GeoPositionCopyWithImpl<_GeoPosition>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeoPosition&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}


@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,accuracy,timestamp);

@override
String toString() {
  return 'GeoPosition(latitude: $latitude, longitude: $longitude, accuracy: $accuracy, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$GeoPositionCopyWith<$Res> implements $GeoPositionCopyWith<$Res> {
  factory _$GeoPositionCopyWith(_GeoPosition value, $Res Function(_GeoPosition) _then) = __$GeoPositionCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude, double accuracy, DateTime? timestamp
});




}
/// @nodoc
class __$GeoPositionCopyWithImpl<$Res>
    implements _$GeoPositionCopyWith<$Res> {
  __$GeoPositionCopyWithImpl(this._self, this._then);

  final _GeoPosition _self;
  final $Res Function(_GeoPosition) _then;

/// Create a copy of GeoPosition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? accuracy = null,Object? timestamp = freezed,}) {
  return _then(_GeoPosition(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
