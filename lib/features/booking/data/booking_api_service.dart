import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import 'package:commons/commons.dart';
import '../booking_service.dart';
import '../models/schedule_slot_item.dart';
import '../models/slot.dart';
import '../models/turf_summary.dart';

/// Real API implementation of [BookingService] backed by the NestJS
/// `rms-futsal-backend`.
///
/// Endpoints:
/// - `GET /slots?turfId=:turfId&date=YYYY-MM-DD` (public)
/// - `POST /slots/:id/book` (requires JWT — not wired yet, will 401)
///
/// JSON responses are parsed with the domain models' generated `fromJson`
/// (`Slot`, `Booking`), following the app's freezed + json_serializable
/// convention.
class BookingApiService implements BookingService {
  BookingApiService({required DioApiClient apiClient}) : _apiClient = apiClient;

  final DioApiClient _apiClient;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// Dummy turf data until a turfs endpoint exists on the backend.
  static const String _dummyTurfName = 'Turf A';
  static const String _dummyTurfAddress = 'Sector 12, Sports Complex';

  @override
  Future<TurfSummary> getTurf(String turfId) async {
    // TODO: replace with a real GET /turfs/:id call once the endpoint exists.
    return TurfSummary(
      id: turfId,
      name: _dummyTurfName,
      address: _dummyTurfAddress,
    );
  }

  @override
  Future<List<ScheduleSlotItem>> getSchedule({
    required String turfId,
    required DateTime date,
  }) async {
    final List<Map<String, dynamic>> jsonList;
    try {
      jsonList = await _apiClient.getJsonList(
        '/slots',
        queryParameters: <String, dynamic>{
          'turfId': turfId,
          'date': _dateFormat.format(date),
        },
      );
    } on DioException catch (e) {
      // Raw dio failures → typed, user-facing exceptions (offline/timeout/
      // server/client) that the cubit surfaces by message.
      throw _apiClient.mapDioException(e);
    }

    return jsonList
        .map((Map<String, dynamic> json) => _toScheduleSlotItem(json, turfId))
        .toList();
  }

  @override
  Future<void> bookSlot({
    required String turfId,
    required String slotId,
    String? customerPhone,
  }) async {
    // The backend identifies the booker via the JWT (not yet wired in the
    // app), so customerPhone is intentionally not sent. Requires a bearer
    // token via DioApiClient.setBearerToken; without one the call returns 401.
    // The response booking/slot is not used: the cubit refetches the schedule.
    try {
      await _apiClient.postJson('/slots/$slotId/book');
    } on DioException catch (e) {
      throw _apiClient.mapDioException(e);
    }
  }

  /// Parses an API slot row into the domain [Slot] and wraps it in a
  /// [ScheduleSlotItem].
  ///
  /// The list endpoint omits `turf_id` per row (it is implied by the query),
  /// so it is completed here before the generated parser runs. The backend
  /// encodes the time-of-day with a dummy date (`1970-01-01`), so the slot's
  /// calendar date comes from `slot_date` and the clock time from
  /// `start_time`/`end_time`, combined into a local [DateTime].
  ScheduleSlotItem _toScheduleSlotItem(
    Map<String, dynamic> json,
    String turfId,
  ) {
    final Slot slot = Slot.fromJson(<String, dynamic>{
      ...json,
      'turf_id': turfId,
    });
    final DateTime date = DateTime(
      slot.slotDate.year,
      slot.slotDate.month,
      slot.slotDate.day,
    );

    return ScheduleSlotItem(
      slot: slot.copyWith(
        slotDate: date,
        startTime: _timeOnDate(slot.startTime, date),
        endTime: _timeOnDate(slot.endTime, date),
      ),
      // The slots list endpoint returns no booking details; the booker's
      // display name arrives as `bookedBy`.
      booking: null,
      customerName: json['bookedBy'] as String?,
    );
  }

  DateTime _timeOnDate(DateTime time, DateTime date) => DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
    time.second,
  );
}
