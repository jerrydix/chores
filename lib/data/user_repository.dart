import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'providers/authentication_provider.dart';

/// Single source of truth for the `users/{uid}` document.
///
/// The `wg` field is written as [noWgSentinel] (an int) when the user is not
/// in a WG and as the WG document id (a String) otherwise, so every read has
/// to cope with both types. Parsing lives here instead of being repeated —
/// and mistyped — at each call site.
class UserRepository {
  UserRepository._();

  /// Value stored in `users/{uid}.wg` while the user belongs to no WG.
  static const int noWgSentinel = -1;

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Normalises a raw `wg` field to a WG id, or null when the user has none.
  ///
  /// Accepts the int sentinel written by the auth flows, the string form that
  /// older builds wrote, and a missing/empty field.
  static String? parseWgId(Object? raw) {
    if (raw == null) return null;
    if (raw is String) {
      if (raw.isEmpty || raw == '-1') return null;
      return raw;
    }
    return null; // ints (the -1 sentinel) mean "no WG"
  }

  /// Reads the current WG id for [uid], or null when there is none.
  static Future<String?> fetchWgId(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return parseWgId(doc.data()?['wg']);
  }

  /// Ensures `users/{uid}` exists for an OAuth sign-in and returns the WG id
  /// (null when the user still has to pick one).
  ///
  /// The create is awaited so navigation can never outrun the write.
  static Future<String?> ensureUserDoc(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (snap.exists) {
      return parseWgId(snap.data()?['wg']);
    }
    await ref.set({
      'username': AuthenticationProvider.usernameOf(user),
      'wg': noWgSentinel,
    });
    return null;
  }

  /// Points the user at [wgId].
  static Future<void> setWgId(String uid, String wgId) =>
      _db.collection('users').doc(uid).update({'wg': wgId});

  /// Clears the user's WG membership.
  static Future<void> clearWgId(String uid) =>
      _db.collection('users').doc(uid).update({'wg': noWgSentinel});
}
