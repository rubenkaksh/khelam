import '../../domain/models/schedule_slot_item.dart';
import '../../domain/models/turf_summary.dart';

abstract interface class BookingService {
  Future<TurfSummary> getTurf(String turfId);
  Future<List<ScheduleSlotItem>> getSchedule({
    required String turfId,
    required DateTime date,
  });
  Future<ScheduleSlotItem> bookSlot({
    required String turfId,
    required String slotId,
    String? customerPhone,
  });
}
