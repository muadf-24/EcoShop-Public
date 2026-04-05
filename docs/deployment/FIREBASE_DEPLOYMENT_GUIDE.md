# 🚀 Firebase Security Rules Deployment Guide

**Project:** EcoShop E-Commerce Application  
**Deployment Date:** February 24, 2026  
**Critical Priority:** ⚠️ IMMEDIATE DEPLOYMENT REQUIRED

---

## 📋 Pre-Deployment Checklist

Before deploying, ensure you have:

- [ ] Firebase CLI installed
- [ ] Firebase project access (Admin or Editor role)
- [ ] Backup of current rules (if any exist)
- [ ] Test environment available
- [ ] 30 minutes of uninterrupted time

---

## 🔧 Step 1: Install Firebase CLI

### For Windows (PowerShell):
```powershell
# Install via npm
npm install -g firebase-tools

# Verify installation
firebase --version
```

### For macOS/Linux:
```bash
# Install via npm
npm install -g firebase-tools

# Or use standalone binary
curl -sL https://firebase.tools | bash
```

**Expected Output:**
```
13.0.0 (or higher)
```

---

## 🔐 Step 2: Authenticate with Firebase

```powershell
# Login to Firebase
firebase login

# This will open a browser window for Google authentication
# Select the Google account associated with your Firebase project
```

**Expected Output:**
```
✔  Success! Logged in as your-email@example.com
```

### Troubleshooting Login Issues:

**If browser doesn't open:**
```powershell
firebase login --no-localhost
```

**If behind a proxy:**
```powershell
set HTTP_PROXY=http://proxy-server:port
set HTTPS_PROXY=http://proxy-server:port
firebase login
```

---

## 🎯 Step 3: Initialize Firebase in Your Project

Navigate to your project root directory:

```powershell
cd path\to\ecoshop
```

### Option A: If firebase.json exists (Update mode)

Check your current `firebase.json`:

```powershell
cat firebase.json
```

**Expected content:**
```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "storage": {
    "rules": "storage.rules"
  }
}
```

✅ **If this exists, skip to Step 4.**

---

### Option B: If firebase.json doesn't exist (First-time setup)

```powershell
# Initialize Firebase
firebase init

# Select the following options:
# ◉ Firestore: Configure security rules and indexes files
# ◉ Storage: Configure security rules
# 
# Use space bar to select, Enter to confirm

# When prompted:
# ? What file should be used for Firestore Rules? → firestore.rules
# ? What file should be used for Storage Rules? → storage.rules
# ? File firestore.rules already exists. Do you want to overwrite? → No
# ? File storage.rules already exists. Do you want to overwrite? → No
```

**Expected Output:**
```
✔  Firebase initialization complete!
```

---

## 📝 Step 4: Verify Rules Files

Ensure both files are in your project root:

```powershell
# Check if files exist
Test-Path firestore.rules
Test-Path storage.rules

# Preview first 20 lines of each
Get-Content firestore.rules -Head 20
Get-Content storage.rules -Head 20
```

**Expected Output:**
```
True
True
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    ...
```

---

## 🧪 Step 5: Test Rules Locally (CRITICAL - DO NOT SKIP)

### Start Firebase Emulators:

```powershell
# Install emulators (first time only)
firebase init emulators

# Select:
# ◉ Firestore Emulator
# ◉ Storage Emulator
# 
# Use default ports (8080, 9199)

# Start emulators
firebase emulators:start
```

**Expected Output:**
```
┌─────────────────────────────────────────────────────────────┐
│ ✔  All emulators ready! It is now safe to connect your app. │
│ i  View Emulator UI at http://localhost:4000                │
└─────────────────────────────────────────────────────────────┘

┌────────────┬────────────────┬─────────────────────────────────┐
│ Emulator   │ Host:Port      │ View in Emulator UI             │
├────────────┼────────────────┼─────────────────────────────────┤
│ Firestore  │ localhost:8080 │ http://localhost:4000/firestore │
│ Storage    │ localhost:9199 │ http://localhost:4000/storage   │
└────────────┴────────────────┴─────────────────────────────────┘
```

### Test Rules in Emulator UI:

1. Open http://localhost:4000 in your browser
2. Go to **Firestore** tab
3. Try creating a test document:

```javascript
// Test 1: Unauthenticated write should FAIL
// Path: /users/test-user-123
// Data: { "name": "Hacker" }
// Expected: Permission denied ✅
```

4. Go to **Authentication** tab in emulator
5. Add a test user with UID: `test-user-123`
6. Try again:

```javascript
// Test 2: Authenticated write to own user doc should SUCCEED
// Auth UID: test-user-123
// Path: /users/test-user-123
// Data: {
//   "name": "John Doe",
//   "email": "john@example.com",
//   "created_at": "2026-02-24T13:00:00Z"
// }
// Expected: Success ✅
```

7. Try unauthorized access:

```javascript
// Test 3: Access another user's data should FAIL
// Auth UID: test-user-123
// Path: /users/different-user-456
// Data: { "name": "Unauthorized" }
// Expected: Permission denied ✅
```

### Automated Testing (Optional but Recommended):

Create `firestore-rules.test.js`:

```javascript
const { initializeTestEnvironment } = require('@firebase/rules-unit-testing');

let testEnv;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'ecoshop-store-2026',
    firestore: {
      rules: require('fs').readFileSync('firestore.rules', 'utf8'),
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

test('should allow user to read own profile', async () => {
  const authenticatedDb = testEnv.authenticatedContext('user123').firestore();
  await assertSucceeds(authenticatedDb.collection('users').doc('user123').get());
});

test('should deny user reading other profiles', async () => {
  const authenticatedDb = testEnv.authenticatedContext('user123').firestore();
  await assertFails(authenticatedDb.collection('users').doc('user456').get());
});
```

Run tests:
```powershell
npm test
```

---

## 🚀 Step 6: Deploy to Production

### IMPORTANT: Backup Current Rules First

```powershell
# Get current Firestore rules
firebase firestore:get > firestore.rules.backup

# Get current Storage rules
firebase storage:get > storage.rules.backup

# Verify backups exist
dir *.backup
```

### Deploy Firestore Rules:

```powershell
# Deploy Firestore rules only
firebase deploy --only firestore:rules

# Confirm when prompted
```

**Expected Output:**
```
=== Deploying to 'ecoshop-store-2026'...

i  deploying firestore
i  firestore: checking firestore.rules for compilation errors...
✔  firestore: rules file firestore.rules compiled successfully
i  firestore: uploading rules firestore.rules...
✔  firestore: released rules firestore.rules to cloud.firestore

✔  Deploy complete!
```

### Deploy Storage Rules:

```powershell
# Deploy Storage rules only
firebase deploy --only storage:rules
```

**Expected Output:**
```
=== Deploying to 'ecoshop-store-2026'...

i  deploying storage
i  storage: checking storage.rules for compilation errors...
✔  storage: rules file storage.rules compiled successfully
i  storage: uploading rules storage.rules...
✔  storage: released rules storage.rules

✔  Deploy complete!
```

### Deploy Both Together:

```powershell
# Deploy both Firestore and Storage rules
firebase deploy --only firestore:rules,storage:rules
```

---

## ✅ Step 7: Verify Deployment

### Check Firestore Rules in Console:

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select project: **ecoshop-store-2026**
3. Go to **Firestore Database** → **Rules**
4. Verify the rules are updated (check timestamp)

### Check Storage Rules in Console:

1. In Firebase Console, go to **Storage** → **Rules**
2. Verify the rules are updated

### Test Live Rules:

```powershell
# Run your Flutter app against production
flutter run

# Try these actions in the app:
# 1. Register a new user → Should work ✅
# 2. Login → Should work ✅
# 3. View products → Should work ✅
# 4. Add to cart → Should work ✅
# 5. Create order → Should work (but price validation will catch manipulation) ✅
```

---

## 🔍 Step 8: Monitor Rules in Action

### Enable Firestore Monitoring:

```powershell
# Stream Firestore logs in real-time
firebase firestore:logs
```

### Check for Rule Violations:

1. Open Firebase Console → **Firestore Database** → **Usage**
2. Look for **denied reads/writes**
3. Check **Rules Simulator** to test specific scenarios

### Example Rule Simulation:

**Firestore Rules Simulator:**
```
Type: get
Location: /databases/(default)/documents/users/user123
Auth: { uid: "user123" }
Result: ✅ Allow
```

```
Type: get
Location: /databases/(default)/documents/users/user456
Auth: { uid: "user123" }
Result: ❌ Deny (permission-denied)
```

---

## 🚨 Emergency Rollback Procedure

If rules cause production issues:

### Immediate Rollback:

```powershell
# Restore previous Firestore rules
firebase deploy --only firestore:rules < firestore.rules.backup

# Or use temporary permissive rules (EMERGENCY ONLY)
echo 'rules_version = "2";
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}' > firestore.rules.emergency

firebase deploy --only firestore:rules
```

### Restore from Console:

1. Go to Firebase Console → **Firestore** → **Rules**
2. Click **Version History**
3. Select previous version
4. Click **Restore**

---

## 📊 Post-Deployment Checklist

After deploying rules, verify:

- [ ] **User Registration** works correctly
- [ ] **User Login** works correctly
- [ ] **Users can view own profile** but not others'
- [ ] **Products are publicly readable**
- [ ] **Orders can be created** with valid data
- [ ] **Order totals are validated** (client can't manipulate)
- [ ] **Wishlist is user-scoped**
- [ ] **File uploads** work with size/type restrictions
- [ ] **No permission-denied errors** in production logs (except expected ones)

---

## 🔧 Advanced: Set Up Admin Access

To perform admin operations (e.g., add products), set custom claims:

### Using Firebase Admin SDK (Node.js):

```javascript
// admin-setup.js
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function setAdminClaim(email) {
  const user = await admin.auth().getUserByEmail(email);
  await admin.auth().setCustomUserClaims(user.uid, { admin: true });
  console.log(`✅ Admin claim set for ${email}`);
}

// Set your admin email
setAdminClaim('your-admin-email@example.com');
```

Run:
```powershell
node admin-setup.js
```

**Important:** Download `serviceAccountKey.json` from Firebase Console → Project Settings → Service Accounts → Generate New Private Key

---

## 📱 Update Flutter App (CRITICAL)

After deploying rules, your app needs updates to work correctly:

### 1. Remove Mock Token (CRITICAL-001 Fix)

**This will be implemented in the next step.**

### 2. Handle Permission Errors

Add error handling in your app:

```dart
try {
  await firestore.collection('users').doc(uid).set(data);
} on FirebaseException catch (e) {
  if (e.code == 'permission-denied') {
    // Show user-friendly message
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Access Denied'),
        content: Text('You do not have permission to perform this action.'),
      ),
    );
  }
}
```

---

## 🐛 Troubleshooting

### Issue 1: "Permission Denied" on Valid Operations

**Symptoms:**
```
FirebaseException: [cloud_firestore/permission-denied] 
The caller does not have permission
```

**Diagnosis:**
```powershell
# Check if user is authenticated
firebase auth:export users.json
cat users.json

# Test rule in simulator
firebase emulators:start
# Then use Emulator UI to test exact scenario
```

**Common Causes:**
- User UID doesn't match document path
- Required fields missing in data
- Timestamp validation failing (use `FieldValue.serverTimestamp()`)

---

### Issue 2: Rules Don't Update After Deployment

**Symptoms:**
Old rules still active after deployment.

**Fix:**
```powershell
# Force cache clear
firebase deploy --only firestore:rules --force

# Verify in console (check timestamp)
```

---

### Issue 3: "rules file compiled with errors"

**Symptoms:**
```
✖  firestore: rules file firestore.rules has errors
```

**Diagnosis:**
```powershell
# Validate rules syntax
firebase firestore:validate firestore.rules
```

**Common Errors:**
- Missing semicolons
- Typo in function names
- Unclosed brackets

---

## 📞 Support & Resources

### Official Documentation:
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Storage Security Rules](https://firebase.google.com/docs/storage/security/start)
- [Rules Reference](https://firebase.google.com/docs/reference/rules)

### Testing Tools:
- [Rules Playground](https://firebaserules.com/)
- [Emulator Suite](https://firebase.google.com/docs/emulator-suite)

### Emergency Contact:
- Firebase Support: https://firebase.google.com/support
- Stack Overflow: `firebase-security-rules` tag

---

## ✅ Deployment Complete!

Once you see this output:

```
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/ecoshop-store-2026/overview
```

Your Firebase Security Rules are **LIVE** and protecting your data! 🎉

**Next Step:** Proceed to implementing CRITICAL-001 (Mock Token Fix) and BUG-005 (Order Total Validation).

---

**Deployment Log Template:**

```
Date: _______________
Deployed by: _______________
Firestore Rules Version: _______________
Storage Rules Version: _______________
Rollback Available: [ ] Yes [ ] No
Post-Deployment Tests: [ ] Passed [ ] Failed
Production Issues: [ ] None [ ] See incident log
```

---

**Document Status:** Ready for Production Deployment  
**Last Updated:** February 24, 2026  
**Next Review:** After deployment (within 24 hours)
