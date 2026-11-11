import 'package:flutter_test/flutter_test.dart';

import 'package:chores/data/user_repository.dart';

void main() {
  group('UserRepository.parseWgId', () {
    test('the int sentinel means no WG', () {
      // What the auth flows write for a user who has not picked a WG.
      expect(UserRepository.parseWgId(-1), isNull);
      expect(UserRepository.parseWgId(UserRepository.noWgSentinel), isNull);
    });

    test('the string sentinel written by older builds means no WG', () {
      expect(UserRepository.parseWgId('-1'), isNull);
    });

    test('missing or empty means no WG', () {
      expect(UserRepository.parseWgId(null), isNull);
      expect(UserRepository.parseWgId(''), isNull);
    });

    test('a document id is returned as-is', () {
      expect(UserRepository.parseWgId('AbC123xyz'), 'AbC123xyz');
    });
  });
}
