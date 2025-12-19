import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:mhike/firebase_options.dart';
import 'package:mhike/services/auth/auth_exceptions.dart';
import 'package:mhike/services/auth/auth_provider.dart';
import 'package:mhike/services/auth/auth_user.dart';

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  AuthUser? get currentUser {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return AuthUser.fromFirebase(user);
  }

  @override
  Future<AuthUser?> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return currentUser;
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') throw WeekPasswordException();
      if (e.code == 'email-already-in-use') throw EmailAlreadyInUseException();
      if (e.code == 'invalid-email') throw InvalidEmailException();
      throw GenericAuthException();
    }
  }

  @override
  Future<AuthUser?> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return currentUser;
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') throw UserNotFoundException();
      if (e.code == 'wrong-password') throw WrongPasswordException();
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logout() async {
    await fb.FirebaseAuth.instance.signOut();
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) throw UserNotLoggedInException();
    await user.sendEmailVerification();
  }
}
