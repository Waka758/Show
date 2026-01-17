# OpsManual AI

OpsManual AI is a multi-tenant operations manual + checklist platform with AI-generated industry packs, gamification, and SaaS foundations.

## Stack
- **Flutter** (Android/iOS/Web) with Riverpod + go_router
- **Firebase** Auth, Firestore, Storage, Cloud Functions
- Clean architecture with repository pattern in `lib/data`

## Project Structure
```
lib/
  app/            App shell + router
  data/           Models + repositories (clean architecture data layer)
  features/       Feature UI modules
functions/        Cloud Functions (TypeScript)
firestore.rules   Security rules
storage.rules     Storage rules
```

## Setup
1. Install Flutter (stable) and Firebase CLI.
2. Configure Firebase for Android/iOS/Web (`flutterfire configure`).
3. Install dependencies:
   ```bash
   flutter pub get
   cd functions && npm install
   ```

## Local Emulators
```bash
firebase emulators:start
```

## Seed Demo Data
Use the seed script to create the demo org, sites, and users. The demo login uses anonymous auth and will create the user profile on first sign-in.
```bash
cd functions
npm run seed
```

This seeds:
- `demo-org` with **2 sites**
- `OWNER` + `SITE_MANAGER` users
- Hospitality industry pack template
- Starter subscription with AI credits

## Test Roles
Update the role on the org user document in Firestore (`orgs/demo-org/users/<uid>`) to validate permissions and UI flows (e.g., `STAFF`, `SITE_MANAGER`).
Admins (`ADMIN`) can manage org content/users/sites but do not have any cross-org access.
To grant a **platform super admin** (global access across orgs), create a document at `platformAdmins/<uid>` with `{ "active": true }`. Super admins can switch the active org from the Admin Console.

## AI Generation
Cloud Function: `generateIndustryStarterPack(orgId, industryKey, answersMap)`
- Loads the industry pack template
- Writes manuals/SOPs/checklists/training stubs in **DRAFT**
- Deducts AI credits and logs usage

> **LLM integration hook:** replace the deterministic mock output in `functions/src/index.ts` with your LLM call. Use the `promptTemplate` + `schemaJson` stored in `industryPacks`.

## Stripe Billing (Foundation)
Billing is prepared by the `subscriptions/{orgId}` document. Add Stripe checkout/portal calls to Cloud Functions and update the subscription fields accordingly.

## Security Rules
- Users can only access documents under their `orgId`
- `OWNER` has write access for manuals/SOPs and admin features
- Staff read-only for manuals/SOPs
- Checklist runs restricted to checklist role targets

## Running the App
```bash
flutter run -d chrome
```

## Notes
- Checklist runs enforce **critical skipped** comments in the UI.
- Checklist items support proof fields (value + photo URL) with Firebase Storage uploads via image picker.
- Ensure iOS/Android photo permissions are configured when running on device.
