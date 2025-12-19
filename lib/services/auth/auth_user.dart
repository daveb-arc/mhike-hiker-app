import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthUser {
  final String id;
  final String email;
  final bool isEmailVerified;

  const AuthUser({
    required this.id,
    required this.email,
    required this.isEmailVerified,
  });

  factory AuthUser.fromFirebase(fb.User user) => AuthUser(
        id: user.uid,
        email: user.email ?? '',
        isEmailVerified: user.emailVerified,
      );
}
