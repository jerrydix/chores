// Adversarial probes: what does the deliberately-loosened join exception
// actually permit to someone who is not joining at all?
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds, initializeTestEnvironment }
  from '@firebase/rules-unit-testing';
import { doc, setDoc, updateDoc } from 'firebase/firestore';

const WG = 'wg1', ALICE = 'alice', BOB = 'bob', CAROL = 'carol';
let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'chores-abuse',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8') },
  });
});
after(() => testEnv?.cleanup());

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'wgs', WG), {
      name: 'Flat 3', count: 2, memberIDs: [0, 1], maxMembers: 4, cw: 40,
      tasks: { Kitchen: { Dishes: false } }, rolesConfig: [],
      algorithmType: 'rotating', noRepeatWindow: 1,
    });
    for (const [uid, slot] of [[ALICE, 0], [BOB, 1]]) {
      await setDoc(doc(db, 'wgs', WG, 'members', uid),
        { uid, memberID: slot, username: uid, active: true });
    }
  });
});

const as = (uid) => testEnv.authenticatedContext(uid).firestore();

describe('join exception, probed adversarially', () => {
  it('a genuine join adding one slot is allowed', async () => {
    await assertSucceeds(updateDoc(doc(as(CAROL), 'wgs', WG), {
      count: 3, memberIDs: [0, 1, 2],
    }));
  });

  it('outsider cannot wipe the slot list', async () => {
    await assertFails(updateDoc(doc(as(CAROL), 'wgs', WG), {
      count: 0, memberIDs: [],
    }));
  });

  it('outsider cannot overstate count past maxMembers', async () => {
    await assertFails(updateDoc(doc(as(CAROL), 'wgs', WG), {
      count: 99, memberIDs: [0, 1, 2, 3, 4, 5, 6, 7],
    }));
  });

  it('outsider cannot drop a slot held by a member', async () => {
    await assertFails(updateDoc(doc(as(CAROL), 'wgs', WG), {
      count: 2, memberIDs: [0, 0],
    }));
  });

  it('count must match the slot list', async () => {
    await assertFails(updateDoc(doc(as(CAROL), 'wgs', WG), {
      count: 1, memberIDs: [0, 1, 2],
    }));
  });

  it('cannot add two slots at once', async () => {
    await assertFails(updateDoc(doc(as(CAROL), 'wgs', WG), {
      count: 4, memberIDs: [0, 1, 2, 3],
    }));
  });

  it('cannot exceed maxMembers even by a legal single step', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await updateDoc(doc(ctx.firestore(), 'wgs', WG),
        { count: 4, memberIDs: [0, 1, 2, 3] });
    });
    await assertFails(updateDoc(doc(as(CAROL), 'wgs', WG), {
      count: 5, memberIDs: [0, 1, 2, 3, 4],
    }));
  });

  it('a legacy WG with no memberIDs can still be seeded on first join', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await setDoc(doc(db, 'wgs', 'legacy'), {
        name: 'Old flat', count: 2, maxMembers: 4, cw: 40,
        tasks: {}, rolesConfig: [], algorithmType: 'rotating',
      });
    });
    // WgRepository seeds the whole list from the existing member docs.
    await assertSucceeds(updateDoc(doc(as(CAROL), 'wgs', 'legacy'), {
      count: 3, memberIDs: [0, 1, 2],
    }));
  });

  it('a leaving member may shrink the slot list', async () => {
    // Allowed via isMember, not the join exception: the member doc still
    // exists when rules evaluate the transaction.
    await assertSucceeds(updateDoc(doc(as(ALICE), 'wgs', WG), {
      count: 1, memberIDs: [1],
    }));
  });

  it('chores stay protected from the outsider', async () => {
    await assertFails(updateDoc(doc(as(CAROL), 'wgs', WG), {
      tasks: { Kitchen: { Dishes: true } },
    }));
  });
});

describe('member eviction', () => {
  it('KNOWN: any member can delete a housemate membership at will', async () => {
    await assertSucceeds(
      // Nothing ties this to the last-one-out teardown path.
      import('firebase/firestore').then(({ deleteDoc, doc: d }) =>
        deleteDoc(d(as(ALICE), 'wgs', WG, 'members', BOB))));
  });
});
