# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Catch Table is a restaurant waiting list/queue management Flutter application designed for tablet kiosks. Customers register by entering their phone number and party size through a multi-step flow. The app targets the Philippine market with localized phone number formatting.

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

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
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

## Architecture

### State Management
This app uses **vanilla StatefulWidget with state lifting** - no external state management libraries (Provider, Riverpod, Bloc, etc.). State flows down through props, events flow up through callbacks.

### Project Structure
```
lib/
├── main.dart                           # App entry point, routes to QueueRegistrationScreen
├── screens/                            # Full-screen views
│   ├── queue_registration.dart         # Main registration flow (manages multi-step state)
│   └── waiting_list.dart               # Display all registrations
├── widgets/                            # Reusable step widgets
│   ├── registration_step_phone.dart    # Phone input with custom keypad
│   ├── registration_step_group.dart    # Group size selection (PageView slider)
│   ├── registration_step_confirm.dart  # Final confirmation display
│   └── store_info.dart                 # Left sidebar with branding/info
├── models/
│   └── registration.dart               # Core immutable model with copyWith()
├── data/
│   └── dummy_data.dart                 # In-memory mock data (not persisted)
├── utils/
│   └── responsive_helper.dart          # iPad Pro 12.9" base scaling (.sp, .hsp, .fsp)
└── extensions/
    └── string_extensions.dart          # Philippine phone number formatting
```

### Key Architectural Patterns

#### Multi-Step Registration Flow
The main screen (`queue_registration.dart`) orchestrates a 3-step registration process:
1. **Phone Entry** → Custom numeric keypad, validates 11 digits
2. **Group Size** → PageView-based slider (1-20 guests)
3. **Confirmation** → Read-only summary display

State is managed via enum `RegistrationStep { phone, group, confirm }` and merged progressively using the `Registration.copyWith()` pattern. Backward navigation preserves previously entered data.

#### State Flow Pattern
```dart
// Parent screen manages state
QueueRegistrationScreen (StatefulWidget)
├── _registration: Registration        # Current form state
├── _currentStep: RegistrationStep      # Current step
├── registrationList: List<Registration> # All registrations
│
└── Callbacks passed to child widgets:
    ├── _onNextStep(Registration)       # Merges data, advances step
    ├── _onBackStep()                   # Returns to previous step
    └── _onSubmitRegistration()         # Adds to list, resets state
```

Each step widget is stateful (manages UI state like keyboard input) but stateless regarding domain data (receives via props, emits via callbacks).

#### Responsive Design
All sizing uses `ResponsiveHelper` extensions based on iPad Pro 12.9" (1024x1366):
```dart
fontSize: context.fsp(46)   // Font scaling (shortest side)
height: context.hsp(200)    // Height-based scaling
width: context.sp(100)      // Width-based scaling
```

**Important:** Never use hardcoded pixel values. Always use `.sp()`, `.hsp()`, or `.fsp()` extensions.

#### Layout Strategy
All step widgets use `LayoutBuilder` with ratio-based height allocation:
```dart
final inputAreaHeight = constraints.maxHeight * 0.60;
final buttonAreaHeight = constraints.maxHeight * 0.15;
```

Main screen uses split-screen layout:
- Left: `StoreInfo` sidebar (flex: 1)
- Right: Registration content (flex: 1)

Target orientation: **Landscape tablet (kiosk mode)**

## Domain Logic

### Registration Model
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

Fields are nullable to support progressive form filling. Use `copyWith()` for partial updates.

### Phone Number Formatting
Philippine phone numbers are handled in `lib/extensions/string_extensions.dart`:
- **Input formats supported:**
  - International: "639171234567" (12 digits)
  - Local without prefix: "9171234567" (10 digits)
  - Standard: "09171234567" (11 digits)
- **Output format:** "0917-123-4567"

The `formatPhoneNumber()` extension normalizes all formats to the standard local format with hyphens.

### Data Persistence
Currently uses **in-memory storage only** (`lib/data/dummy_data.dart`). Data is lost on app restart. Registrations are stored in `QueueRegistrationScreen.registrationList` as a mutable list initialized from `dummyRegistrations`.

## Widget Guidelines

### Step Widget Pattern
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
Use imperative navigation:
```dart
Navigator.push(context, MaterialPageRoute(
  builder: (context) => WaitingListScreen(registrations: registrationList),
));
```

No named routes or routing packages are configured.

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

### State Management
When adding new screens with forms:
1. Keep state in parent screen (StatefulWidget)
2. Create child widgets that accept props + callbacks
3. Use `copyWith()` pattern for immutable model updates
4. Validate in parent before advancing steps

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

## Known Limitations & Technical Debt

1. **Hardcoded values:**
   - Store name: "Mang Inasal" in `store_info.dart`
   - Waiting position: "number 3" in `registration_step_confirm.dart`
   - Should be calculated dynamically based on list position

2. **Unused dependency:**
   - `flutter_libphonenumber` is declared in `pubspec.yaml` but not used
   - Phone formatting is handled by custom extension instead
   - Consider removing or integrating for validation

3. **No persistence:**
   - All data lost on app restart
   - Future: Add SharedPreferences, Hive, or SQLite

4. **No backend integration:**
   - Purely local data storage
   - No API calls or network layer

5. **Confirmation screen limitations:**
   - No actual SMS/call notification system (UI shows info only)
   - No estimated wait time calculation
   - No ability to cancel/remove registrations

## Testing

The project includes `test/widget_test.dart` with basic widget tests. When adding features:
- Write widget tests for new UI components
- Test state transitions in multi-step flows
- Verify phone number formatting edge cases
- Test responsive sizing across different screen dimensions

Run tests with `flutter test` before committing.

## Linting

The project uses `flutter_lints` (activated in `analysis_options.yaml`). Run `flutter analyze` to check for issues. Address all analyzer warnings before committing.

## Platform Support

Currently supports:
- Android (Gradle-based build in `android/`)
- iOS (in `ios/`)

Target devices: **Tablets in landscape orientation** (optimized for iPad Pro 12.9")
