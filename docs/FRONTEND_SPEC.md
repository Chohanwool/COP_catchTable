# Frontend Technical Specification
# Catch Table - Flutter Application

**Version:** 1.0
**Last Updated:** 2025-11-14
**Framework:** Flutter 3.24+
**Target Platform:** iOS/Android Tablets

---

## 1. Architecture Overview

### 1.1 Architecture Pattern
**Layered Architecture with Riverpod State Management**

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Screens    │  │   Widgets    │  │  Components  │  │
│  │ (Routes)     │  │ (Reusable)   │  │  (UI Atoms)  │  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │
│         │                 │                 │           │
│         └─────────────────┴─────────────────┘           │
│                           │                             │
└───────────────────────────┼─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                   State Management Layer                │
│  ┌────────────────────────────────────────────────────┐ │
│  │         Riverpod Providers (Business Logic)        │ │
│  │  - QueueProvider                                   │ │
│  │  - RegistrationProvider                            │ │
│  │  - AnalyticsProvider                               │ │
│  │  - StoreConfigProvider                             │ │
│  └────────────────────┬───────────────────────────────┘ │
└───────────────────────┼─────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────┐
│                      Data Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Repositories │  │    Models    │  │  Data Sources│  │
│  │              │  │  (Freezed)   │  │              │  │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤  │
│  │ - Queue      │  │ - Queue      │  │ - Firestore  │  │
│  │ - Store      │  │ - Store      │  │ - Hive Cache │  │
│  │ - Analytics  │  │ - Analytics  │  │              │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### 1.2 Project Structure (Proposed)

```
lib/
├── main.dart                              # App entry point + Riverpod setup
│
├── app/
│   ├── app.dart                          # MaterialApp configuration
│   ├── router.dart                       # GoRouter configuration
│   └── theme.dart                        # Theme data (colors, typography)
│
├── features/                             # Feature-based modules
│   ├── registration/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── queue_registration_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── registration_step_phone.dart
│   │   │   │   ├── registration_step_group.dart
│   │   │   │   └── registration_step_confirm.dart
│   │   │   └── providers/
│   │   │       └── registration_provider.dart
│   │   ├── domain/
│   │   │   └── models/
│   │   │       └── registration.dart      # Freezed model
│   │   └── data/
│   │       └── repositories/
│   │           └── registration_repository.dart
│   │
│   ├── queue/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── waiting_list_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── queue_item_card.dart
│   │   │   │   ├── queue_filter_tabs.dart
│   │   │   │   └── queue_action_buttons.dart
│   │   │   └── providers/
│   │   │       └── queue_provider.dart
│   │   ├── domain/
│   │   │   └── models/
│   │   │       └── queue_entry.dart       # Freezed model
│   │   └── data/
│   │       └── repositories/
│   │           └── queue_repository.dart
│   │
│   ├── analytics/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── analytics_dashboard_screen.dart
│   │   │   └── widgets/
│   │   │       ├── metric_card.dart
│   │   │       └── stats_chart.dart
│   │   ├── domain/
│   │   │   └── models/
│   │   │       └── analytics_data.dart
│   │   └── data/
│   │       └── repositories/
│   │           └── analytics_repository.dart
│   │
│   └── settings/
│       ├── presentation/
│       │   ├── screens/
│       │   │   └── settings_screen.dart
│       │   └── widgets/
│       │       └── store_info.dart        # Moved from root widgets/
│       ├── domain/
│       │   └── models/
│       │       └── store_config.dart
│       └── data/
│           └── repositories/
│               └── store_repository.dart
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart               # Color palette
│   │   ├── app_sizes.dart                # Spacing, radius constants
│   │   └── app_strings.dart              # Localized strings
│   │
│   ├── extensions/
│   │   ├── string_extensions.dart        # Phone formatting
│   │   ├── datetime_extensions.dart      # Time formatting
│   │   └── context_extensions.dart       # Theme access shortcuts
│   │
│   ├── utils/
│   │   ├── responsive_helper.dart        # .sp(), .hsp(), .fsp()
│   │   ├── validators.dart               # Form validation
│   │   └── logger.dart                   # Debug logging
│   │
│   ├── error/
│   │   ├── exceptions.dart               # Custom exceptions
│   │   └── failures.dart                 # Error handling
│   │
│   └── widgets/                          # Global reusable widgets
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── loading_indicator.dart
│       └── error_view.dart
│
├── services/
│   ├── firebase/
│   │   ├── firestore_service.dart        # Firestore CRUD operations
│   │   ├── auth_service.dart             # Firebase Auth
│   │   └── messaging_service.dart        # FCM (future)
│   │
│   ├── local_storage/
│   │   └── hive_service.dart             # Offline cache
│   │
│   └── notification/
│       └── sms_service.dart              # Mock → Cloud Function
│
└── shared/
    ├── models/
    │   └── base_model.dart               # Base interfaces
    └── providers/
        └── app_state_provider.dart       # Global app state

test/
├── unit/
│   ├── models/
│   ├── repositories/
│   └── providers/
├── widget/
│   └── screens/
└── integration/
    └── flows/
```

---

## 2. State Management with Riverpod

### 2.1 Provider Types & Usage

#### 2.1.1 Queue Provider (StreamProvider)
```dart
// lib/features/queue/presentation/providers/queue_provider.dart

@riverpod
Stream<List<QueueEntry>> queueStream(QueueStreamRef ref, QueueStatus status) {
  final repository = ref.watch(queueRepositoryProvider);
  return repository.watchQueueByStatus(status);
}

@riverpod
class QueueController extends _$QueueController {
  @override
  FutureOr<void> build() {}

  Future<void> callNext(String queueId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(queueRepositoryProvider);
      await repository.updateStatus(queueId, QueueStatus.called);
      // Trigger SMS via Cloud Function
      await ref.read(smsServiceProvider).sendCallNotification(queueId);
    });
  }

  Future<void> seatCustomer(String queueId, int? tableNumber) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(queueRepositoryProvider).seatCustomer(queueId, tableNumber);
    });
  }

  Future<void> cancelRegistration(String queueId, String reason) async {
    state = await AsyncValue.guard(() async {
      await ref.read(queueRepositoryProvider).cancel(queueId, reason);
    });
  }
}
```

#### 2.1.2 Registration Provider (StateNotifier)
```dart
// lib/features/registration/presentation/providers/registration_provider.dart

@riverpod
class RegistrationForm extends _$RegistrationForm {
  @override
  Registration build() {
    return const Registration();
  }

  void updatePhone(String phone) {
    state = state.copyWith(phoneNumber: phone);
  }

  void updateGroupSize(int size) {
    state = state.copyWith(groupSize: size);
  }

  Future<String> submit() async {
    final repository = ref.read(registrationRepositoryProvider);
    final queueNumber = await repository.createRegistration(state);

    // Reset form
    state = const Registration();

    return queueNumber;
  }

  void reset() {
    state = const Registration();
  }
}
```

#### 2.1.3 Analytics Provider
```dart
// lib/features/analytics/presentation/providers/analytics_provider.dart

@riverpod
Stream<AnalyticsData> todayAnalytics(TodayAnalyticsRef ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.watchTodayMetrics();
}

@riverpod
Future<List<DailyStats>> historicalStats(
  HistoricalStatsRef ref,
  DateTime startDate,
  DateTime endDate,
) async {
  final repository = ref.read(analyticsRepositoryProvider);
  return repository.getHistoricalData(startDate, endDate);
}
```

### 2.2 Dependency Injection

```dart
// lib/main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox<QueueEntry>('queue_cache');

  runApp(
    ProviderScope(
      observers: [RiverpodLogger()],
      child: const CatchTableApp(),
    ),
  );
}

// Services registration
@riverpod
FirestoreService firestoreService(FirestoreServiceRef ref) {
  return FirestoreService(FirebaseFirestore.instance);
}

@riverpod
HiveService hiveService(HiveServiceRef ref) {
  return HiveService(Hive.box('queue_cache'));
}

@riverpod
QueueRepository queueRepository(QueueRepositoryRef ref) {
  return QueueRepository(
    firestoreService: ref.watch(firestoreServiceProvider),
    hiveService: ref.watch(hiveServiceProvider),
  );
}
```

---

## 3. Data Models (Freezed)

### 3.1 Queue Entry Model

```dart
// lib/features/queue/domain/models/queue_entry.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'queue_entry.freezed.dart';
part 'queue_entry.g.dart';

@freezed
class QueueEntry with _$QueueEntry {
  const QueueEntry._();

  const factory QueueEntry({
    required String id,
    required String queueNumber,
    required String phoneNumber,
    required int groupSize,
    required QueueStatus status,
    required DateTime registeredAt,
    DateTime? calledAt,
    DateTime? seatedAt,
    DateTime? cancelledAt,
    int? tableNumber,
    String? cancellationReason,
    @Default(0) int callCount,
  }) = _QueueEntry;

  factory QueueEntry.fromJson(Map<String, dynamic> json) =>
      _$QueueEntryFromJson(json);

  // Computed properties
  String get maskedPhone {
    if (phoneNumber.length < 11) return phoneNumber;
    return '${phoneNumber.substring(0, 4)}-***-${phoneNumber.substring(8)}';
  }

  Duration get waitTime {
    final endTime = seatedAt ?? DateTime.now();
    return endTime.difference(registeredAt);
  }

  String get formattedWaitTime {
    final minutes = waitTime.inMinutes;
    final seconds = waitTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get isNoShow => callCount >= 3 && status == QueueStatus.called;
}

@JsonEnum()
enum QueueStatus {
  @JsonValue('waiting')
  waiting,
  @JsonValue('called')
  called,
  @JsonValue('seated')
  seated,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('noShow')
  noShow,
}
```

### 3.2 Registration Model (Updated)

```dart
// lib/features/registration/domain/models/registration.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'registration.freezed.dart';
part 'registration.g.dart';

@freezed
class Registration with _$Registration {
  const Registration._();

  const factory Registration({
    String? phoneNumber,
    int? groupSize,
  }) = _Registration;

  factory Registration.fromJson(Map<String, dynamic> json) =>
      _$RegistrationFromJson(json);

  bool get isPhoneValid {
    if (phoneNumber == null) return false;
    final cleaned = phoneNumber!.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length >= 10 && cleaned.length <= 12;
  }

  bool get isGroupSizeValid => groupSize != null && groupSize! >= 1 && groupSize! <= 20;

  bool get isComplete => isPhoneValid && isGroupSizeValid;

  String get formattedPhoneNumber {
    return phoneNumber?.formatPhoneNumber() ?? '';
  }
}
```

### 3.3 Analytics Data Model

```dart
// lib/features/analytics/domain/models/analytics_data.dart

@freezed
class AnalyticsData with _$AnalyticsData {
  const factory AnalyticsData({
    required int totalRegistrations,
    required int currentWaiting,
    required int totalSeated,
    required int totalCancelled,
    required int totalNoShows,
    required Duration averageWaitTime,
    required double noShowRate,
    required DateTime date,
  }) = _AnalyticsData;

  factory AnalyticsData.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsDataFromJson(json);
}

@freezed
class DailyStats with _$DailyStats {
  const factory DailyStats({
    required DateTime date,
    required int registrations,
    required double avgWaitMinutes,
    required int noShows,
  }) = _DailyStats;

  factory DailyStats.fromJson(Map<String, dynamic> json) =>
      _$DailyStatsFromJson(json);
}
```

### 3.4 Store Config Model

```dart
// lib/features/settings/domain/models/store_config.dart

@freezed
class StoreConfig with _$StoreConfig {
  const factory StoreConfig({
    required String id,
    required String name,
    required String logoUrl,
    required String phoneNumber,
    required String address,
    @Default('09:00') String openingTime,
    @Default('22:00') String closingTime,
    @Default(15) int averageServiceMinutes,
    @Default(true) bool isActive,
  }) = _StoreConfig;

  factory StoreConfig.fromJson(Map<String, dynamic> json) =>
      _$StoreConfigFromJson(json);
}
```

---

## 4. Screen Specifications

### 4.1 Queue Registration Screen

**File:** `lib/features/registration/presentation/screens/queue_registration_screen.dart`

**Layout:**
- Split screen: StoreInfo (left 40%) | Registration Steps (right 60%)
- Responsive height allocation using LayoutBuilder

**State:**
- Current step: `RegistrationStep` enum (phone, group, confirm)
- Form data: `Registration` from Riverpod provider
- Navigation: Sequential with back button support

**Step Widgets:**

#### 4.1.1 Registration Step: Phone
- Custom numeric keypad (3x4 grid + backspace)
- Real-time phone formatting display
- Validation on "Next" tap
- Error messages below input field

**Widget Props:**
```dart
class RegistrationStepPhone extends ConsumerWidget {
  const RegistrationStepPhone({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;
}
```

#### 4.1.2 Registration Step: Group
- PageView horizontal slider
- Large number display (context.fsp(120))
- Visual indicator dots
- Swipe + tap navigation

#### 4.1.3 Registration Step: Confirm
- Read-only summary display
- Queue number preview (from provider)
- Estimated wait position (calculated from queue count)
- Dual buttons: Back (edit) | Confirm (submit)

**Submit Flow:**
```dart
Future<void> _onConfirm() async {
  final provider = ref.read(registrationFormProvider.notifier);

  try {
    final queueNumber = await provider.submit();

    if (mounted) {
      // Show success dialog
      showDialog(
        context: context,
        builder: (_) => SuccessDialog(queueNumber: queueNumber),
      );

      // Reset to step 1 after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        setState(() => _currentStep = RegistrationStep.phone);
      });
    }
  } catch (e) {
    // Show error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

### 4.2 Waiting List Screen

**File:** `lib/features/queue/presentation/screens/waiting_list_screen.dart`

**Layout:**
```
┌──────────────────────────────────────────┐
│  [< Back]           Queue List           │
├──────────────────────────────────────────┤
│  [Waiting] [Called] [History]  (Tabs)    │
├──────────────────────────────────────────┤
│  ┌────────────────────────────────────┐  │
│  │ Queue Item Card                    │  │
│  │ Q-20251114-001  |  0917-***-4567   │  │
│  │ 👥 4 guests     |  ⏱️ 12:34        │  │
│  │ [Call] [Cancel] [No-show]          │  │
│  └────────────────────────────────────┘  │
│  ┌────────────────────────────────────┐  │
│  │ ...                                │  │
├──────────────────────────────────────────┤
│  Total Waiting: 8                        │
└──────────────────────────────────────────┘
```

**Riverpod Usage:**
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final selectedTab = useState(QueueStatus.waiting);
  final queueStream = ref.watch(queueStreamProvider(selectedTab.value));

  return queueStream.when(
    data: (entries) => ListView.builder(
      itemCount: entries.length,
      itemBuilder: (ctx, idx) => QueueItemCard(entry: entries[idx]),
    ),
    loading: () => const LoadingIndicator(),
    error: (err, stack) => ErrorView(message: err.toString()),
  );
}
```

**Queue Item Card Actions:**
- **Call Button:** Transitions to "Called", triggers SMS (mock)
- **Seat Button:** Shows table number dialog → transitions to "Seated"
- **Cancel Button:** Shows reason dialog → marks cancelled
- **No-show Button:** Confirmation dialog → marks no-show

### 4.3 Analytics Dashboard Screen

**File:** `lib/features/analytics/presentation/screens/analytics_dashboard_screen.dart`

**Layout:**
```
┌──────────────────────────────────────────┐
│         Today's Performance              │
├──────────────────────────────────────────┤
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  │
│  │   42    │  │   8     │  │  18:30  │  │
│  │ Total   │  │ Waiting │  │ Avg Wait│  │
│  └─────────┘  └─────────┘  └─────────┘  │
│  ┌─────────┐  ┌─────────┐               │
│  │   3     │  │  7.1%   │               │
│  │ No-show │  │ Rate    │               │
│  └─────────┘  └─────────┘               │
├──────────────────────────────────────────┤
│       Historical Trends (Chart)          │
│       [Last 7 Days ▼]                    │
└──────────────────────────────────────────┘
```

**Metrics Cards:**
```dart
class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;
}
```

---

## 5. Routing (GoRouter)

### 5.1 Route Configuration

```dart
// lib/app/router.dart

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/registration',
    routes: [
      GoRoute(
        path: '/registration',
        name: 'registration',
        builder: (context, state) => const QueueRegistrationScreen(),
      ),
      GoRoute(
        path: '/queue',
        name: 'queue',
        builder: (context, state) => const WaitingListScreen(),
      ),
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsDashboardScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
});

// Usage in main.dart
class CatchTableApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.light,
    );
  }
}
```

### 5.2 Navigation Examples

```dart
// Navigate to queue list
context.pushNamed('queue');

// Navigate with data
context.pushNamed('analytics', extra: {'period': 'weekly'});

// Go back
context.pop();
```

---

## 6. Responsive Design

### 6.1 Responsive Helper Usage

```dart
// lib/core/utils/responsive_helper.dart

extension ResponsiveExtension on BuildContext {
  double sp(double size) {
    final width = MediaQuery.of(this).size.width;
    return (size / 1024) * width;  // Base: iPad Pro 12.9" width
  }

  double hsp(double size) {
    final height = MediaQuery.of(this).size.height;
    return (size / 1366) * height;  // Base: iPad Pro 12.9" height
  }

  double fsp(double size) {
    final shortestSide = MediaQuery.of(this).size.shortestSide;
    return (size / 1024) * shortestSide;
  }
}

// Usage in widgets
Text(
  'Queue Number',
  style: TextStyle(fontSize: context.fsp(46)),
)

SizedBox(height: context.hsp(80))

Container(width: context.sp(400))
```

### 6.2 Layout Breakpoints

```dart
// lib/core/constants/app_sizes.dart

class AppSizes {
  // Spacing
  static const double spacing8 = 8.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;

  // Touch targets
  static const double minTouchTarget = 44.0;

  // Screen ratios (for LayoutBuilder)
  static const double inputAreaRatio = 0.60;
  static const double buttonAreaRatio = 0.15;
  static const double headerRatio = 0.10;
}
```

---

## 7. Theme Configuration

### 7.1 Color Palette

```dart
// lib/core/constants/app_colors.dart

class AppColors {
  // Primary
  static const Color primary = Color(0xFFF06F1A);  // Orange
  static const Color primaryDark = Color(0xFFD85A0A);
  static const Color primaryLight = Color(0xFFFF9D5C);

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey700 = Color(0xFF616161);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Queue Status
  static const Color statusWaiting = Color(0xFF2196F3);
  static const Color statusCalled = Color(0xFFFFC107);
  static const Color statusSeated = Color(0xFF4CAF50);
  static const Color statusCancelled = Color(0xFF9E9E9E);
  static const Color statusNoShow = Color(0xFFF44336);
}
```

### 7.2 Theme Data

```dart
// lib/app/theme.dart

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      fontFamily: 'Inter',

      // Typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 96, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 48, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
      ),

      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(0, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
```

---

## 8. Error Handling

### 8.1 Exception Classes

```dart
// lib/core/error/exceptions.dart

class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error occurred']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache error occurred']);
}

class ValidationException implements Exception {
  final String field;
  final String message;
  ValidationException(this.field, this.message);
}
```

### 8.2 Failure Classes

```dart
// lib/core/error/failures.dart

@freezed
class Failure with _$Failure {
  const factory Failure.server(String message) = ServerFailure;
  const factory Failure.cache(String message) = CacheFailure;
  const factory Failure.validation(String field, String message) = ValidationFailure;
  const factory Failure.network(String message) = NetworkFailure;
}
```

### 8.3 Error Handling in Providers

```dart
@riverpod
class QueueController extends _$QueueController {
  @override
  FutureOr<void> build() {}

  Future<void> callNext(String queueId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        await ref.read(queueRepositoryProvider).updateStatus(
          queueId,
          QueueStatus.called,
        );
        await ref.read(smsServiceProvider).sendCallNotification(queueId);
      } on ServerException catch (e) {
        throw Failure.server(e.message);
      } on SocketException {
        throw const Failure.network('No internet connection');
      }
    });
  }
}

// UI handling
ref.listen(queueControllerProvider, (prev, next) {
  next.whenOrNull(
    error: (error, stack) {
      if (error is Failure) {
        error.when(
          server: (msg) => showErrorSnackbar(msg),
          network: (msg) => showErrorDialog('Offline', msg),
          validation: (field, msg) => showFieldError(field, msg),
          cache: (msg) => print('Cache error: $msg'),
        );
      }
    },
  );
});
```

---

## 9. Testing Strategy

### 9.1 Unit Tests

```dart
// test/unit/models/queue_entry_test.dart

void main() {
  group('QueueEntry', () {
    test('maskedPhone hides middle digits', () {
      const entry = QueueEntry(
        id: '1',
        queueNumber: 'Q-001',
        phoneNumber: '09171234567',
        groupSize: 4,
        status: QueueStatus.waiting,
        registeredAt: DateTime(2025, 1, 1),
      );

      expect(entry.maskedPhone, '0917-***-4567');
    });

    test('waitTime calculates correctly', () {
      final registered = DateTime(2025, 1, 1, 10, 0);
      final entry = QueueEntry(
        id: '1',
        queueNumber: 'Q-001',
        phoneNumber: '09171234567',
        groupSize: 4,
        status: QueueStatus.waiting,
        registeredAt: registered,
      );

      // Mock current time to 10:15
      final waitTime = DateTime(2025, 1, 1, 10, 15).difference(registered);
      expect(waitTime.inMinutes, 15);
    });
  });
}
```

### 9.2 Widget Tests

```dart
// test/widget/screens/queue_registration_screen_test.dart

void main() {
  testWidgets('displays phone input step initially', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: QueueRegistrationScreen(),
        ),
      ),
    );

    expect(find.text('Enter Phone Number'), findsOneWidget);
    expect(find.byType(RegistrationStepPhone), findsOneWidget);
  });

  testWidgets('navigates to group size after valid phone', (tester) async {
    await tester.pumpWidget(/* ... */);

    // Enter valid phone
    await tester.tap(find.text('0'));
    await tester.tap(find.text('9'));
    // ... enter full number

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.byType(RegistrationStepGroup), findsOneWidget);
  });
}
```

### 9.3 Integration Tests

```dart
// test/integration/flows/registration_flow_test.dart

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('complete registration flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Step 1: Phone
    await tester.enterText(find.byKey(Key('phone_input')), '09171234567');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 2: Group size
    await tester.drag(find.byType(PageView), Offset(-200, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 3: Confirm
    expect(find.text('0917-123-4567'), findsOneWidget);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    // Verify success
    expect(find.text('Registration Successful'), findsOneWidget);
  });
}
```

---

## 10. Performance Optimization

### 10.1 ListView Optimization

```dart
// Use ListView.builder for large lists
ListView.builder(
  itemCount: entries.length,
  itemBuilder: (context, index) {
    final entry = entries[index];
    return QueueItemCard(
      key: ValueKey(entry.id),  // Stable key for diffing
      entry: entry,
    );
  },
)
```

### 10.2 Image Caching

```dart
// Use cached_network_image for logos
CachedNetworkImage(
  imageUrl: storeConfig.logoUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  memCacheWidth: 200,  // Resize for memory efficiency
)
```

### 10.3 Firestore Query Optimization

```dart
// Index only necessary fields
query
  .where('status', isEqualTo: 'waiting')
  .where('registeredAt', isGreaterThan: todayStart)
  .orderBy('registeredAt')
  .limit(50);  // Limit results
```

---

## 11. Accessibility

### 11.1 Semantic Labels

```dart
Semantics(
  label: 'Call customer button',
  button: true,
  child: ElevatedButton(
    onPressed: onCall,
    child: Text('Call'),
  ),
)
```

### 11.2 Minimum Touch Targets

```dart
// Ensure all interactive elements are at least 44x44 dp
ConstrainedBox(
  constraints: BoxConstraints(minWidth: 44, minHeight: 44),
  child: IconButton(
    icon: Icon(Icons.close),
    onPressed: onClose,
  ),
)
```

---

## 12. Build & Deployment

### 12.1 Flavor Configuration

```dart
// lib/app/flavor_config.dart

enum Flavor { dev, staging, production }

class FlavorConfig {
  final Flavor flavor;
  final String apiBaseUrl;
  final bool enableLogging;

  FlavorConfig._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.enableLogging,
  });

  static FlavorConfig? _instance;

  static FlavorConfig get instance => _instance!;

  static void configure(Flavor flavor) {
    _instance = FlavorConfig._(
      flavor: flavor,
      apiBaseUrl: _getApiUrl(flavor),
      enableLogging: flavor != Flavor.production,
    );
  }

  static String _getApiUrl(Flavor flavor) {
    switch (flavor) {
      case Flavor.dev:
        return 'https://dev-api.catchtable.com';
      case Flavor.staging:
        return 'https://staging-api.catchtable.com';
      case Flavor.production:
        return 'https://api.catchtable.com';
    }
  }
}

// lib/main_dev.dart
void main() {
  FlavorConfig.configure(Flavor.dev);
  runApp(const CatchTableApp());
}
```

### 12.2 Build Commands

```bash
# Development
flutter run --flavor dev --target lib/main_dev.dart

# Staging
flutter build apk --flavor staging --target lib/main_staging.dart

# Production
flutter build apk --release --flavor production --target lib/main_production.dart
flutter build ios --release --flavor production --target lib/main_production.dart
```

---

## 13. Dependencies (Updated pubspec.yaml)

```yaml
name: catch_table
description: Restaurant queue management system
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Firebase
  firebase_core: ^2.24.0
  cloud_firestore: ^4.13.6
  firebase_auth: ^4.15.3
  firebase_analytics: ^10.7.4

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Code Generation
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

  # Routing
  go_router: ^13.0.0

  # UI
  cached_network_image: ^3.3.0
  flutter_hooks: ^0.20.4
  hooks_riverpod: ^2.4.9

  # Utils
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Linting
  flutter_lints: ^3.0.0

  # Code Generation
  build_runner: ^2.4.6
  freezed: ^2.4.5
  json_serializable: ^6.7.1
  riverpod_generator: ^2.3.9
  riverpod_lint: ^2.3.7

  # Testing
  mocktail: ^1.0.1
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/icons/

  fonts:
    - family: Inter
      fonts:
        - asset: fonts/Inter-Regular.ttf
        - asset: fonts/Inter-Medium.ttf
          weight: 500
        - asset: fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: fonts/Inter-Bold.ttf
          weight: 700
```

---

## 14. Code Generation Commands

```bash
# Generate Freezed + JSON serialization
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on file save)
flutter pub run build_runner watch --delete-conflicting-outputs

# Generate Riverpod providers
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 15. Migration Checklist (Current → Target Architecture)

- [ ] Install dependencies (Riverpod, Freezed, GoRouter, Hive)
- [ ] Run code generation setup
- [ ] Create folder structure (features/, core/, services/)
- [ ] Convert models to Freezed (Registration, QueueEntry, etc.)
- [ ] Create repository interfaces
- [ ] Implement Firestore service
- [ ] Implement Hive cache service
- [ ] Create Riverpod providers (queue, registration, analytics)
- [ ] Refactor QueueRegistrationScreen to use Riverpod
- [ ] Refactor WaitingListScreen to use StreamProvider
- [ ] Implement GoRouter routes
- [ ] Update main.dart with ProviderScope
- [ ] Migrate StoreInfo to settings feature
- [ ] Create analytics dashboard screen
- [ ] Implement error handling layer
- [ ] Write unit tests for models
- [ ] Write widget tests for screens
- [ ] Write integration tests for flows
- [ ] Remove unused dependencies (flutter_libphonenumber)
- [ ] Update CLAUDE.md with new architecture

---

**End of Frontend Specification**
