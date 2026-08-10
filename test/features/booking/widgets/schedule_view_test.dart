import 'package:flutter/material.dart' as m;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:khelam/features/booking/bloc/schedule_cubit.dart';
import 'package:khelam/features/booking/booking_service.dart';
import 'package:khelam/features/booking/models/schedule_slot_item.dart';
import 'package:khelam/features/booking/models/turf_summary.dart';
import 'package:khelam/features/booking/views/schedule_view.dart';
import 'package:khelam/ui/navigation/app_routes.dart';

/// Minimal service returning an empty slot list for any date — the
/// loaded-but-empty day scenario the empty view covers.
class _EmptySlotsBookingService implements BookingService {
  @override
  Future<TurfSummary> getTurf(String turfId) async {
    return const TurfSummary(id: 'turf-a', name: 'Turf A');
  }

  @override
  Future<List<ScheduleSlotItem>> getSchedule({
    required String turfId,
    required DateTime date,
  }) async {
    return const <ScheduleSlotItem>[];
  }

  @override
  Future<void> bookSlot({
    required String turfId,
    required String slotId,
    String? customerName,
    String? customerPhone,
  }) async {}
}

void main() {
  m.Widget app(ScheduleCubit cubit) {
    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.schedulePath,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.schedulePath,
          name: AppRoutes.schedule,
          builder: (m.BuildContext c, GoRouterState s) =>
              BlocProvider<ScheduleCubit>.value(
                value: cubit,
                child: const ScheduleView(),
              ),
        ),
      ],
    );
    return m.MaterialApp.router(routerConfig: router);
  }

  testWidgets('shows the empty view when a loaded day has no slots', (
    WidgetTester tester,
  ) async {
    final ScheduleCubit cubit = ScheduleCubit(
      service: _EmptySlotsBookingService(),
      turfId: 'turf-a',
    );
    await tester.pumpWidget(app(cubit));
    await tester.pump(); // post-frame load starts
    await tester.pump(); // load completes and the view rebuilds

    expect(find.text('No slots available for this date.'), findsOneWidget);
  });
}
