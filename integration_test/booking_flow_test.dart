import 'dart:io' show Platform;

import 'package:commons/commons.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khelam/features/auth/data/auth_api_service.dart';
import 'package:khelam/features/auth/data/auth_token_store.dart';
import 'package:khelam/features/auth/models/auth_session.dart';
import 'package:khelam/features/booking/booking_service.dart';
import 'package:khelam/features/booking/data/booking_api_service.dart';
import 'package:khelam/features/booking/models/schedule_slot_item.dart';
import 'package:khelam/features/booking/models/slot_status.dart';

/// Books a slot end-to-end against the live NestJS backend
/// (`rms-futsal-backend` on branch `feature/login-auth`, port 8000) using the
/// exact same services the app uses.
///
/// The Android emulator reaches the host machine at `10.0.2.2`; the iOS
/// simulator shares the host network, so `localhost` works there. The backend
/// must be running on the host:
///
///     cd rms-futsal-backend && npm run start:dev
///
/// Run with:
///
///     flutter test integration_test/booking_flow_test.dart -d <device>
void main() {
  final String baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:8000'
      : 'http://localhost:8000';
  const String phoneNumber = '9800000001';
  const String password = 'khelam123';
  const String turfId = '44444444-4444-4444-4444-444444444441';

  testWidgets('login then book an available slot against the live backend', (
    WidgetTester tester,
  ) async {
    final DioApiClient apiClient = DioApiClient(baseUrl: baseUrl);
    final AuthTokenStore tokenStore = AuthTokenStore();
    final AuthApiService authService = AuthApiService(
      apiClient: apiClient,
      tokenStore: tokenStore,
    );
    final BookingService bookingService = BookingApiService(
      apiClient: apiClient,
    );

    // Authenticate: phoneLogin attaches the bearer token to the shared
    // DioApiClient, exactly like the app's login screen does.
    final AuthSession session = await authService.phoneLogin(
      phoneNumber: phoneNumber,
      password: password,
    );
    expect(session.accessToken, isNotEmpty);

    // Find the next day (within a week) that still has an available slot.
    ScheduleSlotItem? target;
    DateTime? targetDate;
    for (int i = 0; i < 7; i++) {
      final DateTime date = DateTime.now().add(Duration(days: i));
      final List<ScheduleSlotItem> items = await bookingService.getSchedule(
        turfId: turfId,
        date: date,
      );
      final List<ScheduleSlotItem> available = items
          .where((ScheduleSlotItem item) => item.slot.status == SlotStatus.available)
          .toList();
      if (available.isNotEmpty) {
        target = available.first;
        targetDate = date;
        break;
      }
    }
    expect(
      target,
      isNotNull,
      reason: 'no available slot found in the next 7 days for turf $turfId',
    );

    // Book it.
    final String slotId = target!.slot.id;
    await bookingService.bookSlot(turfId: turfId, slotId: slotId);

    // The server is the source of truth: refetch and assert the slot flipped
    // to booked with the booker's display name.
    final List<ScheduleSlotItem> refreshed =
        await bookingService.getSchedule(turfId: turfId, date: targetDate!);
    final ScheduleSlotItem updated = refreshed.firstWhere(
      (ScheduleSlotItem item) => item.slot.id == slotId,
    );
    expect(updated.slot.status, SlotStatus.booked);
    expect(updated.customerName, isNotNull);
    expect(updated.customerName, isNotEmpty);
  });
}
