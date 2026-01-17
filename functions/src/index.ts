import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

export const generateIndustryStarterPack = functions.https.onCall(async (data, context) => {
  const orgId = data.orgId as string;
  const industryKey = data.industryKey as string;
  const answersMap = (data.answersMap ?? {}) as Record<string, string>;

  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required.');
  }
  if (!orgId || !industryKey) {
    throw new functions.https.HttpsError('invalid-argument', 'orgId and industryKey are required.');
  }

  const subscriptionRef = db.collection('subscriptions').doc(orgId);
  const subscriptionSnap = await subscriptionRef.get();
  const subscription = subscriptionSnap.data();
  const creditsRemaining = (subscription?.aiCreditsRemaining as number | undefined) ?? 0;
  if (creditsRemaining <= 0) {
    throw new functions.https.HttpsError('failed-precondition', 'No AI credits remaining.');
  }

  const industryPackQuery = await db
    .collection('orgs')
    .doc(orgId)
    .collection('industryPacks')
    .where('industryKey', '==', industryKey)
    .limit(1)
    .get();

  const packDoc = industryPackQuery.docs[0];
  const pack = packDoc?.data() ?? {
    title: 'Starter Pack',
    description: 'Default industry starter pack.',
    version: 1,
    promptTemplate: 'N/A',
    schemaJson: {},
  };

  const manualId = db.collection('orgs').doc(orgId).collection('manuals').doc().id;
  const sopId = db.collection('orgs').doc(orgId).collection('sops').doc().id;
  const checklistId = db.collection('orgs').doc(orgId).collection('checklists').doc().id;
  const trainingId = db.collection('orgs').doc(orgId).collection('trainingPaths').doc().id;

  const now = admin.firestore.FieldValue.serverTimestamp();

  const batch = db.batch();

  batch.set(db.collection('orgs').doc(orgId).collection('manuals').doc(manualId), {
    title: `${pack.title} Manual`,
    description: `${pack.description} (${industryKey})`,
    status: 'DRAFT',
    version: 1,
    updatedAt: now,
  });

  batch.set(db.collection('orgs').doc(orgId).collection('sops').doc(sopId), {
    manualId,
    sectionId: 'core',
    title: 'Opening Shift SOP',
    purpose: 'Prepare the site for service based on the onboarding answers.',
    scope: answersMap.q1 ?? 'All staff',
    steps: [
      'Review overnight notes and equipment status.',
      'Verify prep list and inventory readiness.',
      'Complete safety checks and sign off in checklist.',
    ],
    standards: 'All steps completed before opening.',
    commonFailures: ['Missing prep items', 'Equipment not calibrated'],
    escalationTriggers: ['Critical equipment failure', 'Safety hazard'],
    status: 'DRAFT',
    version: 1,
    updatedAt: now,
  });

  batch.set(db.collection('orgs').doc(orgId).collection('checklists').doc(checklistId), {
    title: 'Daily Opening Checklist',
    frequency: 'Daily',
    roleTarget: 'SITE_MANAGER',
    siteId: null,
    items: [
      {
        label: 'Temperature logs checked',
        requiresPhoto: false,
        requiresValue: true,
        isCritical: true,
      },
      {
        label: 'Equipment safety inspection',
        requiresPhoto: true,
        requiresValue: false,
        isCritical: true,
      },
      {
        label: 'Prep station sanitation',
        requiresPhoto: false,
        requiresValue: false,
        isCritical: false,
      },
    ],
    active: true,
    status: 'DRAFT',
    version: 1,
  });

  batch.set(db.collection('orgs').doc(orgId).collection('trainingPaths').doc(trainingId), {
    title: 'Onboarding: Kitchen Safety',
    description: 'Starter training path auto-generated from onboarding answers.',
    status: 'DRAFT',
    version: 1,
    updatedAt: now,
  });

  const usageRef = db.collection('usage').doc();
  batch.set(usageRef, {
    orgId,
    userId: context.auth.uid,
    type: 'AI_GENERATION',
    creditsUsed: 1,
    createdAt: now,
  });

  batch.set(subscriptionRef, {
    aiCreditsRemaining: creditsRemaining - 1,
  }, { merge: true });

  await batch.commit();

  return {
    status: 'ok',
    manualId,
    sopId,
    checklistId,
    trainingId,
  };
});

export const createStripeCheckoutSession = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required.');
  }
  return {
    status: 'placeholder',
    message: 'Stripe checkout not configured. Wire Stripe SDK here.',
  };
});
