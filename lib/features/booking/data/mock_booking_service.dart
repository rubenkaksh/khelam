import '../booking_service.dart';
import '../models/booking.dart';
import '../models/booking_status.dart';
import '../models/schedule_slot_item.dart';
import '../models/slot.dart';
import '../models/slot_status.dart';
import '../models/turf_summary.dart';
import 'mock_turfs_repository.dart';

String _slotId(int hour, DateTime date) =>
    'slot-${date.year}-${date.month}-${date.day}-$hour';
String _bookingId(int hour, DateTime date) =>
    'bk-${date.year}-${date.month}-${date.day}-$hour';

class MockBookingService implements BookingService {
  MockBookingService();

  static const int _openHour = 7;
  static const int _closeHour = 22;
  static const List<String> _customerNames = <String>[
    'Team Alpha',
    'FC Rovers',
    'United Stars',
    'Sporting Club',
    'Elite Academy',
  ];

  final Set<String> _extraBookedSlotIds = <String>{};

  @override
  Future<TurfSummary> getTurf(String turfId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    // Names follow the two known turfs from MockTurfsRepository so the turf
    // header matches what was picked on the selection screen.
    return TurfSummary(
      id: turfId,
      name: turfId == MockTurfsRepository.secondTurfId ? 'Turf B' : 'Turf A',
      address: turfId == MockTurfsRepository.secondTurfId
          ? 'Sector 7, Futsal Court'
          : 'Sector 12, Sports Complex',
    );
  }

  @override
  Future<List<ScheduleSlotItem>> getSchedule({
    required String turfId,
    required DateTime date,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final DateTime normalizedDate = DateTime(date.year, date.month, date.day);
    final List<ScheduleSlotItem> items = <ScheduleSlotItem>[];

    for (int hour = _openHour; hour < _closeHour; hour++) {
      final DateTime startTime = normalizedDate.add(Duration(hours: hour));
      final DateTime endTime = normalizedDate.add(Duration(hours: hour + 1));

      final String sid = _slotId(hour, date);
      final bool isBooked =
          _isSlotBooked(hour, date) || _extraBookedSlotIds.contains(sid);
      final SlotStatus slotStatus = isBooked
          ? SlotStatus.booked
          : SlotStatus.available;

      final Slot slot = Slot(
        id: sid,
        turfId: turfId,
        slotDate: normalizedDate,
        startTime: startTime,
        endTime: endTime,
        status: slotStatus,
      );

      Booking? booking;
      String? customerName;
      if (isBooked) {
        final int customerIndex = (hour * 7 + date.day) % _customerNames.length;
        customerName = _customerNames[customerIndex];
        booking = Booking(
          id: _bookingId(hour, date),
          bookingCode:
              'BK-${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}-${hour.toString().padLeft(2, '0')}',
          userId: 'user-1',
          turfId: turfId,
          slotId: sid,
          totalAmount: 100.0,
          advanceAmount: 50.0,
          remainingAmount: 50.0,
          status: BookingStatus.confirmed,
        );
      }

      items.add(
        ScheduleSlotItem(
          slot: slot,
          booking: booking,
          customerName: customerName,
        ),
      );
    }

    return items;
  }

  @override
  Future<void> bookSlot({
    required String turfId,
    required String slotId,
    String? customerPhone,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _extraBookedSlotIds.add(slotId);
  }

  bool _isSlotBooked(int hour, DateTime date) {
    final int totalSlots = _closeHour - _openHour;
    final int daySeed = date.day + date.month * 31;
    final int slotIndex = hour - _openHour;
    final int threshold = totalSlots ~/ 2;
    return (slotIndex * 7 + daySeed * 13) % totalSlots < threshold;
  }
}
