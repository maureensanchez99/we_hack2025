import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'bluetooth.dart';
class DailyReminder extends StatelessWidget {
  const DailyReminder({super.key});

  static const Color greenBg = Color(0xFFD7EAB4);
  static const Color brownText = Color(0xFF4F2027);

  @override
  Widget build(BuildContext context) {

    void sendBlinkCommand() async {
      final messenger = BluetoothMessenger();

      // Send a single-character message (e.g., 'a')
      await messenger.sendMessage("g");
    }

    return Scaffold(
      backgroundColor: greenBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Placeholder for navigation
                // Navigator.push(context, MaterialPageRoute(builder: (_) => NextPage()));
                sendBlinkCommand();
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
