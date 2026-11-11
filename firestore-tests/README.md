# Firestore rules tests

Unit tests for `../firestore.rules`, run against the Firestore emulator.
No Firebase project is touched — the emulator is local and needs only Java.

```bash
cd firestore-tests
npm install     # once
npm test
```

`npm test` starts the emulator, runs both suites and shuts it down.

- `rules.test.mjs` — the intended behaviour: who may read and write what.
- `abuse.test.mjs` — adversarial probes. These exist because the join path
  needs a narrow exception for a user who is not yet a member, and that
  exception is easy to widen by accident.

Deploy only once these pass:

```bash
npx firebase-tools deploy --only firestore:rules
```
