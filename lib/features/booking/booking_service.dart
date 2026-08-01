import 'models/schedule_slot_item.dart';
import 'models/turf_summary.dart';

abstract interface class BookingService {
  Future<TurfSummary> getTurf(String turfId);
  Future<List<ScheduleSlotItem>> getSchedule({
    required String turfId,
    required DateTime date,
  });

  /// Books a slot on the server.
  ///
  /// Returns void: the server is the source of truth, so callers should
  /// re-fetch the schedule after booking instead of relying on the response
  /// carrying full slot details.
  Future<void> bookSlot({
    required String turfId,
    required String slotId,
    String? customerPhone,
  });
}
