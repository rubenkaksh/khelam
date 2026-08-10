import 'package:commons/commons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../booking_service.dart';
import '../models/schedule_slot_item.dart';
import '../models/slot_status.dart';
import '../models/turf_summary.dart';

/// Aggregate stats for a single schedule day.
///
/// Lives beside the state machine (not in a widget file) so the state
/// vocabulary is defined where the state is computed.
class DayStats {
  const DayStats({this.bookingCount = 0, this.revenue = 0.0});

  final int bookingCount;
  final double revenue;
}

class ScheduleState {
  const ScheduleState({
    this.selectedDate,
    this.turf,
    this.slots = const <ScheduleSlotItem>[],
    this.dayStats = const DayStats(),
    this.isLoading = false,
    this.errorMessage,
  });

  final DateTime? selectedDate;
  final TurfSummary? turf;
  final List<ScheduleSlotItem> slots;
  final DayStats dayStats;
  final bool isLoading;
  final String? errorMessage;

  ScheduleState copyWith({
    DateTime? selectedDate,
    TurfSummary? turf,
    List<ScheduleSlotItem>? slots,
    DayStats? dayStats,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ScheduleState(
      selectedDate: selectedDate ?? this.selectedDate,
      turf: turf ?? this.turf,
      slots: slots ?? this.slots,
      dayStats: dayStats ?? this.dayStats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit({required BookingService service, required String turfId})
    : _service = service,
      _turfId = turfId,
      super(const ScheduleState());

  /// Turf selected on the turf-selection screen and passed through the route
  /// (no hardcoded fallback: the schedule only exists for a picked turf).
  final String _turfId;

  final BookingService _service;

  Future<void> load({String? turfId}) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final TurfSummary turf = await _service.getTurf(turfId ?? _turfId);
      final DateTime today = DateTime.now();
      final DateTime normalizedDate = DateTime(
        today.year,
        today.month,
        today.day,
      );

      final List<ScheduleSlotItem> slots = await _service.getSchedule(
        turfId: turf.id,
        date: normalizedDate,
      );

      emit(
        state.copyWith(
          selectedDate: normalizedDate,
          turf: turf,
          slots: slots,
          dayStats: _computeStats(slots),
          isLoading: false,
          clearError: true,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Could not load schedule.',
        ),
      );
    }
  }

  Future<void> selectDate(DateTime date) async {
    final DateTime normalizedDate = DateTime(date.year, date.month, date.day);
    emit(state.copyWith(selectedDate: normalizedDate, isLoading: true));

    try {
      final List<ScheduleSlotItem> slots = await _service.getSchedule(
        turfId: state.turf?.id ?? _turfId,
        date: normalizedDate,
      );
      emit(
        state.copyWith(
          slots: slots,
          dayStats: _computeStats(slots),
          isLoading: false,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Could not load schedule for selected date.',
        ),
      );
    }
  }

  Future<void> bookSlot(
    String slotId, {
    String? customerName,
    String? customerPhone,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _service.bookSlot(
        turfId: state.turf?.id ?? _turfId,
        slotId: slotId,
        customerName: customerName,
        customerPhone: customerPhone,
      );

      // The server is the source of truth: re-fetch the schedule so the
      // booked slot (and its booker name) comes back from the API.
      final DateTime date = state.selectedDate ?? DateTime.now();
      final List<ScheduleSlotItem> updatedSlots = await _service.getSchedule(
        turfId: state.turf?.id ?? _turfId,
        date: date,
      );

      emit(
        state.copyWith(
          slots: updatedSlots,
          dayStats: _computeStats(updatedSlots),
          isLoading: false,
          clearError: true,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Could not book slot. Please try again.',
        ),
      );
    }
  }

  DayStats _computeStats(List<ScheduleSlotItem> items) {
    int count = 0;
    double revenue = 0.0;
    for (final ScheduleSlotItem item in items) {
      // Count by slot status so API data (which has no booking object on
      // list slots) is counted too.
      if (item.slot.status == SlotStatus.booked) {
        count++;
        // Revenue needs the booking payload; the slots list endpoint does not
        // return one, so API mode reports ₹0 until the backend supplies it.
        revenue += item.booking?.totalAmount ?? 0;
      }
    }
    return DayStats(bookingCount: count, revenue: revenue);
  }
}
