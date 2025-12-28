import 'package:flutter/material.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Initialize Firebase here if you need it later
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AuthService().signInAnonymouslyIfNeeded();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      // TODO: Add authentication logic here if needed
      // For now, app starts directly at HomeScreen
      home: const HomeScreen(),
    );
  }
}
