import 'package:firebase_core/firebase_core.dart';

class FirebaseEnv {
  static const apiKey =
      String.fromEnvironment('FIREBASE_API_KEY');
  static const appId =
      String.fromEnvironment('FIREBASE_APP_ID');
  static const messagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const projectId =
      String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const authDomain =
      String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const storageBucket =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static const measurementId =
      String.fromEnvironment('FIREBASE_MEASUREMENT_ID');

  static FirebaseOptions web() {
    assert(apiKey.isNotEmpty, 'FIREBASE_API_KEY missing');
    assert(appId.isNotEmpty, 'FIREBASE_APP_ID missing');

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: authDomain,
      storageBucket: storageBucket,
      measurementId: measurementId,
    );
  }
}
