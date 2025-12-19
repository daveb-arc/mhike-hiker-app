import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:mhike/constants/routes.dart';
import 'package:mhike/pages/add_hike_page.dart';
import 'package:mhike/pages/auth/login_page.dart';
import 'package:mhike/pages/auth/signup_page.dart';
import 'package:mhike/pages/hike_detail/hike_detail_page.dart';
import 'package:mhike/pages/home/home_page.dart';
import 'package:mhike/pages/search_page.dart';
import 'package:mhike/services/auth/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show a visible screen instead of blank-white if Flutter throws.
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  // Catch async errors too (common on web).
  runZonedGuarded(() {
    runApp(const MyApp());
  }, (error, stack) {
    debugPrint('🔥 Unhandled zone error: $error');
    debugPrint('$stack');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M Hike',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const _Bootstrapper(),
      routes: {
        loginRoute: (context) => const LoginPage(),
        signupRoute: (context) => const SignupPage(),
        homeRoute: (context) => const HomePage(),
        searchRoute: (context) => const SearchPage(),
        addHikeRoute: (context) => const AddHikePage(),
        hikeDetailRoute: (context) => const HikeDetailPage(),
      },
    );
  }
}

class _Bootstrapper extends StatefulWidget {
  const _Bootstrapper();

  @override
  State<_Bootstrapper> createState() => _BootstrapperState();
}

class _BootstrapperState extends State<_Bootstrapper> {
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();

    _initFuture = () async {
      // 1) Initialize Firebase/Auth
      await AuthService.firebase().initialize();

      // 2) Configure Firestore (don’t allow this to crash startup)
      if (kIsWeb) {
        try {
          FirebaseFirestore.instance.settings = const Settings(
            persistenceEnabled: true,
          );
        } catch (e) {
          debugPrint('Firestore settings warning: $e');
        }
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Startup error:\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = AuthService.firebase().currentUser;
        return user == null ? const LoginPage() : const HomePage();
      },
    );
  }
}
