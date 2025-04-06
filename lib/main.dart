import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';
import 'pages/connection_setup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mindful Reminders',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD7EAB4)),
        useMaterial3: true,
        fontFamily: 'Inter', // Set global font family to Inter
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Inter'),
          bodyMedium: TextStyle(fontFamily: 'Inter'),
          bodySmall: TextStyle(fontFamily: 'Inter'),
          headlineLarge: TextStyle(fontFamily: 'Inter'),
          headlineMedium: TextStyle(fontFamily: 'Inter'),
          headlineSmall: TextStyle(fontFamily: 'Inter'),
        ),
      ),
      //home: const WelcomeScreen(),
      home: ConnectionSetupPage(),
    );
  }
}