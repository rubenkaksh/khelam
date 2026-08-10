import 'package:intl/intl.dart';

import '../models/slot.dart';

/// Formats a slot's time range, e.g. `7:00 AM – 8:00 AM`.
String slotTimeRange(Slot slot) {
  final DateFormat timeFormat = DateFormat('h:mm a');
  return '${timeFormat.format(slot.startTime)} – ${timeFormat.format(slot.endTime)}';
}
