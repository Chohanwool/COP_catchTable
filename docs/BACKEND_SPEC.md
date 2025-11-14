# Backend Technical Specification
# Catch Table - Firebase Backend

**Version:** 1.0
**Last Updated:** 2025-11-14
**Platform:** Firebase (Firestore, Cloud Functions, Authentication)

---

## 1. Architecture Overview

### 1.1 Firebase Services Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Flutter App                        │
└────────────┬────────────────────────────────────────┘
             │
             ├──────────────────┐
             │                  │
┌────────────▼──────┐  ┌────────▼─────────┐
│  Firebase Auth    │  │   Firestore DB   │
│  (Staff Login)    │  │  (Real-time)     │
└───────────────────┘  └──────┬───────────┘
                              │
                    ┌─────────▼──────────┐
                    │  Cloud Functions   │
                    │  (Node.js/Python)  │
                    └─────────┬──────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
    ┌─────────▼────┐  ┌───────▼──────┐  ┌───▼────────┐
    │ Twilio/      │  │  Scheduled   │  │  Firestore │
    │ Semaphore    │  │  Jobs        │  │  Triggers  │
    │ SMS API      │  │  (Analytics) │  │  (Hooks)   │
    └──────────────┘  └──────────────┘  └────────────┘
```

### 1.2 Data Flow Diagram

```
Registration Flow:
┌─────────┐      ┌───────────┐      ┌──────────────┐
│ Flutter │─────>│ Firestore │─────>│ Cloud Func   │
│  App    │      │  /queues  │      │ (onCreate)   │
└─────────┘      └───────────┘      └──────┬───────┘
                                            │
                                     ┌──────▼───────┐
                                     │ Update       │
                                     │ Analytics    │
                                     └──────────────┘

Call Customer Flow:
┌─────────┐      ┌───────────┐      ┌──────────────┐
│ Flutter │─────>│ Firestore │─────>│ Cloud Func   │
│  App    │      │  Update   │      │ (onUpdate)   │
└─────────┘      │  status   │      └──────┬───────┘
                 └───────────┘             │
                                    ┌──────▼───────┐
                                    │ Send SMS     │
                                    │ via Twilio   │
                                    └──────────────┘
```

---

## 2. Firestore Database Schema

### 2.1 Collections Overview

```
/stores
  /{storeId}
    /queues
      /{queueId}
    /analytics
      /{dateId}
    /config
      - storeConfig document
    /staff
      /{staffId}
```

### 2.2 Collection: /stores/{storeId}

**Document Structure:**
```json
{
  "id": "store_001",
  "name": "Mang Inasal - SM North EDSA",
  "logoUrl": "https://storage.googleapis.com/...",
  "phoneNumber": "09171234567",
  "address": "SM City North EDSA, Quezon City",
  "location": {
    "latitude": 14.6564,
    "longitude": 121.0293
  },
  "openingTime": "09:00",
  "closingTime": "22:00",
  "timezone": "Asia/Manila",
  "averageServiceMinutes": 45,
  "isActive": true,
  "createdAt": "2025-01-01T00:00:00Z",
  "updatedAt": "2025-01-14T10:30:00Z"
}
```

**Indexes:**
- `isActive` (ASC)

### 2.3 Collection: /stores/{storeId}/queues/{queueId}

**Document Structure:**
```json
{
  "id": "queue_20251114_001",
  "queueNumber": "Q-20251114-001",
  "storeId": "store_001",
  "phoneNumber": "09171234567",
  "groupSize": 4,
  "status": "waiting",
  "registeredAt": "2025-11-14T14:30:00Z",
  "calledAt": null,
  "seatedAt": null,
  "cancelledAt": null,
  "completedAt": null,
  "tableNumber": null,
  "cancellationReason": null,
  "callCount": 0,
  "lastCalledAt": null,
  "estimatedWaitMinutes": 25,
  "notes": "",
  "metadata": {
    "registeredBy": "staff_001",
    "ipAddress": "192.168.1.100",
    "deviceId": "tablet_01"
  }
}
```

**Field Descriptions:**
- `id`: Unique identifier (auto-generated)
- `queueNumber`: Human-readable queue number (format: Q-YYYYMMDD-NNN)
- `status`: Enum - "waiting" | "called" | "seated" | "cancelled" | "noShow"
- `registeredAt`: Timestamp of initial registration
- `calledAt`: Timestamp when first called (null if not yet called)
- `seatedAt`: Timestamp when seated
- `cancelledAt`: Timestamp when cancelled or marked no-show
- `completedAt`: Timestamp when removed from active queue (seated/cancelled/noShow)
- `callCount`: Number of times customer was called (auto no-show at 3)
- `estimatedWaitMinutes`: Calculated estimate (updated via Cloud Function)

**Indexes:**
- `storeId` (ASC), `status` (ASC), `registeredAt` (ASC)
- `storeId` (ASC), `registeredAt` (ASC)
- `status` (ASC), `registeredAt` (ASC)

**Composite Index (Required for Queries):**
```
Collection: queues
Fields: storeId (Ascending), status (Ascending), registeredAt (Ascending)
```

### 2.4 Collection: /stores/{storeId}/analytics/{dateId}

**Document ID Format:** `YYYY-MM-DD` (e.g., "2025-11-14")

**Document Structure:**
```json
{
  "date": "2025-11-14",
  "storeId": "store_001",
  "totalRegistrations": 42,
  "statusCounts": {
    "waiting": 8,
    "called": 3,
    "seated": 28,
    "cancelled": 2,
    "noShow": 1
  },
  "averageWaitMinutes": 32.5,
  "medianWaitMinutes": 28,
  "maxWaitMinutes": 65,
  "minWaitMinutes": 12,
  "peakHour": "18:00",
  "peakHourRegistrations": 12,
  "hourlyBreakdown": {
    "09:00": 2,
    "10:00": 3,
    "11:00": 5,
    "12:00": 8,
    "13:00": 6,
    "14:00": 4,
    "15:00": 3,
    "16:00": 2,
    "17:00": 4,
    "18:00": 12,
    "19:00": 10,
    "20:00": 6,
    "21:00": 3
  },
  "noShowRate": 2.38,
  "cancellationRate": 4.76,
  "lastUpdatedAt": "2025-11-14T21:59:00Z"
}
```

**Update Frequency:**
- Real-time: Incremented on each new registration/status change
- Batch: Recalculated hourly via Cloud Scheduler

**Indexes:**
- `storeId` (ASC), `date` (DESC)

### 2.5 Collection: /stores/{storeId}/staff/{staffId}

**Document Structure:**
```json
{
  "id": "staff_001",
  "email": "host@manginasal.com",
  "displayName": "Maria Santos",
  "role": "host",
  "storeId": "store_001",
  "isActive": true,
  "createdAt": "2025-01-01T00:00:00Z",
  "lastLoginAt": "2025-11-14T14:00:00Z"
}
```

**Roles:**
- `host`: Can register, call, seat, cancel customers
- `manager`: All host permissions + analytics access + settings
- `admin`: All permissions + multi-store access

---

## 3. Cloud Functions

### 3.1 Function: onQueueCreate (Firestore Trigger)

**Purpose:** Auto-generate queue number and calculate initial wait estimate

**Trigger:** `onCreate` on `/stores/{storeId}/queues/{queueId}`

**Implementation (Node.js):**
```javascript
// functions/src/triggers/onQueueCreate.ts

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const onQueueCreate = functions.firestore
  .document('stores/{storeId}/queues/{queueId}')
  .onCreate(async (snap, context) => {
    const { storeId, queueId } = context.params;
    const data = snap.data();

    try {
      // Generate queue number
      const today = new Date().toISOString().split('T')[0].replace(/-/g, '');
      const dailyCount = await getDailyQueueCount(storeId, today);
      const queueNumber = `Q-${today}-${String(dailyCount + 1).padStart(3, '0')}`;

      // Calculate estimated wait time
      const avgWaitTime = await getAverageWaitTime(storeId);
      const currentQueueLength = await getCurrentQueueLength(storeId);
      const estimatedWaitMinutes = Math.ceil((currentQueueLength + 1) * avgWaitTime);

      // Update document
      await snap.ref.update({
        queueNumber,
        estimatedWaitMinutes,
        'metadata.queuePosition': currentQueueLength + 1,
      });

      // Update daily analytics
      await incrementDailyCount(storeId, today);

      functions.logger.info(`Queue created: ${queueNumber} for store ${storeId}`);
    } catch (error) {
      functions.logger.error('Error in onQueueCreate:', error);
      throw error;
    }
  });

async function getDailyQueueCount(storeId: string, dateStr: string): Promise<number> {
  const startOfDay = new Date(`${dateStr}T00:00:00Z`);
  const endOfDay = new Date(`${dateStr}T23:59:59Z`);

  const snapshot = await admin.firestore()
    .collection(`stores/${storeId}/queues`)
    .where('registeredAt', '>=', startOfDay)
    .where('registeredAt', '<=', endOfDay)
    .count()
    .get();

  return snapshot.data().count;
}

async function getAverageWaitTime(storeId: string): Promise<number> {
  const last10Seated = await admin.firestore()
    .collection(`stores/${storeId}/queues`)
    .where('status', '==', 'seated')
    .orderBy('seatedAt', 'desc')
    .limit(10)
    .get();

  if (last10Seated.empty) return 30; // Default 30 minutes

  const waitTimes = last10Seated.docs.map(doc => {
    const data = doc.data();
    const registered = data.registeredAt.toDate();
    const seated = data.seatedAt.toDate();
    return (seated - registered) / 60000; // minutes
  });

  return waitTimes.reduce((a, b) => a + b, 0) / waitTimes.length;
}

async function getCurrentQueueLength(storeId: string): Promise<number> {
  const snapshot = await admin.firestore()
    .collection(`stores/${storeId}/queues`)
    .where('status', '==', 'waiting')
    .count()
    .get();

  return snapshot.data().count;
}

async function incrementDailyCount(storeId: string, dateStr: string): Promise<void> {
  const analyticsRef = admin.firestore()
    .doc(`stores/${storeId}/analytics/${dateStr}`);

  await analyticsRef.set({
    date: dateStr,
    storeId,
    totalRegistrations: admin.firestore.FieldValue.increment(1),
    'statusCounts.waiting': admin.firestore.FieldValue.increment(1),
    lastUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });
}
```

### 3.2 Function: onQueueUpdate (Firestore Trigger)

**Purpose:** Trigger SMS when status changes to "called"

**Trigger:** `onUpdate` on `/stores/{storeId}/queues/{queueId}`

**Implementation:**
```javascript
// functions/src/triggers/onQueueUpdate.ts

export const onQueueUpdate = functions.firestore
  .document('stores/{storeId}/queues/{queueId}')
  .onUpdate(async (change, context) => {
    const { storeId, queueId } = context.params;
    const before = change.before.data();
    const after = change.after.data();

    // Status changed from waiting → called
    if (before.status === 'waiting' && after.status === 'called') {
      await handleCustomerCall(storeId, queueId, after);
    }

    // Status changed to seated
    if (after.status === 'seated' && before.status !== 'seated') {
      await updateAnalyticsOnSeated(storeId, after);
    }

    // Status changed to cancelled or noShow
    if (['cancelled', 'noShow'].includes(after.status) && before.status !== after.status) {
      await updateAnalyticsOnCancellation(storeId, after);
    }
  });

async function handleCustomerCall(storeId: string, queueId: string, data: any) {
  try {
    // Get store config
    const storeDoc = await admin.firestore().doc(`stores/${storeId}`).get();
    const storeData = storeDoc.data();

    // Send SMS via Twilio
    await sendSMS({
      to: data.phoneNumber,
      body: `Hi! Your table at ${storeData.name} is ready. Please proceed to the host stand. Queue #${data.queueNumber}`,
    });

    // Update call metadata
    await admin.firestore().doc(`stores/${storeId}/queues/${queueId}`).update({
      callCount: admin.firestore.FieldValue.increment(1),
      lastCalledAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    functions.logger.info(`SMS sent to ${data.phoneNumber} for queue ${data.queueNumber}`);
  } catch (error) {
    functions.logger.error('Error sending SMS:', error);
    // Don't throw - allow status update to succeed even if SMS fails
  }
}
```

### 3.3 Function: sendSMS (HTTP Callable)

**Purpose:** Send SMS notifications via Twilio/Semaphore

**Endpoint:** `https://{region}-{project-id}.cloudfunctions.net/sendSMS`

**Request:**
```json
{
  "to": "09171234567",
  "body": "Your table is ready..."
}
```

**Response:**
```json
{
  "success": true,
  "messageSid": "SM1234567890abcdef",
  "timestamp": "2025-11-14T15:30:00Z"
}
```

**Implementation:**
```javascript
// functions/src/callable/sendSMS.ts

import * as functions from 'firebase-functions';
import * as twilio from 'twilio';

const accountSid = functions.config().twilio.account_sid;
const authToken = functions.config().twilio.auth_token;
const fromNumber = functions.config().twilio.from_number;

const client = twilio(accountSid, authToken);

export const sendSMS = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Must be authenticated to send SMS'
    );
  }

  const { to, body } = data;

  if (!to || !body) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required fields: to, body'
    );
  }

  try {
    const message = await client.messages.create({
      body,
      from: fromNumber,
      to: formatPhoneNumberForTwilio(to),
    });

    return {
      success: true,
      messageSid: message.sid,
      timestamp: new Date().toISOString(),
    };
  } catch (error) {
    functions.logger.error('Twilio error:', error);
    throw new functions.https.HttpsError(
      'internal',
      `Failed to send SMS: ${error.message}`
    );
  }
});

function formatPhoneNumberForTwilio(phoneNumber: string): string {
  // Convert 09171234567 → +639171234567
  const cleaned = phoneNumber.replace(/\D/g, '');

  if (cleaned.startsWith('0')) {
    return `+63${cleaned.substring(1)}`;
  } else if (cleaned.startsWith('63')) {
    return `+${cleaned}`;
  } else {
    return `+63${cleaned}`;
  }
}
```

### 3.4 Function: aggregateAnalytics (Scheduled)

**Purpose:** Hourly aggregation of analytics data

**Schedule:** Every hour (Cron: `0 * * * *`)

**Implementation:**
```javascript
// functions/src/scheduled/aggregateAnalytics.ts

export const aggregateAnalytics = functions.pubsub
  .schedule('0 * * * *')  // Every hour
  .timeZone('Asia/Manila')
  .onRun(async (context) => {
    const stores = await admin.firestore().collection('stores').get();

    for (const storeDoc of stores.docs) {
      const storeId = storeDoc.id;
      await aggregateStoreAnalytics(storeId);
    }

    functions.logger.info('Analytics aggregation completed');
  });

async function aggregateStoreAnalytics(storeId: string) {
  const today = new Date().toISOString().split('T')[0];

  // Get all queues for today
  const queuesSnapshot = await admin.firestore()
    .collection(`stores/${storeId}/queues`)
    .where('registeredAt', '>=', new Date(`${today}T00:00:00Z`))
    .where('registeredAt', '<=', new Date(`${today}T23:59:59Z`))
    .get();

  const queues = queuesSnapshot.docs.map(doc => doc.data());

  // Calculate metrics
  const statusCounts = {
    waiting: queues.filter(q => q.status === 'waiting').length,
    called: queues.filter(q => q.status === 'called').length,
    seated: queues.filter(q => q.status === 'seated').length,
    cancelled: queues.filter(q => q.status === 'cancelled').length,
    noShow: queues.filter(q => q.status === 'noShow').length,
  };

  const seatedQueues = queues.filter(q => q.status === 'seated');
  const waitTimes = seatedQueues.map(q => {
    const registered = q.registeredAt.toDate();
    const seated = q.seatedAt.toDate();
    return (seated - registered) / 60000; // minutes
  });

  const averageWaitMinutes = waitTimes.length > 0
    ? waitTimes.reduce((a, b) => a + b, 0) / waitTimes.length
    : 0;

  const hourlyBreakdown = calculateHourlyBreakdown(queues);
  const peakHour = Object.entries(hourlyBreakdown)
    .reduce((max, [hour, count]) => count > max[1] ? [hour, count] : max, ['', 0])[0];

  // Update analytics document
  await admin.firestore()
    .doc(`stores/${storeId}/analytics/${today}`)
    .set({
      date: today,
      storeId,
      totalRegistrations: queues.length,
      statusCounts,
      averageWaitMinutes,
      peakHour,
      peakHourRegistrations: hourlyBreakdown[peakHour] || 0,
      hourlyBreakdown,
      noShowRate: (statusCounts.noShow / queues.length) * 100,
      cancellationRate: (statusCounts.cancelled / queues.length) * 100,
      lastUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}

function calculateHourlyBreakdown(queues: any[]): Record<string, number> {
  const breakdown: Record<string, number> = {};

  queues.forEach(queue => {
    const hour = queue.registeredAt.toDate().getHours();
    const hourKey = `${hour.toString().padStart(2, '0')}:00`;
    breakdown[hourKey] = (breakdown[hourKey] || 0) + 1;
  });

  return breakdown;
}
```

### 3.5 Function: cleanupOldQueues (Scheduled)

**Purpose:** Archive queues older than 30 days to reduce database size

**Schedule:** Daily at 2:00 AM (Cron: `0 2 * * *`)

**Implementation:**
```javascript
// functions/src/scheduled/cleanupOldQueues.ts

export const cleanupOldQueues = functions.pubsub
  .schedule('0 2 * * *')  // Daily at 2 AM
  .timeZone('Asia/Manila')
  .onRun(async (context) => {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - 30);

    const stores = await admin.firestore().collection('stores').get();

    for (const storeDoc of stores.docs) {
      const storeId = storeDoc.id;

      const oldQueues = await admin.firestore()
        .collection(`stores/${storeId}/queues`)
        .where('registeredAt', '<', cutoffDate)
        .get();

      // Batch delete (max 500 at a time)
      const batch = admin.firestore().batch();
      oldQueues.docs.forEach(doc => batch.delete(doc.ref));

      await batch.commit();

      functions.logger.info(`Deleted ${oldQueues.size} old queues for store ${storeId}`);
    }
  });
```

---

## 4. Firebase Security Rules

### 4.1 Firestore Rules

```javascript
// firestore.rules

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isStaff(storeId) {
      return isAuthenticated() &&
             exists(/databases/$(database)/documents/stores/$(storeId)/staff/$(request.auth.uid));
    }

    function isManager(storeId) {
      let staffDoc = get(/databases/$(database)/documents/stores/$(storeId)/staff/$(request.auth.uid));
      return isStaff(storeId) && staffDoc.data.role in ['manager', 'admin'];
    }

    function isAdmin() {
      return isAuthenticated() &&
             get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role == 'admin';
    }

    // Store documents
    match /stores/{storeId} {
      allow read: if isAuthenticated();
      allow write: if isManager(storeId) || isAdmin();

      // Queue subcollection
      match /queues/{queueId} {
        allow create: if isStaff(storeId);
        allow read: if isStaff(storeId);
        allow update: if isStaff(storeId) &&
                         request.resource.data.diff(resource.data).affectedKeys()
                         .hasOnly(['status', 'calledAt', 'seatedAt', 'cancelledAt',
                                  'tableNumber', 'cancellationReason', 'callCount', 'lastCalledAt']);
        allow delete: if isManager(storeId);
      }

      // Analytics subcollection
      match /analytics/{dateId} {
        allow read: if isStaff(storeId);
        allow write: if false;  // Only Cloud Functions can write
      }

      // Staff subcollection
      match /staff/{staffId} {
        allow read: if isStaff(storeId);
        allow write: if isManager(storeId);
      }
    }

    // Admin collection
    match /admins/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if false;  // Only via Cloud Functions
    }
  }
}
```

### 4.2 Storage Rules (for logos/images)

```javascript
// storage.rules

rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    // Store logos
    match /stores/{storeId}/logo.{ext} {
      allow read: if true;  // Public
      allow write: if request.auth != null &&
                      firestore.get(/databases/(default)/documents/stores/$(storeId)/staff/$(request.auth.uid)).data.role in ['manager', 'admin'];
    }

    // Temporary uploads
    match /temp/{userId}/{fileName} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

---

## 5. API Specifications (Cloud Functions HTTP Endpoints)

### 5.1 POST /sendSMS

**Authentication:** Firebase Auth Token (required)

**Request Headers:**
```
Authorization: Bearer {firebase_id_token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "to": "09171234567",
  "body": "Your table at Mang Inasal is ready. Queue #Q-20251114-042"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "messageSid": "SM1234567890abcdef",
  "timestamp": "2025-11-14T15:30:00Z"
}
```

**Error Responses:**
- `401 Unauthorized`: Missing or invalid auth token
- `400 Bad Request`: Missing required fields
- `500 Internal Server Error`: Twilio API failure

### 5.2 GET /analytics/export

**Purpose:** Export analytics data as CSV

**Authentication:** Firebase Auth Token (Manager+ role required)

**Query Parameters:**
- `storeId` (required): Store ID
- `startDate` (required): ISO date (YYYY-MM-DD)
- `endDate` (required): ISO date (YYYY-MM-DD)
- `format` (optional): "csv" | "json" (default: csv)

**Request:**
```
GET /analytics/export?storeId=store_001&startDate=2025-11-01&endDate=2025-11-14&format=csv
Authorization: Bearer {token}
```

**Response (200 OK):**
```csv
Date,Total Registrations,Avg Wait (min),No-shows,Cancellations
2025-11-01,38,28.5,2,1
2025-11-02,42,32.0,1,3
...
```

**Implementation:**
```javascript
// functions/src/http/exportAnalytics.ts

export const exportAnalytics = functions.https.onRequest(async (req, res) => {
  // Verify auth
  const token = req.headers.authorization?.split('Bearer ')[1];
  if (!token) {
    res.status(401).send('Unauthorized');
    return;
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    const { storeId, startDate, endDate, format = 'csv' } = req.query;

    // Verify manager role
    const staffDoc = await admin.firestore()
      .doc(`stores/${storeId}/staff/${decodedToken.uid}`)
      .get();

    if (!staffDoc.exists || !['manager', 'admin'].includes(staffDoc.data().role)) {
      res.status(403).send('Forbidden: Manager role required');
      return;
    }

    // Fetch analytics
    const analyticsSnapshot = await admin.firestore()
      .collection(`stores/${storeId}/analytics`)
      .where('date', '>=', startDate)
      .where('date', '<=', endDate)
      .orderBy('date', 'asc')
      .get();

    const data = analyticsSnapshot.docs.map(doc => doc.data());

    if (format === 'json') {
      res.json(data);
    } else {
      // Convert to CSV
      const csv = convertToCSV(data);
      res.setHeader('Content-Type', 'text/csv');
      res.setHeader('Content-Disposition', `attachment; filename="analytics_${storeId}_${startDate}_${endDate}.csv"`);
      res.send(csv);
    }
  } catch (error) {
    functions.logger.error('Export error:', error);
    res.status(500).send('Internal Server Error');
  }
});

function convertToCSV(data: any[]): string {
  const headers = ['Date', 'Total Registrations', 'Avg Wait (min)', 'No-shows', 'Cancellations'];
  const rows = data.map(d => [
    d.date,
    d.totalRegistrations,
    d.averageWaitMinutes.toFixed(1),
    d.statusCounts.noShow,
    d.statusCounts.cancelled,
  ]);

  return [headers, ...rows].map(row => row.join(',')).join('\n');
}
```

---

## 6. Third-Party Integrations

### 6.1 Twilio SMS Integration

**Environment Variables (Firebase Config):**
```bash
firebase functions:config:set twilio.account_sid="AC1234567890abcdef"
firebase functions:config:set twilio.auth_token="your_auth_token"
firebase functions:config:set twilio.from_number="+12345678900"
```

**Usage in Functions:**
```javascript
const twilioConfig = functions.config().twilio;
const client = require('twilio')(twilioConfig.account_sid, twilioConfig.auth_token);

await client.messages.create({
  body: 'Your table is ready!',
  from: twilioConfig.from_number,
  to: '+639171234567',
});
```

**Cost Estimation:**
- Philippine SMS: ~$0.015 per message
- 100 customers/day: $1.50/day = $45/month per store

### 6.2 Semaphore SMS Integration (Alternative)

**Environment Variables:**
```bash
firebase functions:config:set semaphore.api_key="your_api_key"
```

**Implementation:**
```javascript
// functions/src/services/semaphoreSMS.ts

import axios from 'axios';

export async function sendSemaphoreSMS(to: string, message: string) {
  const apiKey = functions.config().semaphore.api_key;

  const response = await axios.post('https://api.semaphore.co/api/v4/messages', {
    apikey: apiKey,
    number: to,
    message: message,
    sendername: 'CatchTable',
  });

  return response.data;
}
```

**Cost:**
- ₱0.60-0.90 per SMS (cheaper for PH domestic)
- 100 customers/day: ~₱70/day = ₱2,100/month per store

---

## 7. Database Indexes (Required)

### 7.1 Composite Indexes

Create these indexes in Firebase Console or via `firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "queues",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "storeId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "registeredAt", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "queues",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "storeId", "order": "ASCENDING" },
        { "fieldPath": "registeredAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "analytics",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "storeId", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "DESCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

Deploy indexes:
```bash
firebase deploy --only firestore:indexes
```

---

## 8. Authentication Setup

### 8.1 Firebase Authentication Configuration

**Enabled Sign-in Methods:**
1. Email/Password (for staff login)
2. Phone (optional, for future customer app)

**Custom Claims (Set via Cloud Function):**
```javascript
// functions/src/auth/setCustomClaims.ts

export const setStaffRole = functions.https.onCall(async (data, context) => {
  // Only admins can set roles
  if (!context.auth || context.auth.token.role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'Admin only');
  }

  const { userId, role, storeId } = data;

  await admin.auth().setCustomUserClaims(userId, {
    role,
    storeId,
  });

  return { success: true };
});
```

**Usage in Security Rules:**
```javascript
function hasRole(role) {
  return request.auth.token.role == role;
}

allow read: if hasRole('manager') || hasRole('admin');
```

### 8.2 Staff Registration Flow

1. Admin creates staff account via Cloud Function
2. Cloud Function:
   - Creates Firebase Auth user
   - Sets custom claims (role, storeId)
   - Creates Firestore `/stores/{storeId}/staff/{uid}` document
3. Staff receives email with temporary password
4. Staff logs in and changes password

---

## 9. Error Handling & Logging

### 9.1 Cloud Functions Error Handling

```javascript
try {
  // Function logic
} catch (error) {
  if (error instanceof ValidationError) {
    throw new functions.https.HttpsError('invalid-argument', error.message);
  } else if (error instanceof PermissionError) {
    throw new functions.https.HttpsError('permission-denied', error.message);
  } else {
    functions.logger.error('Unexpected error:', error);
    throw new functions.https.HttpsError('internal', 'An unexpected error occurred');
  }
}
```

### 9.2 Structured Logging

```javascript
functions.logger.info('Queue created', {
  queueId,
  storeId,
  phoneNumber: maskPhone(phoneNumber),
  groupSize,
});

functions.logger.warn('High queue count detected', {
  storeId,
  currentCount: queueLength,
  threshold: 50,
});

functions.logger.error('SMS send failed', {
  error: error.message,
  queueId,
  phoneNumber: maskPhone(phoneNumber),
});
```

### 9.3 Monitoring & Alerts

**Set up Cloud Monitoring alerts for:**
- Function execution errors > 5% error rate
- Function execution time > 30 seconds
- Firestore read/write costs > $X per day
- SMS send failures > 10% failure rate

---

## 10. Deployment

### 10.1 Firebase CLI Setup

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize project
firebase init

# Select:
# - Firestore
# - Functions
# - Storage
# - Hosting (optional)
```

### 10.2 Environment Configuration

**Development:**
```bash
firebase use dev
firebase functions:config:set env.mode="development"
firebase functions:config:set twilio.account_sid="test_sid"
```

**Production:**
```bash
firebase use production
firebase functions:config:set env.mode="production"
firebase functions:config:set twilio.account_sid="AC_real_sid"
```

### 10.3 Deployment Commands

```bash
# Deploy everything
firebase deploy

# Deploy only functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:onQueueCreate

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Firestore indexes
firebase deploy --only firestore:indexes
```

---

## 11. Performance Optimization

### 11.1 Firestore Query Optimization

**Inefficient:**
```javascript
// Fetches all queues then filters in memory
const allQueues = await db.collection('queues').get();
const waiting = allQueues.docs.filter(d => d.data().status === 'waiting');
```

**Optimized:**
```javascript
// Filters at database level
const waiting = await db.collection('queues')
  .where('status', '==', 'waiting')
  .where('storeId', '==', storeId)
  .get();
```

### 11.2 Cloud Function Cold Start Optimization

```javascript
// Keep connections alive outside handler
const twilioClient = twilio(accountSid, authToken);  // Initialize once
const db = admin.firestore();  // Reuse instance

export const sendSMS = functions.https.onCall(async (data) => {
  // Use pre-initialized clients
  await twilioClient.messages.create({...});
});
```

### 11.3 Batch Operations

```javascript
// Instead of individual updates
for (const queueId of queueIds) {
  await db.doc(`queues/${queueId}`).update({status: 'seated'});
}

// Use batch writes (max 500 per batch)
const batch = db.batch();
queueIds.forEach(id => {
  batch.update(db.doc(`queues/${id}`), {status: 'seated'});
});
await batch.commit();
```

---

## 12. Testing

### 12.1 Unit Tests for Cloud Functions

```javascript
// functions/test/onQueueCreate.test.ts

import * as admin from 'firebase-admin';
import * as test from 'firebase-functions-test';

const testEnv = test();

describe('onQueueCreate', () => {
  beforeAll(() => {
    admin.initializeApp();
  });

  afterAll(() => {
    testEnv.cleanup();
  });

  it('should generate queue number on create', async () => {
    const snap = testEnv.firestore.makeDocumentSnapshot(
      { phoneNumber: '09171234567', groupSize: 4 },
      'stores/store_001/queues/queue_001'
    );

    const wrapped = testEnv.wrap(onQueueCreate);
    await wrapped(snap);

    const doc = await admin.firestore()
      .doc('stores/store_001/queues/queue_001')
      .get();

    expect(doc.data().queueNumber).toMatch(/^Q-\d{8}-\d{3}$/);
  });
});
```

### 12.2 Integration Tests

```bash
# Run emulator suite
firebase emulators:start

# Run tests against emulators
npm test
```

---

## 13. Cost Estimation

### 13.1 Firestore Costs (Per Store, 100 customers/day)

**Reads:**
- Queue list refreshes: 100 customers × 10 refreshes = 1,000 reads/day
- Analytics: 50 reads/day
- Total: ~1,050 reads/day = 31,500/month
- Cost: FREE (50K reads/day free tier)

**Writes:**
- New registrations: 100/day
- Status updates: 100 × 3 (called, seated) = 300/day
- Analytics updates: 24 (hourly) = 24/day
- Total: ~424 writes/day = 12,720/month
- Cost: FREE (20K writes/day free tier)

**Storage:**
- ~500 KB per 100 queues
- 30 days retention = ~15 MB/month
- Cost: FREE (1 GB free tier)

### 13.2 Cloud Functions Costs

**Invocations:**
- onQueueCreate: 100/day
- onQueueUpdate: 300/day
- sendSMS: 100/day
- Scheduled (aggregateAnalytics): 24/day
- Total: ~524/day = 15,720/month
- Cost: FREE (2M invocations/month free tier)

**Compute Time (GB-seconds):**
- Avg 256 MB × 1 second per invocation
- 15,720 × 0.256 GB × 1 sec = 4,024 GB-sec/month
- Cost: FREE (400K GB-sec free tier)

### 13.3 SMS Costs (Largest Expense)

**Twilio:**
- 100 SMS/day × 30 days = 3,000 SMS/month
- $0.015 per SMS = $45/month per store

**Semaphore (Philippine Alternative):**
- 3,000 SMS/month × ₱0.75 = ₱2,250/month (~$40/month)

### 13.4 Total Monthly Cost (Per Store)

- Firestore: $0 (within free tier)
- Cloud Functions: $0 (within free tier)
- Firebase Auth: $0 (free tier)
- SMS (Twilio): $45
- **Total: ~$45/month per store**

---

## 14. Migration from In-Memory to Firestore

### 14.1 Migration Steps

1. **Create Firestore collections**
   - Deploy schema structure
   - Set up indexes
   - Configure security rules

2. **Migrate dummy data**
   ```javascript
   // One-time migration script
   const dummyRegistrations = [...];

   for (const reg of dummyRegistrations) {
     await db.collection('stores/store_001/queues').add({
       ...reg,
       registeredAt: admin.firestore.Timestamp.now(),
     });
   }
   ```

3. **Update Flutter app**
   - Replace in-memory lists with Firestore queries
   - Implement StreamProviders for real-time updates

4. **Test migration**
   - Use Firestore emulator for local testing
   - Verify data integrity

5. **Deploy**
   - Deploy Cloud Functions
   - Deploy Firestore rules
   - Update Flutter app

---

## 15. Backup & Disaster Recovery

### 15.1 Automated Backups

**Enable Firestore automatic backups:**
```bash
gcloud firestore backups schedules create \
  --database='(default)' \
  --recurrence=daily \
  --retention=7d
```

### 15.2 Manual Export

```bash
gcloud firestore export gs://[BUCKET_NAME]/[EXPORT_FOLDER]
```

### 15.3 Point-in-Time Recovery

Firestore retains deleted data for 7 days by default.

**Restore deleted document:**
```javascript
// Use Firebase Admin SDK to access document history
const snapshot = await admin.firestore()
  .doc('stores/store_001/queues/queue_001')
  .get({ readTime: timestampBeforeDeletion });
```

---

**End of Backend Specification**
