import '../../domain/models/schedule_slot_item.dart';
import '../../domain/models/turf_summary.dart';
import '../../domain/repositories/booking_service.dart';

class BookingRepository {
  const BookingRepository({required BookingService service})
    : _service = service;

  final BookingService _service;

  Future<TurfSummary> getTurf(String turfId) {
    return _service.getTurf(turfId);
  }

  Future<List<ScheduleSlotItem>> getSchedule({
    required String turfId,
    required DateTime date,
  }) {
    return _service.getSchedule(turfId: turfId, date: date);
  }

  Future<ScheduleSlotItem> bookSlot({
    required String turfId,
    required String slotId,
  }) {
    return _service.bookSlot(turfId: turfId, slotId: slotId);
  }
}
