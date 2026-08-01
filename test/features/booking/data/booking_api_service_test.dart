import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/core/network/dio_api_client.dart';
import 'package:khelam/features/booking/data/booking_api_service.dart';
import 'package:khelam/features/booking/models/slot_status.dart';
import 'package:khelam/features/booking/models/turf_summary.dart';

void main() {
  group('BookingApiService', () {
    // Slot payloads as returned by GET /slots (the deleted
    // lib/ui/features/schedule/data/dummy.dart was the original reference for
    // this shape).
    final List<Map<String, dynamic>> slotsJson = <Map<String, dynamic>>[
      <String, dynamic>{
        'id': '9ded7792-74cf-4dd5-bd32-06ea445547d8',
        'slot_date': '2026-07-31T00:00:00.000Z',
        'start_time': '1970-01-01T06:00:00.000Z',
        'end_time': '1970-01-01T07:00:00.000Z',
        'status': 'available',
        'isBooked': false,
        'bookedBy': null,
      },
      <String, dynamic>{
        'id': 'c3b0fcef-17b7-4b5e-9c5d-4e17b7b5e9c5',
        'slot_date': '2026-07-31T00:00:00.000Z',
        'start_time': '1970-01-01T18:00:00.000Z',
        'end_time': '1970-01-01T19:00:00.000Z',
        'status': 'booked',
        'isBooked': true,
        'bookedBy': 'Rahul Sharma',
      },
    ];

    test('getTurf returns dummy turf data for the requested id', () async {
      final _RecordingAdapter adapter = _RecordingAdapter(
        (RequestOptions options) async => _jsonResponse(<dynamic>[]),
      );
      final BookingApiService service = _service(adapter);

      final TurfSummary turf = await service.getTurf('turf-1');

      expect(turf.id, 'turf-1');
      expect(turf.name, isNotEmpty);
      expect(turf.address, isNotEmpty);
    });

    test(
      'getSchedule sends turfId and yyyy-MM-dd date query parameters',
      () async {
        final _RecordingAdapter adapter = _RecordingAdapter(
          (RequestOptions options) async => _jsonResponse(slotsJson),
        );
        final BookingApiService service = _service(adapter);

        await service.getSchedule(
          turfId: '44444444-4444-4444-4444-444444444441',
          date: DateTime(2026, 7, 31),
        );

        final RequestOptions? request = adapter.lastRequest;
        expect(request?.path, '/slots');
        expect(
          request?.queryParameters['turfId'],
          '44444444-4444-4444-4444-444444444441',
        );
        expect(request?.queryParameters['date'], '2026-07-31');
      },
    );

    test('getSchedule maps slot rows into schedule items', () async {
      final _RecordingAdapter adapter = _RecordingAdapter(
        (RequestOptions options) async => _jsonResponse(slotsJson),
      );
      final BookingApiService service = _service(adapter);

      final items = await service.getSchedule(
        turfId: '44444444-4444-4444-4444-444444444441',
        date: DateTime(2026, 7, 31),
      );

      expect(items, hasLength(2));

      // Available slot: API times combine with the calendar date.
      final available = items[0];
      expect(available.slot.id, '9ded7792-74cf-4dd5-bd32-06ea445547d8');
      expect(available.slot.turfId, '44444444-4444-4444-4444-444444444441');
      expect(available.slot.slotDate, DateTime(2026, 7, 31));
      expect(available.slot.startTime, DateTime(2026, 7, 31, 6));
      expect(available.slot.endTime, DateTime(2026, 7, 31, 7));
      expect(available.slot.status, SlotStatus.available);
      expect(available.booking, isNull);
      expect(available.customerName, isNull);

      // Booked slot: no booking object on list responses, but status and
      // booker name come through.
      final booked = items[1];
      expect(booked.slot.status, SlotStatus.booked);
      expect(booked.slot.startTime, DateTime(2026, 7, 31, 18));
      expect(booked.slot.endTime, DateTime(2026, 7, 31, 19));
      expect(booked.booking, isNull);
      expect(booked.customerName, 'Rahul Sharma');
    });

    test('bookSlot POSTs to /slots/:id/book without a body', () async {
      final _RecordingAdapter adapter = _RecordingAdapter(
        (RequestOptions options) async => _jsonResponse(<String, dynamic>{
          'booking': <String, dynamic>{'id': 'b1'},
          'slot': <String, dynamic>{'id': 's1', 'status': 'booked'},
        }),
      );
      final BookingApiService service = _service(adapter);

      await service.bookSlot(turfId: 'turf-1', slotId: 's1');

      final RequestOptions? request = adapter.lastRequest;
      expect(request?.method, 'POST');
      expect(request?.path, '/slots/s1/book');
      expect(request?.data, isNull);
    });
  });
}

BookingApiService _service(_RecordingAdapter adapter) {
  final Dio dio = Dio()..httpClientAdapter = adapter;
  return BookingApiService(
    apiClient: DioApiClient(baseUrl: 'https://example.test', dio: dio),
  );
}

ResponseBody _jsonResponse(Object? body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.respond);

  final Future<ResponseBody> Function(RequestOptions options) respond;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    lastRequest = options;
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}
