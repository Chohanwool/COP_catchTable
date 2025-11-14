# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Project Overview

**Catch Table** is a restaurant queue management system designed for tablet kiosks. The app enables restaurant staff to efficiently manage walk-in customers through a streamlined registration and queue tracking interface.

**Target Market:** Philippines (initial launch)
**Platform:** Flutter (iOS/Android tablets)
**Backend:** Firebase (Firestore, Cloud Functions, Authentication)
**Current Phase:** MVP Development (Phase 1)

---

## 📚 Documentation Structure

All project documentation is located in the `/docs` directory:

### Core Documents
1. **[PRD.md](docs/PRD.md)** - Product Requirements Document
   - Product vision, scope, and functional requirements
   - User stories and success criteria
   - Mock data annotations (🔶 markers indicate mocked features)

2. **[FRONTEND_SPEC.md](docs/FRONTEND_SPEC.md)** - Frontend Technical Specification
   - Flutter architecture (Riverpod state management)
   - Screen specifications and UI flows
   - Data models (Freezed), routing (GoRouter)
   - Responsive design guidelines

3. **[BACKEND_SPEC.md](docs/BACKEND_SPEC.md)** - Backend Technical Specification
   - Firebase Firestore schema
   - Cloud Functions (triggers, callable, scheduled)
   - Security rules and authentication
   - Third-party integrations (Twilio/Semaphore SMS)

4. **[FEATURE_SUMMARY.md](docs/FEATURE_SUMMARY.md)** - Feature Overview
   - Phase-based feature breakdown (MVP → Future)
   - Implementation status tracking
   - Mock vs production implementations
   - Development timeline estimates

### Quick Reference
- **Stuck on architecture?** → Read FRONTEND_SPEC.md Section 1-2
- **Need Firestore schema?** → Read BACKEND_SPEC.md Section 2
- **What's mocked vs real?** → Read FEATURE_SUMMARY.md "Mock Data Summary"
- **Roadmap unclear?** → See "Development Roadmap" section below

---

## 🚀 Development Roadmap (Auto-Generated)

### Current Status: Phase 1 - MVP (In Progress)

**Completed:**
- ✅ Multi-step registration UI (Phone → Group → Confirm)
- ✅ Philippine phone number formatting
- ✅ Custom numeric keypad
- ✅ PageView slider for group size
- ✅ Responsive design system (iPad Pro 12.9" base)

**Next Steps (Phase 1 - MVP):**

#### Step 1: Project Setup & Architecture Migration (Week 1-2)
```bash
# Install new dependencies
flutter pub add flutter_riverpod riverpod_annotation freezed_annotation json_annotation go_router hive hive_flutter firebase_core cloud_firestore firebase_auth

# Dev dependencies
flutter pub add -d build_runner freezed json_serializable riverpod_generator riverpod_lint
```

**Tasks:**
1. Create new folder structure (features-based architecture)
   - See FRONTEND_SPEC.md Section 1.2 for complete structure
2. Set up Firebase project
   - Create Firebase project in console
   - Add Android/iOS apps
   - Download google-services.json and GoogleService-Info.plist
3. Initialize Riverpod in main.dart
4. Set up code generation
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

#### Step 2: Data Layer Migration (Week 2-3)
**Priority: HIGH - Foundation for all features**

1. **Create Firestore Service** (`lib/services/firebase/firestore_service.dart`)
   - CRUD operations abstraction
   - Error handling wrapper

2. **Convert Models to Freezed**
   - `lib/features/registration/domain/models/registration.dart`
   - `lib/features/queue/domain/models/queue_entry.dart`
   - `lib/features/settings/domain/models/store_config.dart`
   - `lib/features/analytics/domain/models/analytics_data.dart`
   - Run: `flutter pub run build_runner build`

3. **Implement Repositories**
   - `RegistrationRepository`: Create queue entries
   - `QueueRepository`: CRUD + real-time streams
   - `StoreRepository`: Fetch/update store config
   - `AnalyticsRepository`: Aggregate metrics

4. **Set up Hive for Offline Cache**
   - Initialize in main.dart
   - Create cache box for queue entries
   - Implement sync logic

5. **Deploy Firestore Schema**
   - Create collections: `/stores/{storeId}/queues`, `/analytics`, `/staff`
   - Deploy security rules (BACKEND_SPEC.md Section 4.1)
   - Create composite indexes (BACKEND_SPEC.md Section 7.1)

**Validation:**
```bash
# Test Firestore connection
flutter run
# Navigate to registration → Submit entry → Verify in Firebase Console
```

#### Step 3: State Management Migration (Week 3-4)
**Priority: HIGH - Enables all UI features**

1. **Create Riverpod Providers**
   - `lib/features/registration/presentation/providers/registration_provider.dart`
   - `lib/features/queue/presentation/providers/queue_provider.dart`
   - `lib/features/analytics/presentation/providers/analytics_provider.dart`

2. **Refactor QueueRegistrationScreen**
   - Replace StatefulWidget state with `ref.watch(registrationFormProvider)`
   - Use `ref.read(registrationFormProvider.notifier).submit()` for submission
   - Remove in-memory list, use Firestore stream

3. **Refactor WaitingListScreen**
   - Use `StreamProvider` for real-time queue updates
   - Implement status filtering with `ref.watch(queueStreamProvider(status))`

**Validation:**
```bash
flutter test test/unit/providers/
# All provider tests should pass
```

#### Step 4: Queue List Features (Week 4-5)
**Priority: HIGH - Core user workflow**

1. **Implement Status Filtering**
   - Add TabBar (Waiting, Called, Seated, History)
   - Filter Firestore query by status
   - Display count per tab

2. **Add Queue Item Actions**
   - **Call Button:**
     - Update status to "called"
     - Trigger mock SMS (console log)
     - Increment callCount
   - **Seat Button:**
     - Show table number dialog
     - Update status to "seated"
     - Record seatedAt timestamp
   - **Cancel Button:**
     - Show reason selection dialog
     - Update status to "cancelled"
     - Record cancellationReason
   - **No-show Button:**
     - Auto-suggest if callCount >= 3
     - Update status to "noShow"

3. **Display Metrics**
   - Queue position (calculated from Firestore count)
   - Elapsed wait time (real-time calculation)
   - Masked phone number

**Files to Create/Modify:**
- `lib/features/queue/presentation/widgets/queue_item_card.dart`
- `lib/features/queue/presentation/widgets/queue_filter_tabs.dart`
- `lib/features/queue/presentation/widgets/queue_action_buttons.dart`

**Validation:**
- Create registration → Verify in Waiting tab
- Call customer → Verify in Called tab + console log
- Seat customer → Verify in Seated/History tab
- Cancel → Verify reason saved

#### Step 5: Cloud Functions Deployment (Week 5-6)
**Priority: MEDIUM - SMS currently mocked**

1. **Initialize Firebase Functions**
   ```bash
   firebase init functions
   # Choose TypeScript
   cd functions
   npm install
   ```

2. **Implement Functions** (See BACKEND_SPEC.md Section 3)
   - `onQueueCreate`: Auto-generate queue number
   - `onQueueUpdate`: Trigger SMS on status change
   - `sendSMS`: Callable function (Twilio integration)
   - `aggregateAnalytics`: Scheduled hourly aggregation

3. **Set Environment Variables**
   ```bash
   firebase functions:config:set twilio.account_sid="YOUR_SID"
   firebase functions:config:set twilio.auth_token="YOUR_TOKEN"
   firebase functions:config:set twilio.from_number="+1234567890"
   ```

4. **Deploy**
   ```bash
   firebase deploy --only functions
   ```

5. **Update Flutter App**
   - Replace mock SMS with Cloud Function call
   - Handle success/error states

**Validation:**
- Call customer → Verify SMS received (or Twilio logs)
- Create registration → Verify queue number auto-generated

#### Step 6: Analytics Dashboard (Week 6-7)
**Priority: MEDIUM - Manager feature**

1. **Create Analytics Screen**
   - `lib/features/analytics/presentation/screens/analytics_dashboard_screen.dart`
   - Real-time metrics cards:
     - Total registrations today
     - Currently waiting count
     - Average wait time
     - No-show count & rate

2. **Implement Analytics Provider**
   - `StreamProvider` watching `/stores/{storeId}/analytics/{today}`
   - Auto-refresh every 30 seconds

3. **Add Navigation**
   - Add "Analytics" button to main menu
   - Use GoRouter for navigation

**Validation:**
- Dashboard shows accurate real-time metrics
- Metrics update after queue operations

#### Step 7: Testing & Bug Fixes (Week 7-8)
**Priority: HIGH - Launch readiness**

1. **Write Tests**
   - Unit tests for models (Freezed equality, copyWith)
   - Unit tests for providers (Riverpod testing utilities)
   - Widget tests for screens
   - Integration tests for registration flow

2. **Fix Known Issues**
   - Remove hardcoded store name (fetch from Firestore)
   - Remove hardcoded queue position (calculate dynamically)
   - Remove unused `flutter_libphonenumber` dependency

3. **Performance Optimization**
   - Implement ListView.builder with keys
   - Add image caching for store logos
   - Optimize Firestore queries (add indexes)

4. **Error Handling**
   - Add offline detection
   - Show user-friendly error messages
   - Implement retry logic

**Validation:**
```bash
flutter test --coverage
flutter analyze
# 0 errors, 0 warnings
```

#### Phase 1 Completion Checklist
- [ ] All registration flows work end-to-end
- [ ] Queue list shows real-time updates
- [ ] All status transitions work (waiting → called → seated)
- [ ] Analytics dashboard displays accurate metrics
- [ ] SMS notifications sent (mock or real)
- [ ] Offline mode functional
- [ ] All tests passing
- [ ] No critical bugs
- [ ] Performance benchmarks met (< 3s load time, < 1s Firestore updates)

---

## Development Commands

### Running the Application
```bash
# Run on connected device or emulator
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>

# Run with hot reload enabled (default)
# Press 'r' to hot reload, 'R' to hot restart
```

### Code Generation (Required after model changes)
```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Firebase Emulator (Local Development)
```bash
# Start emulators (Firestore + Functions)
firebase emulators:start

# Run app against emulators
flutter run --dart-define=USE_EMULATOR=true
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage

# View coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Check for outdated dependencies
flutter pub outdated

# Update dependencies
flutter pub get
```

### Building
```bash
# Build APK (Android)
flutter build apk

# Build for iOS (requires macOS)
flutter build ios

# Build for specific platform
flutter build <platform>  # apk, ios, web, etc.
```

---

## Architecture

### State Management
**Current (Phase 0):** Vanilla StatefulWidget with state lifting
**Migrating to:** **Riverpod 2.x** (code generation-based)

State flows down through providers, events trigger provider methods.

### Target Project Structure (Post-Migration)
```
lib/
├── main.dart                              # App entry + ProviderScope
├── app/
│   ├── app.dart                          # MaterialApp config
│   ├── router.dart                       # GoRouter routes
│   └── theme.dart                        # Theme data
│
├── features/                             # Feature modules
│   ├── registration/
│   │   ├── presentation/                 # UI layer
│   │   │   ├── screens/
│   │   │   ├── widgets/
│   │   │   └── providers/
│   │   ├── domain/                       # Business logic
│   │   │   └── models/
│   │   └── data/                         # Data layer
│   │       └── repositories/
│   ├── queue/
│   ├── analytics/
│   └── settings/
│
├── core/                                 # Shared utilities
│   ├── constants/
│   ├── extensions/
│   ├── utils/
│   ├── error/
│   └── widgets/
│
├── services/                             # External services
│   ├── firebase/
│   ├── local_storage/
│   └── notification/
│
└── shared/                               # Shared models/providers
```

See [FRONTEND_SPEC.md](docs/FRONTEND_SPEC.md) for complete architecture details.

### Current Project Structure (Phase 0 - To Be Migrated)
```
lib/
├── main.dart                           # App entry point
├── screens/
│   ├── queue_registration.dart         # Registration flow
│   └── waiting_list.dart               # Queue list
├── widgets/
│   ├── registration_step_phone.dart
│   ├── registration_step_group.dart
│   ├── registration_step_confirm.dart
│   └── store_info.dart
├── models/
│   └── registration.dart               # Will migrate to Freezed
├── data/
│   └── dummy_data.dart                 # Will remove
├── utils/
│   └── responsive_helper.dart
└── extensions/
    └── string_extensions.dart
```

---

## Key Architectural Patterns

### Multi-Step Registration Flow
The main screen orchestrates a 3-step registration process:
1. **Phone Entry** → Custom numeric keypad, validates 11 digits
2. **Group Size** → PageView-based slider (1-20 guests)
3. **Confirmation** → Read-only summary display

**Current Implementation:** Managed via `RegistrationStep` enum + `copyWith()` pattern
**Future (Riverpod):** Managed via `RegistrationFormProvider` state

### Responsive Design
All sizing uses `ResponsiveHelper` extensions based on iPad Pro 12.9" (1024x1366):
```dart
fontSize: context.fsp(46)   // Font scaling (shortest side)
height: context.hsp(200)    // Height-based scaling
width: context.sp(100)      // Width-based scaling
```

**Important:** Never use hardcoded pixel values. Always use `.sp()`, `.hsp()`, or `.fsp()` extensions.

### Layout Strategy
All step widgets use `LayoutBuilder` with ratio-based height allocation:
```dart
final inputAreaHeight = constraints.maxHeight * 0.60;
final buttonAreaHeight = constraints.maxHeight * 0.15;
```

Main screen uses split-screen layout:
- Left: `StoreInfo` sidebar (flex: 1)
- Right: Registration content (flex: 1)

Target orientation: **Landscape tablet (kiosk mode)**

---

## Domain Logic

### Registration Model (Current - Will Migrate to Freezed)
Located in `lib/models/registration.dart`:
```dart
@immutable
class Registration {
  final String? phoneNumber;  // Raw: "09171234567"
  final int? groupSize;       // 1-20

  String get formattedPhoneNumber; // "0917-123-4567"
  Registration copyWith({...});    // Immutable updates
}
```

**Migration Target (Freezed):**
```dart
@freezed
class Registration with _$Registration {
  const factory Registration({
    String? phoneNumber,
    int? groupSize,
  }) = _Registration;

  factory Registration.fromJson(Map<String, dynamic> json) =>
      _$RegistrationFromJson(json);
}
```

### Phone Number Formatting
Philippine phone numbers are handled in `lib/extensions/string_extensions.dart`:
- **Input formats supported:**
  - International: "639171234567" (12 digits)
  - Local without prefix: "9171234567" (10 digits)
  - Standard: "09171234567" (11 digits)
- **Output format:** "0917-123-4567"

The `formatPhoneNumber()` extension normalizes all formats to the standard local format with hyphens.

### Data Persistence

**Current (Phase 0):**
- In-memory storage only (`lib/data/dummy_data.dart`)
- Data lost on app restart

**Phase 1 Migration:**
- **Firestore:** Real-time database for queue entries, analytics, store config
- **Hive:** Local offline cache
- See [BACKEND_SPEC.md Section 2](docs/BACKEND_SPEC.md#2-firestore-database-schema) for schema

---

## Widget Guidelines

### Step Widget Pattern (Current)
All step widgets (`registration_step_*.dart`) follow this structure:
```dart
class RegistrationStepX extends StatefulWidget {
  final Registration registrationInfo;      // Current state (read-only)
  final ValueChanged<Registration> onNext;  // Submit data + advance
  final VoidCallback onBack;                // Navigate back

  // Local UI state (keyboard input, PageController, etc.)
  // Restore previous values from registrationInfo in initState
}
```

**Migration to Riverpod:**
```dart
class RegistrationStepX extends ConsumerWidget {
  // No need for callbacks - use ref.read() to access providers
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registration = ref.watch(registrationFormProvider);
    // ...
  }
}
```

### Button Area Consistency
All steps use identical button layout:
```dart
Row(
  children: [
    // Left button (Back or View List) - white background
    Expanded(...),
    VerticalDivider(...),
    // Right button (Next or Confirm) - orange background (#F06F1A)
    Expanded(...),
  ]
)
```

Button area height: 15% of total screen height (via `LayoutBuilder`)

### Navigation Between Screens

**Current (Imperative):**
```dart
Navigator.push(context, MaterialPageRoute(
  builder: (context) => WaitingListScreen(registrations: registrationList),
));
```

**Migration Target (GoRouter):**
```dart
context.pushNamed('queue');
```

---

## Code Conventions

### Imports
Group imports in this order:
1. Dart core libraries
2. Flutter libraries
3. Third-party packages
4. Local project files (relative imports)

### Naming
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Private members: `_leadingUnderscore`

### State Management (Post-Migration)
When adding new screens:
1. Create Riverpod provider for state
2. Use `ConsumerWidget` or `ConsumerStatefulWidget`
3. Watch providers with `ref.watch()`
4. Trigger actions with `ref.read().method()`

### Responsive Sizing
Always use responsive helpers from `lib/utils/responsive_helper.dart`:
```dart
// DO
Text('Hello', style: TextStyle(fontSize: context.fsp(24)))
SizedBox(height: context.hsp(100))

// DON'T
Text('Hello', style: TextStyle(fontSize: 24))
SizedBox(height: 100)
```

---

## Known Limitations & Technical Debt

### Phase 0 (Pre-Migration)
1. ✅ **Hardcoded values:** (Will fix in Phase 1)
   - Store name: "Mang Inasal" in `store_info.dart` → Fetch from Firestore
   - Waiting position: "number 3" in `registration_step_confirm.dart` → Calculate dynamically

2. ✅ **Unused dependency:** (Will remove in Phase 1)
   - `flutter_libphonenumber` declared but not used

3. ✅ **No persistence:** (Will fix in Phase 1)
   - All data lost on app restart → Firestore + Hive

4. ✅ **No backend integration:** (Will fix in Phase 1)
   - Purely local data → Firebase Cloud Functions

5. ✅ **Confirmation screen limitations:** (Will fix in Phase 1)
   - No actual SMS → Twilio/Semaphore integration
   - No estimated wait time → Calculate from analytics
   - No cancel ability → Add to queue list

### Migration Checklist
- [ ] Migrate to Riverpod state management
- [ ] Convert models to Freezed
- [ ] Implement Firestore integration
- [ ] Add Hive offline cache
- [ ] Deploy Cloud Functions
- [ ] Integrate SMS API
- [ ] Add GoRouter navigation
- [ ] Remove dummy_data.dart
- [ ] Remove flutter_libphonenumber

---

## Testing

The project includes `test/widget_test.dart` with basic widget tests.

**Testing Strategy (Phase 1):**
- Unit tests for Freezed models
- Unit tests for Riverpod providers
- Widget tests for screens
- Integration tests for flows
- Firebase emulator tests

See [FRONTEND_SPEC.md Section 9](docs/FRONTEND_SPEC.md#9-testing-strategy) for detailed testing guidelines.

Run tests with `flutter test` before committing.

---

## Linting

The project uses `flutter_lints` (activated in `analysis_options.yaml`). Run `flutter analyze` to check for issues. Address all analyzer warnings before committing.

---

## Platform Support

Currently supports:
- Android (Gradle-based build in `android/`)
- iOS (in `ios/`)

Target devices: **Tablets in landscape orientation** (optimized for iPad Pro 12.9")

---

## Firebase Setup (Phase 1)

### Prerequisites
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`

### Setup Steps
```bash
# Initialize Firebase in project
firebase init

# Select:
# - Firestore
# - Functions
# - Storage (optional)

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy indexes
firebase deploy --only firestore:indexes

# Deploy Cloud Functions
firebase deploy --only functions
```

See [BACKEND_SPEC.md Section 10](docs/BACKEND_SPEC.md#10-deployment) for detailed deployment instructions.

---

## Quick Start for New Developers

1. **Read Documentation (30 mins)**
   - PRD.md → Understand product vision
   - FEATURE_SUMMARY.md → See what's built vs planned
   - This file → Understand architecture

2. **Set Up Development Environment (1 hour)**
   ```bash
   # Clone repo
   git clone <repo-url>
   cd catch_table

   # Install dependencies
   flutter pub get

   # Run app
   flutter run
   ```

3. **Explore Codebase (1 hour)**
   - Start from `lib/main.dart`
   - Open `lib/screens/queue_registration.dart` (main flow)
   - Try the registration flow on emulator

4. **First Task: Simple Feature**
   - Add validation to phone input (min/max length)
   - Write unit test for validation
   - Submit PR

5. **Second Task: Data Layer**
   - Follow Step 2 of Development Roadmap
   - Set up Firestore + Freezed models
   - Pair with senior developer

---

## Support & Resources

- **Firebase Documentation:** https://firebase.google.com/docs
- **Riverpod Documentation:** https://riverpod.dev
- **Freezed Documentation:** https://pub.dev/packages/freezed
- **GoRouter Documentation:** https://pub.dev/packages/go_router
- **Flutter Documentation:** https://flutter.dev/docs

For questions or issues, contact the development team or create a GitHub issue.

---

## Version History

- **v1.0 (Current):** MVP in development
  - Registration flow completed (UI only)
  - Waiting list view (basic)
  - In-memory data storage

- **v1.1 (Target):** Phase 1 MVP Complete
  - Firestore integration
  - Cloud Functions (SMS)
  - Riverpod state management
  - Analytics dashboard

- **v2.0 (Future):** Phase 2 - Enhanced Operations
  - Reservation system
  - Table management
  - Multi-user authentication

---

**Last Updated:** 2025-11-14
**Maintained By:** Development Team
