# Feature Summary
# Catch Table - Restaurant Queue Management System

**Version:** 1.0
**Last Updated:** 2025-11-14

---

## Overview

This document provides a high-level summary of all features planned for Catch Table, organized by development phase.

---

## Phase 1: MVP (Essential Features)

### 1. Walk-in Registration
**Status:** 🔶 Partially Implemented

**Current Implementation:**
- ✅ Multi-step registration flow (Phone → Group Size → Confirm)
- ✅ Philippine phone number formatting
- ✅ Custom numeric keypad
- ✅ PageView slider for group size selection

**Pending:**
- 🔶 Firestore integration (currently in-memory)
- 🔶 Auto-generated queue numbers
- 🔶 Queue position calculation

**Screens:**
- `QueueRegistrationScreen` (lib/screens/queue_registration.dart)
- `RegistrationStepPhone` (lib/widgets/registration_step_phone.dart)
- `RegistrationStepGroup` (lib/widgets/registration_step_group.dart)
- `RegistrationStepConfirm` (lib/widgets/registration_step_confirm.dart)

**User Flow:**
```
1. Enter phone number (11 digits)
   → Validate format
2. Select party size (1-20)
   → Swipe or tap
3. Review & confirm
   → Auto-generate queue number
   → Display estimated wait time
4. Success
   → Show queue number
   → Return to step 1
```

---

### 2. Queue List Management
**Status:** 🔶 Partially Implemented

**Current Implementation:**
- ✅ Basic waiting list display
- ✅ In-memory data storage

**Pending:**
- 🔶 Real-time Firestore updates
- 🔶 Status filtering (Waiting, Called, Seated, History)
- 🔶 Queue position tracking
- 🔶 Elapsed wait time display
- 🔶 Action buttons (Call, Seat, Cancel, No-show)

**Screens:**
- `WaitingListScreen` (lib/screens/waiting_list.dart)

**Data Display:**
- Queue number
- Masked phone number (0917-***-4567)
- Party size
- Wait time (elapsed)
- Current status
- Action buttons

**User Flow:**
```
1. View waiting list
   → Filter by status tabs
2. Select customer
   → View details
3. Perform action:
   - Call → Send SMS + update status
   - Seat → Prompt for table number + mark seated
   - Cancel → Select reason + mark cancelled
   - No-show → Mark after 3 failed calls
```

---

### 3. Customer Notification System
**Status:** ❌ Not Implemented (Mock Only)

**Implementation Plan:**
- Cloud Function trigger on status change (waiting → called)
- Twilio/Semaphore SMS API integration
- SMS template with store name + queue number

**SMS Template:**
```
Hi! Your table at {storeName} is ready.
Please proceed to the host stand.
Queue #{queueNumber}
```

**Mock Behavior (Phase 1):**
- Button click → Console log
- Status update → Firestore only
- No actual SMS sent

**Production (Phase 2):**
- Cloud Function: `onQueueUpdate`
- Twilio integration
- SMS delivery confirmation

---

### 4. Seating Management
**Status:** ❌ Not Implemented

**Features:**
- Transition customer from "Called" → "Seated"
- Optional table number input
- Record seating timestamp
- Remove from active queue (move to history)

**UI Flow:**
```
1. Tap "Seat" on queue item
   → Show table number dialog (optional)
2. Confirm seating
   → Update status to "seated"
   → Record timestamp
3. Remove from active list
   → Move to "History" tab
```

**Data Updates:**
- `status`: "seated"
- `seatedAt`: Current timestamp
- `tableNumber`: User input (nullable)

---

### 5. Cancellation & No-show Handling
**Status:** ❌ Not Implemented

**Cancellation Features:**
- Customer-requested cancellation
- Reason dropdown:
  - Customer left
  - Wrong registration
  - Duplicate entry
  - Other (text input)
- Cancellation timestamp

**No-show Features:**
- Auto-suggest after 3 failed calls
- Manual no-show marking
- Track call count per customer

**UI Flow:**
```
Cancellation:
1. Tap "Cancel" button
   → Show reason dialog
2. Select reason + confirm
   → Update status to "cancelled"
   → Record timestamp

No-show:
1. System detects callCount >= 3
   → Show no-show suggestion
2. Confirm no-show
   → Update status to "noShow"
   → Move to history
```

---

### 6. Basic Analytics Dashboard
**Status:** ❌ Not Implemented

**Metrics (Real-time):**
- Total registrations today
- Currently waiting count
- Average wait time (registration → seated)
- No-show count & percentage
- Cancellation count & percentage

**Data Source:**
- Firestore `/stores/{storeId}/analytics/{YYYY-MM-DD}`
- Updated via Cloud Function (hourly aggregation)

**UI Layout:**
```
┌─────────────────────────────────────┐
│     Today's Performance             │
├─────────────────────────────────────┤
│ [42]       [8]        [28:30]       │
│ Total      Waiting    Avg Wait      │
│                                     │
│ [3]        [7.1%]                   │
│ No-show    Rate                     │
├─────────────────────────────────────┤
│ Hourly Breakdown (Chart - Future)  │
└─────────────────────────────────────┘
```

**Screens:**
- `AnalyticsDashboardScreen` (lib/features/analytics/presentation/screens/analytics_dashboard_screen.dart)

---

### 7. Data Persistence (Firestore)
**Status:** ❌ Not Implemented

**Migration Tasks:**
- Replace `dummy_data.dart` with Firestore queries
- Implement real-time StreamProviders
- Set up Firestore security rules
- Create composite indexes
- Implement offline cache with Hive

**Collections:**
```
/stores/{storeId}
  - Store configuration

  /queues/{queueId}
    - Queue entries

  /analytics/{dateId}
    - Daily analytics

  /staff/{staffId}
    - Staff accounts
```

**Offline Support:**
- Cache active queue in Hive
- Sync when connection restored
- Conflict resolution (last-write-wins)

---

## Phase 2: Enhanced Operations

### 8. Reservation System
**Status:** 🔮 Planned

**Features:**
- Advance booking with date/time picker
- Reservation calendar view
- Automated reminder SMS (1 hour before)
- Priority handling (reservation vs walk-in)

**Screens:**
- `ReservationScreen`
- `CalendarView`
- `ReservationForm`

**User Flow:**
```
1. Navigate to Reservations tab
2. View calendar (day/week/month)
3. Tap time slot → Create reservation
   - Customer phone
   - Party size
   - Date & time
   - Special requests (optional)
4. Confirm → Save to Firestore
5. Automated reminder (1 hour before)
```

---

### 9. Table Management Module
**Status:** 🔮 Planned

**Features:**
- Visual table layout editor
- Table status tracking:
  - Available
  - Occupied
  - Reserved
  - Cleaning
- Capacity matching (auto-suggest tables for party size)
- Seating duration tracking
- Table turnover rate calculation

**Screens:**
- `TableManagementScreen`
- `TableLayoutEditor`
- `TableStatusView`

**Data Model:**
```javascript
{
  "tableId": "T-01",
  "tableNumber": 1,
  "capacity": 4,
  "status": "occupied",
  "currentQueueId": "queue_001",
  "seatedAt": "2025-11-14T14:00:00Z",
  "estimatedTurnoverAt": "2025-11-14T15:00:00Z"
}
```

---

### 10. Multi-User Authentication
**Status:** 🔮 Planned

**Features:**
- Firebase Authentication (Email/Password)
- Role-based access control:
  - **Host:** Register, call, seat customers
  - **Manager:** All host permissions + analytics + settings
  - **Admin:** Multi-store access + user management
- Activity logs (who did what, when)

**Implementation:**
- Firebase Auth custom claims
- Firestore security rules based on roles
- Login screen with email/password
- Password reset flow

---

### 11. Real SMS Integration
**Status:** 🔮 Planned

**Migration from Mock:**
- Implement Cloud Function `onQueueUpdate`
- Integrate Twilio API (development)
- Migrate to Semaphore (production - cost savings for PH)
- SMS delivery tracking
- Retry logic on failures

**Configuration:**
- Environment variables for API keys
- SMS template management in Firestore
- Multi-language support (English/Tagalog)

---

### 12. Advanced Analytics
**Status:** 🔮 Planned

**Features:**
- Historical trends (7 days, 30 days, custom range)
- Hourly traffic patterns (heatmap)
- Peak hour identification
- Table turnover rate
- Customer return rate (phone number tracking)
- Export to CSV/PDF
- Weekly/monthly email reports

**Visualizations:**
- Line charts (daily registrations over time)
- Bar charts (hourly breakdown)
- Pie charts (status distribution)
- Heatmaps (busy hours)

**Screens:**
- `AdvancedAnalyticsScreen`
- `ReportsScreen`
- `ExportDialog`

---

## Phase 3: Customer Experience

### 13. Customer Mobile App
**Status:** 🔮 Future

**Features:**
- Self-registration via customer phone
- Real-time queue status (position updates)
- Push notifications when table is ready
- QR code check-in at restaurant
- Wait time estimates
- Rate experience after visit

**Platforms:**
- Flutter (iOS + Android)
- Public API endpoints (Cloud Functions)

**User Flow:**
```
1. Customer opens app
2. Scans QR code at restaurant
   OR enters restaurant code
3. Registers (phone + party size)
4. Receives queue number
5. Real-time status updates
6. Push notification when called
7. Check-in at host stand
```

---

### 14. Public API for Customer App
**Status:** 🔮 Future

**Endpoints:**
- `POST /api/register` - Create queue entry
- `GET /api/queue/{queueId}` - Get status
- `GET /api/store/{storeId}/status` - Current queue length + wait time
- `POST /api/checkin` - Confirm arrival
- `DELETE /api/queue/{queueId}` - Self-cancel

**Security:**
- Rate limiting (prevent spam)
- reCAPTCHA for registration
- JWT tokens for customer sessions

---

### 15. QR Code Check-in
**Status:** 🔮 Future

**Implementation:**
- Generate unique QR code per store
- Customer scans → Pre-filled registration form
- Faster check-in (no typing store code)

**QR Code Data:**
```json
{
  "storeId": "store_001",
  "storeName": "Mang Inasal - SM North EDSA",
  "action": "register"
}
```

---

## Phase 4: Intelligence & Scale

### 16. Wait Time Prediction (ML)
**Status:** 🔮 Future

**Features:**
- Machine learning model trained on historical data
- Inputs:
  - Current queue length
  - Time of day
  - Day of week
  - Party size
  - Historical avg wait time
- Output: Predicted wait time (minutes)
- Real-time adjustment based on seating pace

**Implementation:**
- TensorFlow Lite on-device model
- OR Cloud Function with ML API
- Retrain model weekly on new data

---

### 17. Multi-Store Management
**Status:** 🔮 Future

**Features:**
- Store selection/switching
- Centralized admin dashboard
- Cross-store analytics
- Store comparison reports
- Chain-wide insights

**User Roles:**
- **Store Manager:** Single store access
- **Regional Manager:** Multiple stores
- **Corporate Admin:** All stores

**Screens:**
- `StoreSelectionScreen`
- `MultiStoreAnalyticsScreen`
- `StoreComparisonReport`

---

### 18. POS Integration
**Status:** 🔮 Future

**Features:**
- Link queue entries to POS orders
- Automatic seating when order placed
- Revenue tracking per queue entry
- Average spend per party size

**Integration:**
- REST API to common POS systems
- Webhook notifications
- Order status sync

---

## Mock Data Summary

### Currently Mocked (Phase 1)

| Feature | Mock Implementation | Production Implementation |
|---------|-------------------|-------------------------|
| SMS Sending | `print()` statement | Cloud Function + Twilio/Semaphore |
| Queue Number | Hardcoded increment | Cloud Function auto-generation |
| Queue Position | Hardcoded "number 3" | Firestore query calculation |
| Store Info | Hardcoded "Mang Inasal" | Firestore `/stores/{storeId}` |
| Analytics | In-memory, resets daily | Firestore aggregation + Cloud Scheduler |
| Wait Time Estimate | Not shown | Avg of last 10 seated customers |
| Table Assignment | Manual input, no validation | Table management system |
| Data Persistence | `dummy_data.dart` (in-memory) | Firestore + Hive offline cache |

---

## Feature Dependency Matrix

```
Registration Flow
├── Firestore Integration (REQUIRED)
├── Queue Number Generation (REQUIRED)
└── Analytics Update (OPTIONAL)

Queue List
├── Firestore Real-time Streams (REQUIRED)
├── Status Filtering (REQUIRED)
└── Action Buttons (REQUIRED)
    ├── Call → SMS Integration (MOCK → REAL)
    ├── Seat → Table Management (OPTIONAL)
    └── Cancel → Reason Tracking (REQUIRED)

Analytics Dashboard
├── Firestore Analytics Collection (REQUIRED)
├── Cloud Function Aggregation (REQUIRED)
└── Charts/Visualizations (OPTIONAL)

Reservation System
├── Calendar View (REQUIRED)
├── SMS Reminders (Depends on SMS Integration)
└── Priority Queue Logic (REQUIRED)

Customer App
├── Public API (REQUIRED)
├── Push Notifications (REQUIRED)
└── QR Code Scanner (OPTIONAL)
```

---

## Technical Debt & Known Limitations

### Phase 1 Limitations
1. **No Persistence:** Data lost on app restart (fixed by Firestore)
2. **No Authentication:** Anyone can access the app (fixed by Firebase Auth)
3. **Single Store Only:** No multi-store support (added in Phase 4)
4. **Manual Queue Numbers:** Hardcoded increment (fixed by Cloud Function)
5. **No Table Management:** Table numbers not validated (added in Phase 2)

### Code Refactoring Needed
1. **State Management:** Migrate from vanilla StatefulWidget to Riverpod
2. **Models:** Convert to Freezed for immutability + copyWith
3. **Routing:** Replace imperative Navigator with GoRouter
4. **Code Generation:** Add json_serializable for Firestore serialization
5. **Error Handling:** Implement centralized error handling layer

---

## Feature Completion Checklist (Phase 1 MVP)

### Registration Flow
- [x] Phone input with validation (DONE)
- [x] Group size selection (DONE)
- [x] Confirmation screen (DONE)
- [ ] Firestore integration
- [ ] Queue number auto-generation
- [ ] Queue position calculation
- [ ] Success dialog with queue number

### Queue Management
- [x] Basic list display (DONE)
- [ ] Real-time Firestore updates
- [ ] Status filtering tabs
- [ ] Masked phone display
- [ ] Elapsed wait time
- [ ] Call button (mock SMS)
- [ ] Seat button + table dialog
- [ ] Cancel button + reason dialog
- [ ] No-show detection (3 calls)

### Analytics
- [ ] Analytics dashboard screen
- [ ] Real-time metrics
- [ ] Cloud Function aggregation
- [ ] Firestore analytics collection

### Infrastructure
- [ ] Firebase project setup
- [ ] Firestore schema creation
- [ ] Security rules deployment
- [ ] Composite indexes
- [ ] Cloud Functions deployment
- [ ] Hive offline cache
- [ ] Riverpod state management

### Testing
- [ ] Unit tests for models
- [ ] Widget tests for screens
- [ ] Integration tests for flows
- [ ] Firebase emulator testing

---

## Estimated Development Timeline

### Phase 1: MVP (8 weeks)
- Week 1-2: Firebase setup, Firestore integration, Riverpod migration
- Week 3-4: Queue list screen, real-time updates, status management
- Week 5: Customer calling flow (mock SMS), seating, cancellation
- Week 6: Analytics dashboard, Cloud Functions
- Week 7: Offline support (Hive), error handling
- Week 8: Testing, bug fixes, performance optimization

### Phase 2: Enhanced Operations (6 weeks)
- Week 1-2: Reservation system
- Week 3-4: Table management module
- Week 5: Real SMS integration (Twilio → Semaphore)
- Week 6: Advanced analytics, multi-user auth

### Phase 3: Customer App (8 weeks)
- Week 1-2: Public API design + implementation
- Week 3-4: Customer app UI (Flutter)
- Week 5-6: Push notifications, QR code
- Week 7: Testing, beta launch
- Week 8: Production launch

### Phase 4: Intelligence & Scale (12 weeks)
- Week 1-4: ML wait time prediction
- Week 5-8: Multi-store management
- Week 9-12: POS integration, chain analytics

---

## Success Metrics by Phase

### Phase 1 (MVP)
- ✅ 100% of registrations saved to Firestore
- ✅ Average registration time < 30 seconds
- ✅ Zero data loss on app restart
- ✅ Real-time queue updates < 1 second latency

### Phase 2
- ✅ SMS delivery rate > 95%
- ✅ Table turnover rate tracking
- ✅ 80% of reservations show up on time

### Phase 3
- ✅ 50% of customers use mobile app
- ✅ Customer satisfaction score > 4.5/5
- ✅ Reduced no-show rate by 30%

### Phase 4
- ✅ 100+ stores using the platform
- ✅ Wait time prediction accuracy > 85%
- ✅ Platform uptime > 99.9%

---

**End of Feature Summary**
