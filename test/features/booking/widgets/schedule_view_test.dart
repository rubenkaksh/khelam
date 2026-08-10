import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:commons/commons.dart';
import 'package:khelam/features/booking/bloc/schedule_cubit.dart';
import 'package:khelam/features/booking/booking_service.dart';
import 'package:khelam/features/booking/models/schedule_slot_item.dart';
import 'package:khelam/features/booking/models/turf_summary.dart';
import 'package:khelam/features/booking/views/schedule_view.dart';
import 'package:khelam/features/booking/widgets/booking_timeline.dart';
import 'package:khelam/features/booking/widgets/date_strip.dart';
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

/// Service whose load futures never complete — keeps the cubit in its
/// loading state for the duration of the test.
class _PendingBookingService implements BookingService {
  @override
  Future<TurfSummary> getTurf(String turfId) => Completer<TurfSummary>().future;

  @override
  Future<List<ScheduleSlotItem>> getSchedule({
    required String turfId,
    required DateTime date,
  }) {
    return Completer<List<ScheduleSlotItem>>().future;
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
  Widget app(ScheduleCubit cubit) {
    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.schedulePath,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.schedulePath,
          name: AppRoutes.schedule,
          builder: (BuildContext c, GoRouterState s) =>
              BlocProvider<ScheduleCubit>.value(
                value: cubit,
                child: const ScheduleView(),
              ),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
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

  testWidgets('keeps the date strip visible alongside the empty view', (
    WidgetTester tester,
  ) async {
    final ScheduleCubit cubit = ScheduleCubit(
      service: _EmptySlotsBookingService(),
      turfId: 'turf-a',
    );
    await tester.pumpWidget(app(cubit));
    await tester.pump(); // post-frame load starts
    await tester.pump(); // load completes and the view rebuilds

    expect(
      find.byType(DateStrip),
      findsOneWidget,
      reason: 'date strip must stay visible when the day is empty',
    );
    expect(find.text('No slots available for this date.'), findsOneWidget);
    expect(
      find.byType(BookingTimeline),
      findsNothing,
      reason:
          'empty view replaces the timeline in the content slot, '
          'not the whole body',
    );
  });

  testWidgets('shows the loading view in the content slot while loading', (
    WidgetTester tester,
  ) async {
    final ScheduleCubit cubit = ScheduleCubit(
      service: _PendingBookingService(),
      turfId: 'turf-a',
    );
    await tester.pumpWidget(app(cubit));
    await tester.pump(); // post-frame load starts

    expect(
      find.byType(DateStrip),
      findsOneWidget,
      reason: 'date strip must stay visible while loading',
    );
    expect(
      find.byType(LoadingView),
      findsOneWidget,
      reason: 'loading view renders in the content slot',
    );
    expect(find.byType(BookingTimeline), findsNothing);
  });
}
