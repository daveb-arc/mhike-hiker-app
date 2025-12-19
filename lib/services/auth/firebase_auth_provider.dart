import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:mhike/firebase/firebase_env.dart';
import 'package:mhike/services/auth/auth_exceptions.dart';
import 'package:mhike/services/auth/auth_provider.dart';
import 'package:mhike/services/auth/auth_user.dart';

class FirebaseAuthProvider implements AuthProvider {
  @override
  AuthUser? get currentUser {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return AuthUser.fromFirebase(user);
  }

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: kIsWeb ? FirebaseEnv.web() : null,
    );
  }

  @override
  Future<AuthUser?> createUser({
    required String email,
    required String password,
  }) async {
    try {
      final credential =
          await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw UserNotLoggedInException();
      }

      return AuthUser.fromFirebase(user);
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        // NOTE: your auth_exceptions.dart class is spelled "WeekPasswordException"
        throw WeekPasswordException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<AuthUser?> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential =
          await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw UserNotLoggedInException();
      }

      return AuthUser.fromFirebase(user);
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
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
