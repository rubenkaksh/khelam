import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/booking_repository.dart';
import '../../../../domain/models/schedule_slot_item.dart';
import '../../../../domain/models/turf_summary.dart';
import '../widgets/day_stats_section.dart';

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
  ScheduleCubit({required BookingRepository repository})
    : _repository = repository,
      super(const ScheduleState());

  final BookingRepository _repository;

  Future<void> load({String? turfId}) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final TurfSummary turf = await _repository.getTurf(
        turfId ?? 'turf-a',
      );
      final DateTime today = DateTime.now();
      final DateTime normalizedDate = DateTime(today.year, today.month, today.day);

      final List<ScheduleSlotItem> slots = await _repository.getSchedule(
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
    } catch (e) {
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
      final List<ScheduleSlotItem> slots = await _repository.getSchedule(
        turfId: state.turf?.id ?? 'turf-a',
        date: normalizedDate,
      );
      emit(
        state.copyWith(
          slots: slots,
          dayStats: _computeStats(slots),
          isLoading: false,
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

  Future<void> bookSlot(String slotId) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final ScheduleSlotItem bookedItem = await _repository.bookSlot(
        turfId: state.turf?.id ?? 'turf-a',
        slotId: slotId,
      );

      final List<ScheduleSlotItem> updatedSlots = state.slots.map((item) {
        if (item.slot.id == slotId) return bookedItem;
        return item;
      }).toList();

      emit(state.copyWith(
        slots: updatedSlots,
        dayStats: _computeStats(updatedSlots),
        isLoading: false,
        clearError: true,
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Could not book slot. Please try again.',
      ));
    }
  }

  DayStats _computeStats(List<ScheduleSlotItem> items) {
    int count = 0;
    double revenue = 0.0;
    for (final ScheduleSlotItem item in items) {
      if (item.booking != null) {
        count++;
        revenue += item.booking!.totalAmount;
      }
    }
    return DayStats(bookingCount: count, revenue: revenue);
  }
}
