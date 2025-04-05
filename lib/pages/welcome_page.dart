import 'package:flutter/material.dart';
import 'daily_reminder.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color greenBg = Color(0xFFD7EAB4);
  static const Color brownText = Color(0xFF4F2027);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greenBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: brownText,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Let's provide your plant a name!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                color: brownText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                // Placeholder for navigation
                Navigator.push(context, MaterialPageRoute(builder: (_) => DailyReminder()));
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 11),
                backgroundColor: brownText,
                foregroundColor: greenBg,
                elevation: 0,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
