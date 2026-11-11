import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_repository.dart';

/// Default cap on members per WG. Stored per-WG as `maxMembers` so it can be
/// raised later without another release; WGs created before that field
/// existed fall back to this value.
const int kDefaultMaxWgMembers = 4;

enum JoinResult { joined, full, missing }

/// All multi-document WG mutations, kept in transactions.
///
/// Joining and leaving both touch the WG doc, its `members` subcollection and
/// the user doc at once. Done as loose sequential writes these interleave
/// badly: two people joining at the same moment used to be handed the same
/// member slot, and a failed step could leave `count` disagreeing with the
/// real membership.
class WgRepository {
  WgRepository._();

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static List<int> _slotsOf(Map<String, dynamic>? data) =>
      ((data?['memberIDs'] as List?) ?? const [])
          .map((e) => e is num ? e.toInt() : null)
          .whereType<int>()
          .toList();

  /// Adds [uid] to [wgID], allocating the lowest free member slot.
  ///
  /// The slot list lives on the WG doc so allocation can happen inside the
  /// transaction — a subcollection cannot be queried from one. WGs created
  /// before `memberIDs` existed are seeded from their current member docs.
  static Future<JoinResult> join({
    required String wgID,
    required String uid,
    required String username,
  }) async {
    final wgRef = _db.collection('wgs').doc(wgID);

    // Seed values for WGs predating the memberIDs field. Read outside the
    // transaction (subcollections are not readable inside one); the
    // transaction still reads the WG doc, so a concurrent join invalidates
    // and retries it.
    final existing = await wgRef.collection('members').get();
    final seedSlots = existing.docs
        .map((d) => (d.data()['memberID'] as num?)?.toInt())
        .whereType<int>()
        .where((slot) => slot >= 0)
        .toList();

    return _db.runTransaction<JoinResult>((tx) async {
      final snap = await tx.get(wgRef);
      final data = snap.data();
      if (!snap.exists || data == null) return JoinResult.missing;

      final maxMembers =
          (data['maxMembers'] as num?)?.toInt() ?? kDefaultMaxWgMembers;
      final slots = data.containsKey('memberIDs') ? _slotsOf(data) : seedSlots;

      // Re-joining a WG you are already in must not consume a second slot.
      final alreadyIn = existing.docs.any((d) => d.id == uid);
      if (!alreadyIn && slots.length >= maxMembers) return JoinResult.full;

      int slot = -1;
      for (int i = 0; i < maxMembers; i++) {
        if (!slots.contains(i)) {
          slot = i;
          break;
        }
      }
      if (slot == -1) return JoinResult.full;

      final nextSlots = alreadyIn ? slots : [...slots, slot];

      tx.set(wgRef.collection('members').doc(uid), {
        'uid': uid,
        'memberID': slot,
        'username': username,
        'active': true,
      });
      tx.update(wgRef, {
        'memberIDs': nextSlots,
        // Derive count from the slot list rather than blind-incrementing, so
        // it cannot drift away from the real membership.
        'count': nextSlots.length,
      });
      tx.update(_db.collection('users').doc(uid), {'wg': wgID});
      return JoinResult.joined;
    });
  }

  /// Removes [uid] from [wgID], deleting the WG when nobody is left.
  ///
  /// Firestore does not cascade: deleting the WG document on its own would
  /// strand its `members` subcollection, so the member docs are deleted
  /// explicitly in the same transaction.
  static Future<void> leave({
    required String wgID,
    required String uid,
  }) async {
    final wgRef = _db.collection('wgs').doc(wgID);
    final memberDocs = await wgRef.collection('members').get();

    await _db.runTransaction((tx) async {
      final snap = await tx.get(wgRef);
      final data = snap.data();
      if (!snap.exists || data == null) return;

      int? mySlot;
      for (final doc in memberDocs.docs) {
        if (doc.id == uid) {
          mySlot = (doc.data()['memberID'] as num?)?.toInt();
          break;
        }
      }

      final remainingDocs = memberDocs.docs.where((d) => d.id != uid).toList();

      if (remainingDocs.isEmpty) {
        // Last one out: remove the member docs too, then the WG itself.
        for (final doc in memberDocs.docs) {
          tx.delete(doc.reference);
        }
        tx.delete(wgRef);
      } else {
        tx.delete(wgRef.collection('members').doc(uid));
        final slots = data.containsKey('memberIDs')
            ? _slotsOf(data)
            : memberDocs.docs
                .map((d) => (d.data()['memberID'] as num?)?.toInt())
                .whereType<int>()
                .toList();
        final nextSlots = slots.where((s) => s != mySlot).toList();
        tx.update(wgRef, {
          'memberIDs': nextSlots,
          'count': nextSlots.isEmpty ? remainingDocs.length : nextSlots.length,
        });
      }
    });

    await UserRepository.clearWgId(uid);
  }
}
