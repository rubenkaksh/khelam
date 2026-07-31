import 'package:intl/intl.dart';

import '../models/slot_dto.dart';
import '../services/dio_api_client.dart';
import '../../domain/models/schedule_slot_item.dart';
import '../../domain/models/slot.dart';
import '../../domain/models/slot_status.dart';
import '../../domain/models/turf_summary.dart';
import '../../domain/repositories/booking_service.dart';

/// Real API implementation of [BookingService] backed by the NestJS
/// `rms-futsal-backend`.
///
/// Endpoints:
/// - `GET /slots?turfId=:turfId&date=YYYY-MM-DD` (public)
/// - `POST /slots/:id/book` (requires JWT — not wired yet, will 401)
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
    final List<Map<String, dynamic>> jsonList = await _apiClient.getJsonList(
      '/slots',
      queryParameters: <String, dynamic>{
        'turfId': turfId,
        'date': _dateFormat.format(date),
      },
    );

    return jsonList
        .map((Map<String, dynamic> json) =>
            _toScheduleSlotItem(SlotDto.fromJson(json), turfId))
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
    await _apiClient.postJson('/slots/$slotId/book');
  }

  /// Maps an API slot row into the domain [Slot] + [ScheduleSlotItem].
  ///
  /// The backend encodes the time-of-day with a dummy date (`1970-01-01`),
  /// so the slot's calendar date comes from `slot_date` and the clock time
  /// from `start_time`/`end_time`, combined into a local [DateTime].
  ScheduleSlotItem _toScheduleSlotItem(SlotDto dto, String turfId) {
    final DateTime utcDate = dto.slotDate.toUtc();
    final DateTime date = DateTime(utcDate.year, utcDate.month, utcDate.day);

    final DateTime utcStart = dto.startTime.toUtc();
    final DateTime startTime = DateTime(
      date.year,
      date.month,
      date.day,
      utcStart.hour,
      utcStart.minute,
      utcStart.second,
    );
    final DateTime utcEnd = dto.endTime.toUtc();
    final DateTime endTime = DateTime(
      date.year,
      date.month,
      date.day,
      utcEnd.hour,
      utcEnd.minute,
      utcEnd.second,
    );

    return ScheduleSlotItem(
      slot: Slot(
        id: dto.id,
        turfId: turfId,
        slotDate: date,
        startTime: startTime,
        endTime: endTime,
        status: SlotStatus.values.byName(dto.status),
      ),
      // The slots list endpoint returns no booking details; the booker's
      // display name arrives as `bookedBy`.
      booking: null,
      customerName: dto.bookedBy,
    );
  }
}
