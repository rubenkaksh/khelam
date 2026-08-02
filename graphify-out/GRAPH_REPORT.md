# Graph Report - .  (2026-08-02)

## Corpus Check
- Corpus is ~47,829 words - fits in a single context window. You may not need a graph.

## Summary
- 745 nodes · 1065 edges · 67 communities (53 shown, 14 thin omitted)
- Extraction: 95% EXTRACTED · 5% INFERRED · 0% AMBIGUOUS · INFERRED: 50 edges (avg confidence: 0.84)
- Token cost: 15,500 input · 6,200 output

## Community Hubs (Navigation)
- Windows Runner Boilerplate
- Architecture & Docs Concepts
- Flutter Engine macOS Bindings
- Login & Schedule Views
- App Bootstrap & DI
- Login Contract Strings & Validators
- Platform Runner Build Files
- Linux GTK Plugin Registrant
- Booking Models (Freezed)
- Booking JSON Parsing
- Turf Summary Model
- Slot Model
- Auth User Model
- Dio HTTP Client Layer
- Mock Booking Service
- App Theme Light/Dark
- Schedule Cubit State Machine
- Router & App Shell
- Superpowers Planning Docs
- Auth Cubit & Login Contracts
- Schedule Cubit Tests
- Booking API Service
- Date Chip & Timeline Labels
- Windows Runner Utilities
- Auth Cubit State
- Widget & Service Tests
- Web Manifest
- Booking Timeline Widgets
- App Palette
- App Routes
- Booking Model Tests
- Mock Auth Service
- Booking DI & Env Config
- Auth DI & Service Locator
- Date Strip Widget
- DayStats Section
- Booking Confirmation Sheet
- Booked Slot Card
- Home View & GoRouter
- Auth Service Interface
- Booking Service Interface
- Booking Service Implementations
- Available Slot Card
- Turf Header
- Freezed Generated Files
- Headroom AI Dependency
- Booking Timeline Widgets
- Timeline Rail
- OpenCode Config & Plugin
- Android MainActivity
- Graphify OpenCode Plugin
- Lint Analysis Options
- LoginServiceCallbacks Contract
- LoginStrings Contract
- Navigate Forward Routing
- Booking Status Enum
- Slot Status Enum
- AuthUser fromJson
- Booking fromJson
- SlotItem fromJson
- Slot fromJson
- TurfSummary fromJson
- String None Null

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 22 edges
2. `_` - 19 edges
3. `Session 2026-08-01` - 16 edges
4. `ADR-0004: Feature Modules Own Their Vertical Slice` - 13 edges
5. `MessageHandler` - 12 edges
6. `PRD: Booking Calendar Feature` - 12 edges
7. `ScheduleCubit` - 11 edges
8. `commons Shared Package` - 11 edges
9. `Booking Feature Module` - 11 edges
10. `AuthCubit` - 10 edges

## Surprising Connections (you probably didn't know these)
- `Layered Clean Architecture (README)` --semantically_similar_to--> `Feature Module Owns Vertical Slice`  [INFERRED] [semantically similar]
  README.md → docs/adr/adr-0004-feature-modules-own-their-slice.md
- `Linux top-level CMakeLists.txt` --semantically_similar_to--> `Windows top-level CMakeLists.txt`  [INFERRED] [semantically similar]
  linux/CMakeLists.txt → windows/CMakeLists.txt
- `Linux Flutter build rules CMakeLists.txt` --semantically_similar_to--> `Windows Flutter build rules CMakeLists.txt`  [INFERRED] [semantically similar]
  linux/flutter/CMakeLists.txt → windows/flutter/CMakeLists.txt
- `Linux runner CMakeLists.txt` --semantically_similar_to--> `Windows runner CMakeLists.txt`  [INFERRED] [semantically similar]
  linux/runner/CMakeLists.txt → windows/runner/CMakeLists.txt
- `freezed + json_serializable + build_runner dev dependencies` --semantically_similar_to--> `Model generation with freezed + json_serializable + build_runner (rationale: typed, generated models over hand-written boilerplate)`  [INFERRED] [semantically similar]
  pubspec.yaml → memory.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Architecture Decision Record Series** — docs_adr_adr_0001_no_shallow_use_cases, docs_adr_adr_0002_service_interfaces, docs_adr_adr_0003_per_feature_di, docs_adr_adr_0004_feature_modules_own_their_slice, docs_architecture_review [EXTRACTED 1.00]
- **Feature Module Vertical Slice Pattern** — feature_module_vertical_slice, booking_feature, auth_slice, per_feature_di_registry, pass_through_layer_ban [EXTRACTED 1.00]
- **Commons Shared-Package Extraction** — commons_shared_package, atomic_widget_catalog, dio_api_client, theme_infrastructure_commons, login_screen_commons, google_sign_in_service_commons [EXTRACTED 1.00]
- **Booking bottom sheet phone collection flow (tap slot → sheet → phone → confirm → bookSlot with customerPhone)** — docs_superpowers_checklist_formbottomsheet, docs_superpowers_checklist_phoneinput, docs_superpowers_checklist_bookingconfirmationsheet, docs_superpowers_specs_2026_07_28_booking_bottom_sheet_design_bookingresult, docs_superpowers_plans_2026_07_28_book_available_slots_bookslot, docs_superpowers_checklist_customerphone [EXTRACTED 1.00]
- **Flutter-generated desktop platform build scaffolding (top-level + flutter + runner CMake per platform)** — linux_cmakelists, linux_flutter_cmakelists, linux_runner_cmakelists, windows_cmakelists, windows_flutter_cmakelists, windows_runner_cmakelists [EXTRACTED 1.00]
- **Clean architecture layering convention (ui → domain → data → di) across docs and test layout** — memory_layered_architecture, phase_1_checklist, test_readme [INFERRED 0.85]

## Communities (67 total, 14 thin omitted)

### Community 0 - "Windows Runner Boilerplate"
Cohesion: 0.06
Nodes (53): PluginRegistry, Point, RECT, Size, unique_ptr, RegisterPlugins(), DartProject, HWND (+45 more)

### Community 1 - "Architecture & Docs Concepts"
Cohesion: 0.14
Nodes (42): AGENTS.md (project rules), Atomic Widget Catalog, Auth Feature Slice, Booking Feature Module, BookingService Interface, Layered Clean Architecture (README), commons Shared Package, CONTEXT.md (domain glossary) (+34 more)

### Community 2 - "Flutter Engine macOS Bindings"
Cohesion: 0.07
Nodes (24): Any, Cocoa, Flutter, FlutterAppDelegate, FlutterMacOS, FlutterPluginRegistry, FlutterViewController, Foundation (+16 more)

### Community 3 - "Login & Schedule Views"
Cohesion: 0.07
Nodes (33): LoginView, _LoginViewState, ScheduleCubit, ScheduleState, build, _buildBody, createState, _generateDateRange (+25 more)

### Community 4 - "App Bootstrap & DI"
Cohesion: 0.06
Nodes (29): app.dart, app_routes.dart, di/service_locator.dart, env_config.dart, ../../features/auth/bloc/auth_cubit.dart, ../features/auth/di/auth_dependencies.dart, ../../features/auth/views/login_view.dart, ../../features/booking/bloc/schedule_cubit.dart (+21 more)

### Community 5 - "Login Contract Strings & Validators"
Cohesion: 0.08
Nodes (25): dart:async, FormFieldValidator, appBarTitle, demoEmail, demoPassword, description, dispose, emailLabel (+17 more)

### Community 6 - "Platform Runner Build Files"
Cohesion: 0.10
Nodes (26): Launch Screen Assets README, Linux top-level CMakeLists.txt, Linux Flutter build rules CMakeLists.txt, Linux runner CMakeLists.txt, Khelam Project Memory, All-platform baseline goal (rationale: main branch stays ready for Android, iOS, web, macOS, Windows, Linux; mobile-only branch later), dio for HTTP networking (rationale: interceptors, cancellation, upload/download, timeouts, adapters, global config), drift for SQLite (rationale: reactive persistence built on SQLite, strong default for scalable local relational data) (+18 more)

### Community 7 - "Linux GTK Plugin Registrant"
Cohesion: 0.10
Nodes (20): FlPluginRegistry, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins(), main() (+12 more)

### Community 8 - "Booking Models (Freezed)"
Cohesion: 0.09
Nodes (23): @freezed, booking.dart, Booking, fromJson, ScheduleSlotItem, _ScheduleSlotItem, ScheduleSlotItem, slot.dart (+15 more)

### Community 9 - "Booking JSON Parsing"
Cohesion: 0.10
Nodes (20): Booking, booking_status.dart, _amountToDouble, fromJson, _Booking, package:freezed_annotation/freezed_annotation.dart, _, BookingPatterns (+12 more)

### Community 10 - "Turf Summary Model"
Cohesion: 0.11
Nodes (19): int get, fromJson, TurfSummary, String get, TurfSummary, _, class, hashCode (+11 more)

### Community 11 - "Slot Model"
Cohesion: 0.11
Nodes (19): fromJson, Slot, return, Slot, slot_status.dart, _, class, hashCode (+11 more)

### Community 12 - "Auth User Model"
Cohesion: 0.12
Nodes (18): AuthUser, AuthUser, fromJson, T, _, AuthUserPatterns, class, hashCode (+10 more)

### Community 13 - "Dio HTTP Client Layer"
Cohesion: 0.12
Nodes (16): dart:convert, dart:typed_data, Dio, HttpClientAdapter, package:dio/dio.dart, package:khelam/features/booking/data/booking_api_service.dart, RequestOptions?, close (+8 more)

### Community 14 - "Mock Booking Service"
Cohesion: 0.12
Nodes (15): _bookingId, bookSlot, _closeHour, _customerNames, _extraBookedSlotIds, getSchedule, getTurf, _isSlotBooked (+7 more)

### Community 15 - "App Theme Light/Dark"
Cohesion: 0.13
Nodes (16): _, AppTheme, colorSchemeFor, dark, darkColorScheme, errorColor, errorColorDark, forBrightness (+8 more)

### Community 16 - "Schedule Cubit State Machine"
Cohesion: 0.13
Nodes (14): bookingCount, bookSlot, _computeStats, copyWith, _defaultTurfId, errorMessage, isLoading, load (+6 more)

### Community 17 - "Router & App Shell"
Cohesion: 0.15
Nodes (12): Brightness?, GoRouter, build, KhelamApp, router, HomeView, brightness, build (+4 more)

### Community 18 - "Superpowers Planning Docs"
Cohesion: 0.33
Nodes (14): Booking Bottom Sheet — Iteration Checklist, BookingConfirmationSheet widget composing FormBottomSheet + PhoneInput, customerPhone field on Booking freezed model, FormBottomSheet generic widget (title, body, Confirm/Cancel CTAs, confirmEnabled gate, drag-to-dismiss), PhoneInput widget (10-digit Indian mobile validation, +91 prefix, maxLength 10), Book Available Slots Implementation Plan, bookSlot flow (BookingService interface → MockBookingService in-memory mutation → BookingRepository → ScheduleCubit with optimistic state update), Booking Bottom Sheet Implementation Plan (+6 more)

### Community 19 - "Auth Cubit & Login Contracts"
Cohesion: 0.17
Nodes (12): ../contracts/login_contract.dart, Cubit, AuthCubit, AuthState, LoginAsyncDataImpl, _asyncData, build, createState (+4 more)

### Community 20 - "Schedule Cubit Tests"
Cohesion: 0.15
Nodes (12): package:khelam/features/booking/bloc/schedule_cubit.dart, package:khelam/features/booking/booking_service.dart, package:khelam/features/booking/models/turf_summary.dart, Set, bookedSlotIds, bookSlot, fakeService, getSchedule (+4 more)

### Community 21 - "Booking API Service"
Cohesion: 0.17
Nodes (11): DateFormat, _apiClient, bookSlot, _dateFormat, _dummyTurfAddress, _dummyTurfName, getSchedule, getTurf (+3 more)

### Community 22 - "Date Chip & Timeline Labels"
Cohesion: 0.18
Nodes (10): DateTime, build, date, _isSameDay, onTap, selected, build, time (+2 more)

### Community 23 - "Windows Runner Utilities"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 24 - "Auth Cubit State"
Cohesion: 0.18
Nodes (10): bool get, AuthStatus, copyWith, errorMessage, isAuthenticated, isLoading, login, _service (+2 more)

### Community 25 - "Widget & Service Tests"
Cohesion: 0.20
Nodes (8): package:flutter_test/flutter_test.dart, package:khelam/features/booking/data/mock_booking_service.dart, package:khelam/features/booking/models/slot.dart, package:khelam/features/booking/models/slot_status.dart, package:khelam/features/booking/widgets/available_slot_card.dart, main, main, main

### Community 26 - "Web Manifest"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 27 - "Booking Timeline Widgets"
Cohesion: 0.20
Nodes (9): available_slot_card.dart, booked_slot_card.dart, build, _buildCard, _buildRows, items, ../models/slot_status.dart, timeline_hour_label.dart (+1 more)

### Community 28 - "App Palette"
Cohesion: 0.20
Nodes (9): AppPalette, error, errorDark, secondarySeed, seed, surfaceTintDark, surfaceTintLight, tertiarySeed (+1 more)

### Community 29 - "App Routes"
Cohesion: 0.20
Nodes (9): AppRoutes, home, homePath, login, loginPath, schedule, schedulePath, themePreview (+1 more)

### Community 30 - "Booking Model Tests"
Cohesion: 0.22
Nodes (8): package:khelam/features/booking/models/booking.dart, package:khelam/features/booking/models/booking_status.dart, package:khelam/features/booking/models/schedule_slot_item.dart, package:khelam/features/booking/widgets/booked_slot_card.dart, main, _booking, main, _slot

### Community 31 - "Mock Auth Service"
Cohesion: 0.22
Nodes (8): Exception, demoEmail, demoPassword, login, message, MockAuthException, toString, static const String

### Community 32 - "Booking DI & Env Config"
Cohesion: 0.25
Nodes (7): ../booking_service.dart, ../data/booking_api_service.dart, ../data/mock_booking_service.dart, ../../../di/env_config.dart, DioApiClient, BookingDependencies, register

### Community 33 - "Auth DI & Service Locator"
Cohesion: 0.29
Nodes (6): ../auth_service.dart, ../bloc/auth_cubit.dart, ../data/mock_auth_service.dart, AuthDependencies, register, package:get_it/get_it.dart

### Community 34 - "Date Strip Widget"
Cohesion: 0.29
Nodes (6): date_chip.dart, build, dates, _isSameDay, selectedDate, List

### Community 35 - "DayStats Section"
Cohesion: 0.33
Nodes (5): ../bloc/schedule_cubit.dart, DayStats, build, DayStatsSection, stats

### Community 36 - "Booking Confirmation Sheet"
Cohesion: 0.33
Nodes (5): FilledButton, package:khelam/features/booking/widgets/booking_confirmation_sheet.dart, main, slotDate, testSlot

### Community 37 - "Booked Slot Card"
Cohesion: 0.33
Nodes (5): BookedSlotCard, build, item, onTap, package:commons/commons.dart

### Community 38 - "Home View & GoRouter"
Cohesion: 0.33
Nodes (5): build, package:go_router/go_router.dart, AppRoutes.schedule, AppRoutes.themePreview, ../../../ui/navigation/app_routes.dart

### Community 39 - "Auth Service Interface"
Cohesion: 0.40
Nodes (4): AuthService, login, MockAuthService, ../models/auth_user.dart

### Community 40 - "Booking Service Interface"
Cohesion: 0.40
Nodes (4): bookSlot, getSchedule, getTurf, ../models/schedule_slot_item.dart

### Community 41 - "Booking Service Implementations"
Cohesion: 0.40
Nodes (5): BookingService, BookingApiService, MockBookingService, FakeBookingService, _StaticSlotsService

### Community 42 - "Available Slot Card"
Cohesion: 0.40
Nodes (4): AvailableSlotCard, build, onTap, VoidCallback?

### Community 43 - "Turf Header"
Cohesion: 0.40
Nodes (4): build, turf, TurfHeader, ../models/turf_summary.dart

### Community 44 - "Freezed Generated Files"
Cohesion: 0.50
Nodes (4): @JsonSerializable, _AuthUser, _Slot, _TurfSummary

### Community 45 - "Headroom AI Dependency"
Cohesion: 0.50
Nodes (3): headroom-ai, dependencies, headroom-ai

### Community 46 - "Booking Timeline Widgets"
Cohesion: 0.50
Nodes (4): BookingTimeline, DateChip, DateStrip, m.StatelessWidget

### Community 47 - "Timeline Rail"
Cohesion: 0.50
Nodes (3): build, TimelineRail, package:flutter/material.dart

### Community 48 - "OpenCode Config & Plugin"
Cohesion: 0.50
Nodes (3): plugin, $schema, .opencode/plugins/graphify.js

## Knowledge Gaps
- **298 isolated node(s):** `$schema`, `.opencode/plugins/graphify.js`, `router`, `build`, `envValue` (+293 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **14 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `_` connect `App Theme Light/Dark` to `Booked Slot Card`, `Timeline Rail`?**
  _High betweenness centrality (0.027) - this node is a cross-community bridge._
- **Why does `AuthCubit` connect `Auth Cubit & Login Contracts` to `Auth DI & Service Locator`, `Login & Schedule Views`, `App Bootstrap & DI`, `Login Contract Strings & Validators`, `Auth Cubit State`?**
  _High betweenness centrality (0.023) - this node is a cross-community bridge._
- **Why does `FlutterWindow` connect `Windows Runner Boilerplate` to `Flutter Engine macOS Bindings`?**
  _High betweenness centrality (0.016) - this node is a cross-community bridge._
- **What connects `$schema`, `.opencode/plugins/graphify.js`, `router` to the rest of the system?**
  _298 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Windows Runner Boilerplate` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._
- **Should `Architecture & Docs Concepts` be split into smaller, more focused modules?**
  _Cohesion score 0.14169570267131243 - nodes in this community are weakly interconnected._
- **Should `Flutter Engine macOS Bindings` be split into smaller, more focused modules?**
  _Cohesion score 0.06825396825396825 - nodes in this community are weakly interconnected._