import 'package:flutter/material.dart' as m;
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

class ScheduleView extends m.StatefulWidget {
  const ScheduleView({super.key});

  @override
  m.State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends m.State<ScheduleView> {
  @override
  void initState() {
    super.initState();
    final ScheduleCubit cubit = context.read<ScheduleCubit>();
    m.WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.load();
    });
  }

  @override
  m.Widget build(m.BuildContext context) {
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (m.BuildContext context, ScheduleState state) {
        return m.Scaffold(
          appBar: m.AppBar(
            title: const m.Text('Schedule'),
            actions: [
              // Testing aid: sign out and land on the login screen. The
              // session is also cleared from storage, so the next launch
              // starts logged out.
              m.IconButton(
                tooltip: 'Logout',
                icon: const m.Icon(m.Icons.logout),
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

  m.Widget _buildBody(m.BuildContext context, ScheduleState state) {
    if (state.isLoading && state.turf == null) {
      return const LoadingView();
    }

    if (state.errorMessage case final String error when state.slots.isEmpty) {
      return ErrorView(
        message: error,
        onRetry: () => context.read<ScheduleCubit>().load(),
      );
    }

    final List<DateTime> dates = _generateDateRange();

    return m.ListView(
      children: <m.Widget>[
        DateStrip(
          dates: dates,
          selectedDate: state.selectedDate ?? DateTime.now(),
          onDateSelected: (DateTime date) {
            context.read<ScheduleCubit>().selectDate(date);
          },
        ),
        if (state.turf case final TurfSummary turf) TurfHeader(turf: turf),
        if (state.isLoading && state.slots.isNotEmpty)
          const m.Padding(
            padding: m.EdgeInsets.all(16),
            child: m.CircularProgressIndicator(),
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
                customerPhone: confirmed.customerPhone,
              );
            }
          },
        ),
        if (state.slots.isNotEmpty) DayStatsSection(stats: state.dayStats),
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
