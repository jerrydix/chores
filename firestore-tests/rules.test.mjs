import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  setDoc,
  updateDoc,
} from 'firebase/firestore';

const WG = 'wg1';
const ALICE = 'alice';     // member of wg1
const BOB = 'bob';         // member of wg1
const CAROL = 'carol';     // signed in, not a member

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'chores-test',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8') },
  });
});

after(() => testEnv?.cleanup());

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'users', ALICE), { username: 'Alice', wg: WG });
    await setDoc(doc(db, 'users', BOB), { username: 'Bob', wg: WG });
    await setDoc(doc(db, 'users', CAROL), { username: 'Carol', wg: -1 });
    await setDoc(doc(db, 'wgs', WG), {
      name: 'Flat 3',
      count: 2,
      memberIDs: [0, 1],
      maxMembers: 4,
      cw: 40,
      tasks: { Kitchen: { Dishes: false } },
      rolesConfig: [{ name: 'Kitchen', tasks: [{ name: 'Dishes' }] }],
      algorithmType: 'rotating',
      noRepeatWindow: 1,
    });
    await setDoc(doc(db, 'wgs', WG, 'members', ALICE), {
      uid: ALICE, memberID: 0, username: 'Alice', active: true,
    });
    await setDoc(doc(db, 'wgs', WG, 'members', BOB), {
      uid: BOB, memberID: 1, username: 'Bob', active: true,
    });
  });
});

const as = (uid) => testEnv.authenticatedContext(uid).firestore();
const anon = () => testEnv.unauthenticatedContext().firestore();

describe('users/{uid}', () => {
  it('a user can read their own profile', async () => {
    await assertSucceeds(getDoc(doc(as(ALICE), 'users', ALICE)));
  });

  it('a user cannot read another profile (it names their household)', async () => {
    await assertFails(getDoc(doc(as(CAROL), 'users', ALICE)));
  });

  it('a user can update their own profile', async () => {
    await assertSucceeds(updateDoc(doc(as(ALICE), 'users', ALICE), { wg: -1 }));
  });

  it('a user cannot write another profile', async () => {
    await assertFails(updateDoc(doc(as(CAROL), 'users', ALICE), { wg: 'evil' }));
  });

  it('anonymous cannot read a profile', async () => {
    await assertFails(getDoc(doc(anon(), 'users', ALICE)));
  });
});

describe('wgs/{wgId} reads', () => {
  it('any signed-in user can read a WG (the picker lists them all)', async () => {
    await assertSucceeds(getDoc(doc(as(CAROL), 'wgs', WG)));
  });

  it('a member can read their WG', async () => {
    await assertSucceeds(getDoc(doc(as(ALICE), 'wgs', WG)));
  });

  it('anonymous cannot read a WG', async () => {
    await assertFails(getDoc(doc(anon(), 'wgs', WG)));
  });
});

describe('wgs/{wgId} writes', () => {
  it('a member can tick a chore', async () => {
    await assertSucceeds(updateDoc(doc(as(ALICE), 'wgs', WG), {
      tasks: { Kitchen: { Dishes: true } },
    }));
  });

  it('a non-member cannot change chores', async () => {
    await assertFails(updateDoc(doc(as(CAROL), 'wgs', WG), {
      tasks: { Kitchen: { Dishes: true } },
    }));
  });

  it('a non-member cannot rename the household', async () => {
    await assertFails(updateDoc(doc(as(CAROL), 'wgs', WG), { name: 'Hijacked' }));
  });

  it('a joining user may claim a slot (count + memberIDs only)', async () => {
    await assertSucceeds(updateDoc(doc(as(CAROL), 'wgs', WG), {
      count: 3,
      memberIDs: [0, 1, 2],
    }));
  });

  it('the join exception cannot smuggle other fields through', async () => {
    await assertFails(updateDoc(doc(as(CAROL), 'wgs', WG), {
      count: 3,
      memberIDs: [0, 1, 2],
      tasks: { Kitchen: { Dishes: true } },
    }));
  });

  it('anonymous cannot claim a slot', async () => {
    await assertFails(updateDoc(doc(anon(), 'wgs', WG), {
      count: 3,
      memberIDs: [0, 1, 2],
    }));
  });

  it('a signed-in user can create a WG', async () => {
    await assertSucceeds(setDoc(doc(as(CAROL), 'wgs', 'wgNew'), {
      name: 'New', count: 1, memberIDs: [0], maxMembers: 4, cw: 40,
      tasks: {}, rolesConfig: [], algorithmType: 'rotating', noRepeatWindow: 1,
    }));
  });

  it('anonymous cannot create a WG', async () => {
    await assertFails(setDoc(doc(anon(), 'wgs', 'wgNew'), { name: 'New' }));
  });

  it('a member can delete the household', async () => {
    await assertSucceeds(deleteDoc(doc(as(ALICE), 'wgs', WG)));
  });

  it('a non-member cannot delete the household', async () => {
    await assertFails(deleteDoc(doc(as(CAROL), 'wgs', WG)));
  });
});

describe('wgs/{wgId}/members', () => {
  it('a member can list their housemates', async () => {
    await assertSucceeds(getDocs(collection(as(ALICE), 'wgs', WG, 'members')));
  });

  it('an outsider cannot list the members', async () => {
    await assertFails(getDocs(collection(as(CAROL), 'wgs', WG, 'members')));
  });

  it('a user can read their own membership', async () => {
    await assertSucceeds(getDoc(doc(as(ALICE), 'wgs', WG, 'members', ALICE)));
  });

  it('a user can add themselves', async () => {
    await assertSucceeds(setDoc(doc(as(CAROL), 'wgs', WG, 'members', CAROL), {
      uid: CAROL, memberID: 2, username: 'Carol', active: true,
    }));
  });

  it('a user cannot add themselves under somebody else uid field', async () => {
    await assertFails(setDoc(doc(as(CAROL), 'wgs', WG, 'members', CAROL), {
      uid: ALICE, memberID: 2, username: 'Carol', active: true,
    }));
  });

  it('a user cannot add somebody else', async () => {
    await assertFails(setDoc(doc(as(CAROL), 'wgs', WG, 'members', 'dave'), {
      uid: 'dave', memberID: 2, username: 'Dave', active: true,
    }));
  });

  it('a member can toggle their own availability', async () => {
    await assertSucceeds(
      updateDoc(doc(as(ALICE), 'wgs', WG, 'members', ALICE), { active: false }));
  });

  it('a member cannot toggle a housemate availability', async () => {
    await assertFails(
      updateDoc(doc(as(ALICE), 'wgs', WG, 'members', BOB), { active: false }));
  });

  it('a user can remove their own membership', async () => {
    await assertSucceeds(
      deleteDoc(doc(as(ALICE), 'wgs', WG, 'members', ALICE)));
  });

  it('a member can remove a housemate doc (last-one-out teardown)', async () => {
    await assertSucceeds(deleteDoc(doc(as(ALICE), 'wgs', WG, 'members', BOB)));
  });

  it('an outsider cannot remove a membership', async () => {
    await assertFails(deleteDoc(doc(as(CAROL), 'wgs', WG, 'members', ALICE)));
  });
});
