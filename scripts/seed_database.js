/**
 * EngageBot — Database Seeder
 * Seeds Firebase Auth, Firestore, and Realtime Database with two teacher accounts.
 *
 * SETUP (run once):
 *   1. Firebase Console → Project Settings → Service accounts
 *      → "Generate new private key" → save the file as:
 *         scripts/service-account.json
 *   2. In this folder run:
 *         npm install
 *   3. Then run:
 *         node seed_database.js
 *
 * ACCOUNTS CREATED:
 *   Teacher 1 (Google Sign-In):
 *     → Update GOOGLE_TEACHER_EMAIL below to your real Google account email.
 *     → Sign in with that Google account in the app — it links automatically.
 *
 *   Teacher 2 (Email/Password):
 *     Email:    rahman.aziz@engagebot.edu.my
 *     Password: Demo@1234
 */

const admin = require('firebase-admin');
const serviceAccount = require('./service-account.json');

// ── CONFIG — update before running ───────────────────────────────────────────
const GOOGLE_TEACHER_EMAIL = 'alysha2803@gmail.com'; // ← replace with your Google account email

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://engagebot-498717-default-rtdb.firebaseio.com',
});

const db = admin.firestore();
const rtdb = admin.database();

// ── Teacher IDs ───────────────────────────────────────────────────────────────
const SARAH_ID  = 'teacher_sarah_halim';
const RAHMAN_ID = 'teacher_rahman_aziz';

// ── Teachers ──────────────────────────────────────────────────────────────────
const TEACHERS = {
  [SARAH_ID]: {
    name: 'Ms. Sarah Halim',
    email: GOOGLE_TEACHER_EMAIL,
    school: 'SMK Bandar Kinrara',
    subject: 'Mathematics',
    avatarUrl: '',
  },
  [RAHMAN_ID]: {
    name: 'Mr. Rahman Aziz',
    email: 'rahman.aziz@engagebot.edu.my',
    school: 'SMK Taman Desa',
    subject: 'Science',
    avatarUrl: '',
  },
};

// ── Classes ───────────────────────────────────────────────────────────────────
// Sarah teaches Mathematics (5 classes), Rahman teaches Science (3 classes).
const CLASSES = [
  { id: 'cls_1usaha',  code: '1 USAHA', subject: 'Mathematics', teacherId: SARAH_ID,  studentCount: 28, status: 'online'  },
  { id: 'cls_2jujur',  code: '2 JUJUR', subject: 'Mathematics', teacherId: SARAH_ID,  studentCount: 30, status: 'online'  },
  { id: 'cls_3tekun',  code: '3 TEKUN', subject: 'Mathematics', teacherId: SARAH_ID,  studentCount: 32, status: 'online'  },
  { id: 'cls_4gigih',  code: '4 GIGIH', subject: 'Add Maths',   teacherId: SARAH_ID,  studentCount: 24, status: 'offline' },
  { id: 'cls_5cekal',  code: '5 CEKAL', subject: 'Add Maths',   teacherId: SARAH_ID,  studentCount: 30, status: 'online'  },
  { id: 'cls_r_4alfa', code: '4 ALFA',  subject: 'Science',     teacherId: RAHMAN_ID, studentCount: 26, status: 'online'  },
  { id: 'cls_r_4beta', code: '4 BETA',  subject: 'Science',     teacherId: RAHMAN_ID, studentCount: 28, status: 'offline' },
  { id: 'cls_r_5sains',code: '5 SAINS', subject: 'Biology',     teacherId: RAHMAN_ID, studentCount: 22, status: 'online'  },
];

// ── Students ──────────────────────────────────────────────────────────────────
const STUDENTS = [
  // ── 1 USAHA (Sarah) ────────────────────────────────────────────────────────
  { id: 'stu_ahmad',    name: 'Ahmad Firdaus',      classCode: '1 USAHA', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },
  { id: 'stu_aina',     name: 'Aina Syahira',       classCode: '1 USAHA', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },
  { id: 'stu_hamid',    name: 'Hamid Roslan',       classCode: '1 USAHA', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },
  { id: 'stu_maya',     name: 'Maya Delisha',       classCode: '1 USAHA', teacherId: SARAH_ID,  status: 'distracted', statusNote: 'Often distracted near the window' },
  { id: 'stu_badrul',   name: 'Badrul Hisham',      classCode: '1 USAHA', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },
  { id: 'stu_hani',     name: 'Hani Aisyah',        classCode: '1 USAHA', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },

  // ── 2 JUJUR (Sarah) ────────────────────────────────────────────────────────
  { id: 'stu_haziq',    name: 'Haziq Iqmal',        classCode: '2 JUJUR', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },
  { id: 'stu_aishah',   name: 'Aishah Nabilah',     classCode: '2 JUJUR', teacherId: SARAH_ID,  status: 'distracted', statusNote: '' },
  { id: 'stu_rahman_s', name: 'Rahman Kamal',       classCode: '2 JUJUR', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },
  { id: 'stu_suria',    name: 'Suria Binti Azlan',  classCode: '2 JUJUR', teacherId: SARAH_ID,  status: 'flagged',    statusNote: 'Needs 1-on-1 attention' },
  { id: 'stu_jeffri',   name: 'Jeffri Azwan',       classCode: '2 JUJUR', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },
  { id: 'stu_nadia',    name: 'Nadia Farhan',       classCode: '2 JUJUR', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },

  // ── 3 TEKUN (Sarah) ────────────────────────────────────────────────────────
  { id: 'stu_ali_zain', name: 'Ali Zain',           classCode: '3 TEKUN', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },
  { id: 'stu_sarah_m',  name: 'Sarah Marsya',       classCode: '3 TEKUN', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },
  { id: 'stu_amir_k',   name: 'Amir Khairul',       classCode: '3 TEKUN', teacherId: SARAH_ID,  status: 'distracted', statusNote: '' },
  { id: 'stu_fatimah',  name: 'Fatimah Binti Hamdan',classCode: '3 TEKUN',teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },
  { id: 'stu_hafiz_r',  name: 'Hafiz Ridzuan',      classCode: '3 TEKUN', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },
  { id: 'stu_nurul_f',  name: 'Nurul Farhana',      classCode: '3 TEKUN', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },

  // ── 4 GIGIH (Sarah) ────────────────────────────────────────────────────────
  { id: 'stu_farid',    name: 'Farid Asyraf',       classCode: '4 GIGIH', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },
  { id: 'stu_lina',     name: 'Lina Azura',         classCode: '4 GIGIH', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },
  { id: 'stu_karim',    name: 'Karim Imran',        classCode: '4 GIGIH', teacherId: SARAH_ID,  status: 'distracted', statusNote: '' },
  { id: 'stu_zara',     name: 'Zara Batrisyia',     classCode: '4 GIGIH', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },
  { id: 'stu_dani',     name: 'Dani Hafeez',        classCode: '4 GIGIH', teacherId: SARAH_ID,  status: 'flagged',    statusNote: 'Persistent off-task behaviour' },
  { id: 'stu_sofea',    name: 'Sofea Insyirah',     classCode: '4 GIGIH', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },

  // ── 5 CEKAL (Sarah) ────────────────────────────────────────────────────────
  { id: 'stu_azri',     name: 'Azri Hakimi',        classCode: '5 CEKAL', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },
  { id: 'stu_izzati',   name: 'Izzati Najwa',       classCode: '5 CEKAL', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },
  { id: 'stu_ridzuan',  name: 'Ridzuan Hanafi',     classCode: '5 CEKAL', teacherId: SARAH_ID,  status: 'distracted', statusNote: '' },
  { id: 'stu_farhana',  name: 'Farhana Qistina',    classCode: '5 CEKAL', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },
  { id: 'stu_lutfi',    name: 'Lutfi Hakim',        classCode: '5 CEKAL', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },
  { id: 'stu_shira',    name: 'Shira Balqis',       classCode: '5 CEKAL', teacherId: SARAH_ID,  status: 'engaged',    statusNote: '' },

  // ── 4 ALFA (Rahman) ────────────────────────────────────────────────────────
  { id: 'stu_r_amirul', name: 'Amirul Aqif',        classCode: '4 ALFA',  teacherId: RAHMAN_ID, status: 'engaged',    statusNote: '' },
  { id: 'stu_r_balkis', name: 'Balkis Nadia',       classCode: '4 ALFA',  teacherId: RAHMAN_ID, status: 'engaged',    statusNote: '' },
  { id: 'stu_r_cheng',  name: 'Cheng Wei Lun',      classCode: '4 ALFA',  teacherId: RAHMAN_ID, status: 'distracted', statusNote: '' },
  { id: 'stu_r_dalila', name: 'Dalila Hanum',       classCode: '4 ALFA',  teacherId: RAHMAN_ID, status: 'engaged',    statusNote: '' },
  { id: 'stu_r_emir',   name: 'Emir Zulhilmi',      classCode: '4 ALFA',  teacherId: RAHMAN_ID, status: 'flagged',    statusNote: 'Struggling with new syllabus' },
  { id: 'stu_r_fatin',  name: 'Fatin Husna',        classCode: '4 ALFA',  teacherId: RAHMAN_ID, status: 'engaged',    statusNote: '' },

  // ── 4 BETA (Rahman) ────────────────────────────────────────────────────────
  { id: 'stu_r_ghazi',  name: 'Ghazi Ariffin',      classCode: '4 BETA',  teacherId: RAHMAN_ID, status: 'engaged',    statusNote: '' },
  { id: 'stu_r_hawa',   name: 'Hawa Maisarah',      classCode: '4 BETA',  teacherId: RAHMAN_ID, status: 'engaged',    statusNote: '' },
  { id: 'stu_r_irfan',  name: 'Irfan Zulkifli',     classCode: '4 BETA',  teacherId: RAHMAN_ID, status: 'distracted', statusNote: '' },
  { id: 'stu_r_jannah', name: 'Jannah Rashidah',    classCode: '4 BETA',  teacherId: RAHMAN_ID, status: 'engaged',    statusNote: '' },
  { id: 'stu_r_khalis', name: 'Khalis Aiman',       classCode: '4 BETA',  teacherId: RAHMAN_ID, status: 'engaged',    statusNote: '' },

  // ── 5 SAINS (Rahman) ───────────────────────────────────────────────────────
  { id: 'stu_r_laila',  name: 'Laila Hazwani',      classCode: '5 SAINS', teacherId: RAHMAN_ID, status: 'engaged',    statusNote: '' },
  { id: 'stu_r_musa',   name: 'Musa Aminuddin',     classCode: '5 SAINS', teacherId: RAHMAN_ID, status: 'engaged',    statusNote: '' },
  { id: 'stu_r_naim',   name: 'Naim Fauzan',        classCode: '5 SAINS', teacherId: RAHMAN_ID, status: 'distracted', statusNote: '' },
  { id: 'stu_r_orked',  name: 'Orked Syafiqa',      classCode: '5 SAINS', teacherId: RAHMAN_ID, status: 'engaged',    statusNote: '' },
  { id: 'stu_r_puteri', name: 'Puteri Alya',        classCode: '5 SAINS', teacherId: RAHMAN_ID, status: 'engaged',    statusNote: '' },
];

// ─────────────────────────────────────────────────────────────────────────────
// Firestore seeder — used by the Flutter teacher app
// ─────────────────────────────────────────────────────────────────────────────

async function seedFirestore(rahmanUid) {
  console.log('\nSeeding Firestore...');

  const batch1 = db.batch();

  // Teachers
  for (const [id, data] of Object.entries(TEACHERS)) {
    batch1.set(db.collection('teachers').doc(id), data);
  }

  // users/{uid} for Rahman — created immediately since we have his UID.
  // Sarah's users/{uid} is created automatically on first Google sign-in
  // by the app's auth flow (auth_provider.dart → signInWithGoogle).
  batch1.set(db.collection('users').doc(rahmanUid), {
    teacherId: RAHMAN_ID,
    role: 'teacher',
    email: 'rahman.aziz@engagebot.edu.my',
  });

  // Classes
  for (const cls of CLASSES) {
    batch1.set(db.collection('classes').doc(cls.id), {
      code: cls.code,
      subject: cls.subject,
      teacherId: cls.teacherId,
      studentCount: cls.studentCount,
      status: cls.status,
    });
  }

  await batch1.commit();
  console.log('  ✓ teachers, users, classes');

  // Students (separate batch — more records)
  const batch2 = db.batch();
  for (const s of STUDENTS) {
    batch2.set(db.collection('students').doc(s.id), {
      name: s.name,
      classCode: s.classCode,
      teacherId: s.teacherId,
      status: s.status,
      statusNote: s.statusNote,
    });
  }
  await batch2.commit();
  console.log(`  ✓ students (${STUDENTS.length} records)`);
}

// ─────────────────────────────────────────────────────────────────────────────
// Realtime Database seeder — visible in the Firebase Console RTDB tab
// ─────────────────────────────────────────────────────────────────────────────

async function seedRealtimeDatabase(rahmanUid) {
  console.log('\nSeeding Realtime Database...');

  const payload = { teachers: {}, classes: {}, students: {}, users: {} };

  for (const [id, t] of Object.entries(TEACHERS)) {
    payload.teachers[id] = t;
  }

  payload.users[rahmanUid] = {
    teacherId: RAHMAN_ID,
    role: 'teacher',
    email: 'rahman.aziz@engagebot.edu.my',
  };

  for (const cls of CLASSES) {
    payload.classes[cls.id] = {
      code: cls.code,
      subject: cls.subject,
      teacherId: cls.teacherId,
      studentCount: cls.studentCount,
      status: cls.status,
    };
  }

  for (const s of STUDENTS) {
    payload.students[s.id] = {
      name: s.name,
      classCode: s.classCode,
      teacherId: s.teacherId,
      status: s.status,
      statusNote: s.statusNote,
    };
  }

  await rtdb.ref('/').update(payload);
  console.log('  ✓ teachers, users, classes, students');
}

// ─────────────────────────────────────────────────────────────────────────────
// Main
// ─────────────────────────────────────────────────────────────────────────────

async function main() {
  console.log('EngageBot Database Seeder');
  console.log('=========================');

  if (GOOGLE_TEACHER_EMAIL === 'YOUR_GOOGLE_EMAIL@gmail.com') {
    console.warn('\nWARNING: GOOGLE_TEACHER_EMAIL is still the placeholder.');
    console.warn('         Update it at the top of this file before testing Google sign-in.\n');
  }

  // Create email/password Firebase Auth account for Rahman.
  // If it already exists, reuse the existing UID.
  let rahmanUid;
  try {
    const user = await admin.auth().createUser({
      email: 'rahman.aziz@engagebot.edu.my',
      password: 'Demo@1234',
      displayName: 'Mr. Rahman Aziz',
      emailVerified: true,
    });
    rahmanUid = user.uid;
    console.log('\n✓ Created Auth account: rahman.aziz@engagebot.edu.my');
  } catch (err) {
    if (err.code === 'auth/email-already-exists') {
      const user = await admin.auth().getUserByEmail('rahman.aziz@engagebot.edu.my');
      rahmanUid = user.uid;
      console.log('\n  Auth account already exists — reusing UID for rahman.aziz@engagebot.edu.my');
    } else {
      throw err;
    }
  }

  await seedFirestore(rahmanUid);
  await seedRealtimeDatabase(rahmanUid);

  console.log('\n=========================');
  console.log('Done! Accounts ready:\n');
  console.log('  Teacher 1 — Google Sign-In');
  console.log(`    Email   : ${GOOGLE_TEACHER_EMAIL}`);
  console.log('    How     : Tap "Continue with Google" in the app\n');
  console.log('  Teacher 2 — Email / Password');
  console.log('    Email   : rahman.aziz@engagebot.edu.my');
  console.log('    Password: Demo@1234');
  console.log('    How     : Enter in the email/password fields in the app\n');

  process.exit(0);
}

main().catch(err => {
  console.error('\nSeeder failed:', err.message);
  process.exit(1);
});
