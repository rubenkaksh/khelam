import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:commons/commons.dart';
import '../../../di/service_locator.dart';
import '../../../ui/navigation/app_routes.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../bloc/schedule_cubit.dart';
import '../models/turf_summary.dart';
import '../widgets/booking_confirmation_sheet.dart';
import '../widgets/booking_timeline.dart';
import '../widgets/date_strip.dart';
import '../widgets/day_stats_section.dart';
import '../widgets/turf_header.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  @override
  void initState() {
    super.initState();
    // The turf id arrives on the route (/schedule?turfId=...) from the
    // turf-selection screen; when absent the cubit falls back to its
    // constructor id (the router guards against the missing case).
    // GoRouterState.of must run after initState (it depends on ModalRoute).
    final ScheduleCubit cubit = context.read<ScheduleCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? turfId = GoRouterState.of(
        context,
      ).uri.queryParameters['turfId'];
      cubit.load(turfId: turfId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (BuildContext context, ScheduleState state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Schedule'),
            actions: [
              // Testing aid: sign out and land on the login screen. The
              // session is also cleared from storage, so the next launch
              // starts logged out.
              IconButton(
                tooltip: 'Logout',
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await serviceLocator<AuthCubit>().logout();
                  if (context.mounted) {
                    context.goNamed(AppRoutes.login);
                  }
                },
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ScheduleState state) {
    final List<DateTime> dates = _generateDateRange();

    return ListView(
      children: <Widget>[
        SizedBox(height: 10),
        DateStrip(
          dates: dates,
          selectedDate: state.selectedDate ?? DateTime.now(),
          onDateSelected: (DateTime date) {
            context.read<ScheduleCubit>().selectDate(date);
          },
        ),

        if (state.turf case final TurfSummary turf) TurfHeader(turf: turf),
        // Content slot — the loading/empty/error states render here, where
        // the timeline renders, so the date strip and header stay visible
        // instead of a state view replacing the whole body.
        if (state.isLoading && state.slots.isEmpty)
          const BookingTimelineSkeleton()
        else if (state.errorMessage case final String error
            when state.slots.isEmpty)
          ErrorView(
            message: error,
            onRetry: () => context.read<ScheduleCubit>().load(),
          )
        else if (!state.isLoading &&
            state.turf != null &&
            state.slots.isEmpty &&
            state.errorMessage == null)
          const Center(
            child: EmptyView(message: 'No slots available for this date.'),
          )
        else ...[
          if (state.isLoading && state.slots.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: BookingTimelineSkeleton(cardCount: 1),
            ),
          BookingTimeline(
            items: state.slots,
            onAvailableSlotTap: (item) async {
              // Booking requires a signed-in user. Send guests to login and
              // remember the current location so the auth flow lands them back
              // here (with the guard now passing).
              if (!serviceLocator<AuthCubit>().state.isAuthenticated) {
                context.goNamed(
                  AppRoutes.login,
                  queryParameters: <String, String>{
                    'redirectTo': GoRouterState.of(context).uri.toString(),
                  },
                );
                return;
              }
              final ScheduleCubit cubit = context.read<ScheduleCubit>();
              final BookingResult? result =
                  await showFormBottomSheet<BookingResult>(
                    context: context,
                    builder: (_) => BookingConfirmationSheet(slot: item.slot),
                  );
              if (result case final BookingResult confirmed) {
                cubit.bookSlot(
                  item.slot.id,
                  customerName: confirmed.customerName,
                  customerPhone: confirmed.customerPhone,
                );
              }
            },
          ),
          if (state.slots.isNotEmpty) DayStatsSection(stats: state.dayStats),
        ],
      ],
    );
  }

  List<DateTime> _generateDateRange() {
    final DateTime today = DateTime.now();
    return List<DateTime>.generate(
      7,
      (int i) => DateTime(today.year, today.month, today.day + i),
    );
  }
}
