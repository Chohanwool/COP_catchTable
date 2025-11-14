# Product Requirements Document (PRD)
# Catch Table - Restaurant Queue Management System

**Version:** 1.0
**Last Updated:** 2025-11-14
**Status:** In Development
**Target Market:** Philippines (Initial)

---

## 1. Executive Summary

### 1.1 Product Vision
Catch Table is a tablet-based queue management system designed for restaurants to efficiently manage walk-in customers without requiring customers to download an app. The solution focuses on the restaurant staff experience, providing an intuitive kiosk interface for registration and real-time queue monitoring.

### 1.2 Problem Statement
Restaurants face challenges managing walk-in queues during peak hours:
- Manual paper-based systems are error-prone and inefficient
- Customers leave when wait times are unclear
- Staff lack visibility into queue status and trends
- No automated customer notification system

### 1.3 Success Metrics
- **Operational Efficiency:** Reduce registration time to < 30 seconds per party
- **Customer Satisfaction:** 90% of called customers respond within 5 minutes
- **No-show Rate:** Track and reduce to < 15%
- **Adoption:** 100+ restaurants within 6 months of launch

---

## 2. Target Users

### 2.1 Primary Users
**Restaurant Host/Hostess:**
- Age: 20-40
- Tech-savviness: Medium
- Responsibilities: Customer greeting, queue management, seating coordination
- Pain points: Juggling multiple tasks during rush hours, manual tracking errors

**Restaurant Manager:**
- Age: 25-50
- Tech-savviness: Medium-High
- Responsibilities: Operations oversight, performance monitoring
- Pain points: Lack of data for staffing decisions, no historical insights

### 2.2 Secondary Users (Future)
**Customers:**
- Receive SMS notifications
- Check queue status (future customer app)

---

## 3. Product Scope

### 3.1 In Scope (MVP - Phase 1)

#### 3.1.1 Queue Registration
- [x] Walk-in customer registration with:
  - Phone number (Philippine format: 09XX-XXX-XXXX)
  - Party size (1-20 guests)
  - Auto-generated queue number
  - Timestamp capture
- [x] Multi-step form validation
- [x] Visual confirmation screen

#### 3.1.2 Queue Management
- [ ] Real-time waiting list display with:
  - Queue number
  - Phone number (masked: 0917-***-4567)
  - Party size
  - Wait time elapsed
  - Current status
- [ ] Status management:
  - Waiting (default)
  - Called
  - Seated
  - Cancelled
  - No-show
- [ ] Queue filtering and sorting

#### 3.1.3 Customer Notification
- [ ] **🔶 MOCK:** Call next customer button
- [ ] **🔶 MOCK:** SMS notification trigger
  - Template: "Hi! Your table at [Store Name] is ready. Please proceed to the host stand. Queue #[Number]"
- [ ] Call history log
- [ ] Manual re-call functionality

#### 3.1.4 Seating & Completion
- [ ] Seat customer action (Waiting → Seated)
- [ ] **🔶 MOCK:** Optional table number assignment
- [ ] Remove from active queue (move to history)

#### 3.1.5 Cancellation Handling
- [ ] Cancel registration (customer request)
- [ ] Mark as no-show (no response after 3 calls)
- [ ] Cancellation reason dropdown

#### 3.1.6 Basic Analytics
- [ ] Dashboard with:
  - Total registrations today
  - Currently waiting count
  - Average wait time
  - No-show count & percentage
- [ ] **🔶 MOCK:** Historical data (currently in-memory only)

#### 3.1.7 Data Persistence
- [ ] Firebase Firestore integration
  - Replace in-memory `dummy_data.dart`
  - Real-time synchronization
- [ ] Offline support with local cache (Hive)

### 3.2 Out of Scope (Phase 1)
- ❌ Customer mobile app
- ❌ Reservation/booking system
- ❌ Table layout management
- ❌ Multi-store support
- ❌ Staff authentication
- ❌ Advanced analytics (trends, predictions)
- ❌ Loyalty/CRM features

### 3.3 Future Phases

#### Phase 2: Enhanced Operations
- Reservation system with calendar
- Table management module
- Multi-user authentication
- Role-based access control

#### Phase 3: Customer Experience
- Customer self-service app
- QR code check-in
- Real-time queue status API

#### Phase 4: Intelligence & Scale
- Wait time prediction (ML)
- Multi-store management
- Advanced analytics dashboard
- Integration APIs for POS systems

---

## 4. Functional Requirements

### 4.1 Registration Flow

**FR-REG-001: Phone Number Entry**
- System SHALL display custom numeric keypad (0-9, backspace)
- System SHALL validate Philippine phone formats:
  - 09XXXXXXXXX (11 digits)
  - 9XXXXXXXXX (10 digits, auto-prefix 0)
  - 639XXXXXXXXX (12 digits, convert to local)
- System SHALL format display as 0XXX-XXX-XXXX
- System SHALL prevent submission if < 10 or > 12 digits

**FR-REG-002: Party Size Selection**
- System SHALL provide horizontal slider (PageView) for 1-20 guests
- System SHALL display large, readable numbers for kiosk use
- System SHALL highlight selected value with visual emphasis

**FR-REG-003: Confirmation Display**
- System SHALL show read-only summary:
  - Queue number
  - Phone number
  - Party size
  - Current position estimate **🔶 MOCK (hardcoded "3" currently)**
- System SHALL allow "Back" navigation to edit
- System SHALL provide "Confirm & Add to Queue" action

**FR-REG-004: Queue Number Generation**
- System SHALL auto-increment queue numbers daily (reset at midnight)
- Format: `Q-[YYYYMMDD]-[001]` (e.g., Q-20251114-042)

### 4.2 Queue List Management

**FR-LIST-001: Waiting List Display**
- System SHALL show all "Waiting" status registrations
- System SHALL sort by registration timestamp (oldest first)
- System SHALL update list in real-time (< 1 second latency)
- System SHALL display per row:
  - Queue number
  - Masked phone (last 4 digits visible)
  - Party size icon
  - Wait time (MM:SS format)
  - Action buttons (Call, Cancel, No-show)

**FR-LIST-002: Status Filtering**
- System SHALL provide tabs:
  - Waiting (default)
  - Called
  - Seated
  - Cancelled/No-show (History)
- System SHALL show count per tab

**FR-LIST-003: Queue Position Calculation**
- System SHALL calculate position based on:
  - Number of "Waiting" entries before current entry
  - +1 for self

### 4.3 Customer Calling

**FR-CALL-001: Call Action**
- System SHALL transition status: Waiting → Called
- System SHALL trigger SMS notification **🔶 MOCK (Cloud Function)**
- System SHALL record call timestamp
- System SHALL display "Called" indicator on list

**FR-CALL-002: SMS Notification** **🔶 MOCK**
- System SHALL send SMS via Cloud Function (not implemented)
- Template variables:
  - `{storeName}`: From Firestore store config
  - `{queueNumber}`: Registration queue number
- Current mock: Console log only

**FR-CALL-003: Re-call**
- System SHALL allow re-calling after 3 minutes
- System SHALL increment call count
- System SHALL mark no-show after 3 failed calls

### 4.4 Seating & Completion

**FR-SEAT-001: Seat Customer**
- System SHALL transition: Called → Seated
- System SHALL record seating timestamp
- System SHALL prompt for table number **🔶 MOCK (optional, no table data)**
- System SHALL remove from active queue
- System SHALL move to history

**FR-SEAT-002: Table Assignment** **🔶 MOCK**
- System SHALL accept table number input (1-50)
- Current: No table management system
- Future: Validate against table availability

### 4.5 Cancellation & No-show

**FR-CANCEL-001: Cancel Registration**
- System SHALL prompt for reason:
  - Customer left
  - Wrong registration
  - Duplicate entry
  - Other (text input)
- System SHALL transition to "Cancelled" status
- System SHALL record cancellation timestamp

**FR-CANCEL-002: Mark No-show**
- System SHALL auto-suggest no-show after 3 calls with no response
- System SHALL allow manual no-show marking
- System SHALL transition to "No-show" status

### 4.6 Analytics Dashboard

**FR-ANALYTICS-001: Real-time Metrics**
- System SHALL display:
  - Current queue length (Waiting count)
  - Today's total registrations
  - Average wait time (registration → seated)
  - No-show rate (today)
- System SHALL update every 30 seconds

**FR-ANALYTICS-002: Historical Data** **🔶 MOCK**
- Current: In-memory only, lost on restart
- Future: Firestore aggregation via Cloud Functions
- Show last 7 days, 30 days, custom range

---

## 5. Non-Functional Requirements

### 5.1 Performance
- **NFR-PERF-001:** App SHALL load within 3 seconds on iPad Pro 12.9"
- **NFR-PERF-002:** Registration flow SHALL complete in < 30 seconds
- **NFR-PERF-003:** Firestore updates SHALL reflect in UI within 1 second

### 5.2 Usability
- **NFR-UX-001:** Interface SHALL be usable in landscape tablet mode only
- **NFR-UX-002:** Touch targets SHALL be minimum 44x44 sp
- **NFR-UX-003:** Text SHALL be readable from 60cm distance (min 16sp font)

### 5.3 Reliability
- **NFR-REL-001:** App SHALL support offline mode for registration
- **NFR-REL-002:** Data SHALL sync when connection restored
- **NFR-REL-003:** No data loss on app crash/restart

### 5.4 Security
- **NFR-SEC-001:** Phone numbers SHALL be masked in public views
- **NFR-SEC-002:** Firebase rules SHALL restrict access to authenticated users
- **NFR-SEC-003:** SMS API keys SHALL be stored in Cloud Functions environment

### 5.5 Scalability
- **NFR-SCALE-001:** Support up to 500 registrations per day per store
- **NFR-SCALE-002:** Support 50 concurrent active queue entries

### 5.6 Localization
- **NFR-L10N-001:** UI SHALL support English (primary)
- **NFR-L10N-002:** Phone number format SHALL follow Philippine standards
- **NFR-L10N-003:** SMS SHALL support Tagalog/English templates (future)

---

## 6. Technical Constraints

### 6.1 Platform
- Target devices: iPad Pro 12.9" (primary), Android tablets 10"+ (secondary)
- Orientation: Landscape only
- OS: iOS 12+, Android 8.0+

### 6.2 Technology Stack
- Frontend: Flutter 3.24+
- Backend: Firebase (Firestore, Cloud Functions, Auth)
- SMS: Twilio (dev), Semaphore (production)
- State Management: Riverpod 2.x (planned migration)

### 6.3 Dependencies
- Existing: `flutter_libphonenumber` (unused, to be removed)
- Required: `cloud_firestore`, `firebase_auth`, `firebase_core`, `riverpod`, `freezed`, `hive`

---

## 7. User Stories (MVP)

### 7.1 Registration
```
As a restaurant host,
I want to register walk-in customers quickly,
So that I can minimize wait time at the entrance during rush hour.

Acceptance Criteria:
- Registration completes in < 30 seconds
- Phone number auto-formats as I type
- System confirms registration with queue number
```

### 7.2 Queue Monitoring
```
As a restaurant host,
I want to see all waiting customers in one view,
So that I can manage the queue efficiently.

Acceptance Criteria:
- List shows current position for each party
- Wait time updates in real-time
- I can filter by status (Waiting, Called, etc.)
```

### 7.3 Customer Calling
```
As a restaurant host,
I want to call the next customer when a table is ready,
So that customers are notified immediately.

Acceptance Criteria:
- One-tap call button
- SMS sent automatically (mock in Phase 1)
- Customer status changes to "Called"
```

### 7.4 No-show Handling
```
As a restaurant host,
I want to mark customers who don't respond as no-shows,
So that I can free up the queue for other customers.

Acceptance Criteria:
- System suggests no-show after 3 calls
- No-show entries move to history
- No-show count reflects in analytics
```

### 7.5 Basic Insights
```
As a restaurant manager,
I want to see daily queue statistics,
So that I can understand busy periods and optimize staffing.

Acceptance Criteria:
- Dashboard shows total registrations, avg wait time, no-show rate
- Data updates in real-time
- Accessible from main menu
```

---

## 8. Mock Data & External Dependencies

### 8.1 Currently Mocked (Phase 1)

| Feature | Current State | Future Implementation |
|---------|--------------|----------------------|
| SMS Sending | `print()` statement | Twilio/Semaphore via Cloud Function |
| Table Assignment | Manual input, not validated | Table management system with availability |
| Queue Position | Hardcoded "number 3" | Calculated from Firestore query |
| Store Info | Hardcoded "Mang Inasal" | Firestore `/stores/{storeId}` collection |
| Analytics History | In-memory, resets daily | Firestore aggregation, Cloud Function scheduled |
| Wait Time Estimate | Not shown | Avg of last 10 seated customers |

### 8.2 External API Dependencies

**Twilio SMS API** (Phase 2)
- Endpoint: `https://api.twilio.com/2010-04-01/Accounts/{AccountSid}/Messages.json`
- Authentication: Account SID + Auth Token
- Rate limit: 100 SMS/second
- Cost: ~$0.015 per SMS in Philippines

**Semaphore SMS API** (Production Alternative)
- Endpoint: `https://api.semaphore.co/api/v4/messages`
- Authentication: API Key
- Cost: ₱0.60-0.90 per SMS (cheaper for PH)

---

## 9. Open Questions & Decisions Needed

### 9.1 Open Questions
1. **Queue Reset Time:** Should queue numbers reset daily at midnight or at store opening time?
   - **Decision Needed:** Get restaurant preference

2. **No-show Timeout:** How long to wait before auto-marking no-show?
   - **Recommendation:** 10 minutes after 3rd call

3. **SMS Language:** English only or Tagalog option?
   - **Decision Needed:** User research in Philippine market

4. **Table Assignment:** Mandatory or optional during seating?
   - **Current:** Optional
   - **Recommendation:** Make mandatory in Phase 2 with table management

### 9.2 Resolved Decisions
- ✅ **State Management:** Migrate to Riverpod (from vanilla StatefulWidget) - Planned for Phase 2
- ✅ **Phone Format:** Philippine local format (09XX-XXX-XXXX) as primary
- ✅ **Offline Support:** Required - implement with Hive cache
- ✅ **Platform:** Tablet-only (no phone responsive design)

---

## 10. Success Criteria (Phase 1 MVP)

### 10.1 Launch Readiness Checklist
- [ ] All FR-REG-* requirements implemented
- [ ] All FR-LIST-* requirements implemented
- [ ] All FR-CALL-* requirements implemented (mock SMS acceptable)
- [ ] All FR-SEAT-* requirements implemented
- [ ] All FR-ANALYTICS-* requirements implemented
- [ ] Firebase Firestore integrated
- [ ] Offline mode functional
- [ ] Zero critical bugs
- [ ] Usability testing with 3+ restaurants
- [ ] Performance benchmarks met (NFR-PERF-*)

### 10.2 Post-Launch Metrics (30 days)
- 80% of registrations completed without errors
- Average session duration < 45 seconds per registration
- < 5% app crash rate
- 90% uptime for Firebase backend

---

## 11. Timeline & Milestones

### Phase 1: MVP (8 weeks)
- **Week 1-2:** Firebase setup, Firestore schema, authentication
- **Week 3-4:** Queue list screen, real-time updates, status management
- **Week 5:** Customer calling flow (mock SMS)
- **Week 6:** Seating, cancellation, no-show features
- **Week 7:** Analytics dashboard
- **Week 8:** Testing, bug fixes, performance optimization

### Phase 2: Enhanced Features (6 weeks)
- Reservation system
- Real SMS integration (Twilio → Semaphore)
- Table management
- Multi-user auth

### Phase 3: Customer App (8 weeks)
- Customer mobile app (Flutter)
- QR code check-in
- Push notifications

---

## 12. Appendix

### 12.1 Glossary
- **Queue Number:** Unique identifier for each registration (format: Q-YYYYMMDD-NNN)
- **Party Size:** Number of guests in a group (1-20)
- **Wait Time:** Elapsed time from registration to current moment
- **No-show:** Customer who did not respond after being called 3 times
- **Kiosk Mode:** Full-screen tablet interface for self-service or staff use

### 12.2 References
- Philippine phone number format: [PLDT Standards](https://www.pldt.com)
- Firebase Firestore documentation: https://firebase.google.com/docs/firestore
- Twilio SMS API: https://www.twilio.com/docs/sms
- Semaphore API: https://semaphore.co/docs

---

**Document Prepared By:** Development Team
**Approved By:** [Pending]
**Next Review Date:** 2025-12-14
