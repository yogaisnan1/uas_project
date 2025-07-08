import 'package:flutter/material.dart';
import 'main.dart';
import 'screens/loading_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/reset_password_screen.dart';

class GameChargeApp extends StatelessWidget {
  const GameChargeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GameCharge',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
      },
    );
  }
}
