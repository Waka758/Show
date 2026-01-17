import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

async function seed() {
  const orgId = 'demo-org';
  const ownerId = 'owner-1';
  const managerId = 'manager-1';

  const orgRef = db.collection('orgs').doc(orgId);
  await orgRef.set({
    name: 'OpsManual Demo Org',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  await orgRef.collection('sites').doc('site-1').set({
    name: 'Downtown Kitchen',
    timezone: 'America/Chicago',
  });

  await orgRef.collection('sites').doc('site-2').set({
    name: 'Airport Kitchen',
    timezone: 'America/New_York',
  });

  await orgRef.collection('users').doc(ownerId).set({
    fullName: 'Alex Owner',
    role: 'OWNER',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  await orgRef.collection('users').doc(managerId).set({
    fullName: 'Jamie Manager',
    role: 'SITE_MANAGER',
    siteId: 'site-1',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  await orgRef.collection('industryPacks').doc('hospitality-kitchen-v1').set({
    industryKey: 'hospitality_kitchen',
    title: 'Hospitality - Multi-site Kitchen',
    description: 'Safety, hygiene, and prep workflows for multi-location kitchens.',
    version: 1,
    promptTemplate: 'Generate a starter manual and checklist pack for a multi-site kitchen.',
    schemaJson: {
      manuals: ['title', 'description', 'sections'],
      sops: ['title', 'steps', 'standards'],
      checklists: ['title', 'items', 'frequency'],
      trainingPaths: ['title', 'modules'],
    },
  });

  await db.collection('subscriptions').doc(orgId).set({
    orgId,
    plan: 'STARTER',
    seats: 10,
    sitesLimit: 3,
    aiCreditsMonthly: 10,
    aiCreditsRemaining: 5,
    status: 'ACTIVE',
  });

  console.log('Seed data created.');
}

seed().catch((error) => {
  console.error(error);
  process.exit(1);
});
