# BreakoutTrade — Final Check / Status

This branch (dev/flutter-scaffold) contains the completed scaffold for the BreakoutTrade user app and Admin app and a final-check commit summarizing the current status, how to test, and next steps before production.

Branch: dev/flutter-scaffold
Commit: final-check (this file)

---

What is implemented (user app)
- Home feed (FireStore stream) with search and filters
- ChartCard with cached images, premium overlay, share, unlock-by-rewarded-ad flow
- ChartDetail with PhotoView, view increment, interstitial on opens
- Premium flow: UPI deep-link, submit transaction ID to `/premiumUsers/{deviceId}`
- Notification handling (FCM + local notifications) and firebase_options.dart wired for Android
- AdMob integration (Google test IDs used) and adProvider logic
- Utility services: Firebase wrapper, UPI, FCM helper, local notifications, share util

What is implemented (admin app)
- Admin login (PIN: 1234) for quick local access
- Upload Chart (create): image upload to Storage + doc to `charts/{chartId}`
- Edit Chart (update): edit metadata and replace image (overwrites charts/{id}/chart.jpg)
- Chart List (manage): edit, delete (deletes Firestore doc and attempts to delete Storage image), smart notify action
- Send Notification screen: saves to `notifications/` and (for testing) can send via FCM legacy HTTP using a pasted server key

Firebase structure used
- charts/{chartId}
  - stockName, chartDate, targetPrice, pattern, notes, upstoxCode, timeframe, isPremium, isActive, imageUrl, views, uploadedAt
- notifications/{notifId}
  - title, body, chartId, target, sentAt, sendResult|sendError (set by server/Cloud Function)
- premiumUsers/{deviceId}
  - upiTransactionId, planType, activatedAt, expiresAt, verifiedByAdmin, deviceId, screenshotUrl

Final check notes (what you must verify locally)
1. Android applicationId
   - Ensure `android/app/build.gradle` applicationId is `com.breakouttrade.app` to match committed Firebase Android config.
   - If you use a different applicationId, generate a new `google-services.json` for that package in Firebase console and re-run FlutterFire configure.

2. Firebase config
   - I committed `android/app/google-services.json` and `lib/firebase_options.dart` (Android values).
   - Run FlutterFire configure locally if you need additional platforms or to regenerate options:
     - `dart pub global activate flutterfire_cli`
     - `flutterfire configure --project=pdf-tools-2763d`

3. AdMob
   - Test IDs are currently in `lib/core/services/admob_service.dart`. Replace with real AdMob unit IDs for production.

4. UPI
   - UPI id set to `breakouttrade@ybl` in `lib/core/services/upi_service.dart`. If you prefer remote config, move it to `appConfig` in Firestore and the admin UI will read/write it.

5. Security (important)
   - Do not include FCM server keys in client apps for production. Use a Cloud Function to send FCM messages on writes to `/notifications/`.
   - Protect admin writes: add App Check or route admin uploads/verification through a server or Cloud Functions.
   - Review Firestore and Storage rules before production.

Testing checklist (quick)
- `flutter pub get`
- `flutter run` (set target device)
- Admin app:
  - Run `admin_app/`, login with PIN `1234`, upload a chart, verify it appears under `/charts/` and in the user feed.
  - Edit a chart and replace its image; verify Storage image is updated and doc updated.
  - Delete a chart and confirm Firestore doc removed and Storage deletion attempted.
  - Use Send Notification screen to save a notification and (optionally) send via pasted server key for testing.
- User app:
  - Open premium chart: unlock via Rewarded Ad (test ad) and confirm unlocked overlay removed locally.
  - Open chart detail: interstitial may show (test ad), and views incrementation updates Firestore.
  - Notifications: if sent via server or Cloud Function, tapping notification should deep-link to chart detail.

Recommended next steps (prioritized)
1. Deploy a Cloud Function that triggers on creations in `/notifications/` and sends FCM using Admin SDK (removes server key from admin UI). I can add the function code and deployment steps if you want.
2. Add an Admin "Pending Premium" screen to approve/reject premium submissions and set `verifiedByAdmin` + `expiresAt`, and send an FCM to the device on approval. I can implement this next.
3. Harden Storage/Firestore rules and implement App Check or Cloud Function proxy for admin uploads.
4. Replace test AdMob IDs with production IDs and run a staged release.

Commit / Branch status
- Branch: dev/flutter-scaffold
- All code (user + admin) was committed there. This README update is the final-check commit.

If you want me to proceed I can:
- Add Cloud Function code + CI/deploy instructions (recommended: I will create `functions/` with code and README).
- Implement Pending Premium admin UI and wire FCM via Cloud Function.
- Replace test AdMob IDs (if you provide real IDs).

Reply with which next item you want me to implement and I will push it on dev/flutter-scaffold (or create a feature branch and PR if you prefer).
