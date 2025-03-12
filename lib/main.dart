import 'package:aim_test/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/local_storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final localStorage = LocalStorageService();

  runApp(
    ProviderScope(
      child: MyApp(localStorage: localStorage),
    ),
  );
}

class MyApp extends StatelessWidget {
  final LocalStorageService localStorage;
  const MyApp({super.key, required this.localStorage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF48c9cf),
      ),
      home: const SplashScreen(),
    );
  }
}
