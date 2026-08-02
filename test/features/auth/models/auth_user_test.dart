import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/features/auth/models/auth_user.dart';

void main() {
  group('AuthUser.fromJson', () {
    test('parses the full backend user payload (snake_case keys)', () {
      final AuthUser user = AuthUser.fromJson(<String, dynamic>{
        'id': '5cd72062-2be5-4bb5-b115-2f3e98563b76',
        'full_name': 'Showshant',
        'email': 'showshant716@gmail.com',
        'avatar_url': 'https://lh3.googleusercontent.com/abc',
        'phone_number': null,
        'is_active': true,
        'created_at': '2026-07-31T08:32:47.975Z',
        'updated_at': '2026-07-31T08:32:47.975Z',
      });

      expect(user.id, '5cd72062-2be5-4bb5-b115-2f3e98563b76');
      expect(user.displayName, 'Showshant');
      expect(user.email, 'showshant716@gmail.com');
      expect(user.avatarUrl, 'https://lh3.googleusercontent.com/abc');
      expect(user.phoneNumber, isNull);
      expect(user.isActive, isTrue);
      expect(user.createdAt, DateTime.utc(2026, 7, 31, 8, 32, 47, 975));
      expect(user.updatedAt, DateTime.utc(2026, 7, 31, 8, 32, 47, 975));
    });

    test('round-trips through toJson with the same API keys', () {
      const AuthUser user = AuthUser(
        id: 'u1',
        email: 'a@b.dev',
        displayName: 'A B',
        avatarUrl: 'https://img/x.png',
        isActive: true,
      );

      final Map<String, dynamic> json = user.toJson();

      expect(json['id'], 'u1');
      expect(json['email'], 'a@b.dev');
      expect(json['full_name'], 'A B');
      expect(json['avatar_url'], 'https://img/x.png');
      expect(json['phone_number'], isNull);
      expect(json['is_active'], isTrue);
    });
  });
}
