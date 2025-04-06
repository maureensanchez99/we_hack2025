import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flower_pick_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  TextEditingController _controller = TextEditingController();
  String _savedName = '';

  @override
  void initState() {
    super.initState();
    _loadPlantName();
  }

  // Load the saved plant name from shared preferences
  Future<void> _loadPlantName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedName = prefs.getString('plantName') ?? '';
    });
  }

  // Save the plant name to shared preferences
  Future<void> _savePlantName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('plantName', name);
  }

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
            SvgPicture.asset(
              'assets/images/logo.svg',
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Leafy Saga',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: brownText,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Let's provide your plant a name!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                color: brownText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 75),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  labelText: "Enter your plant's new name",
                  hintText: 'e.g. Sunny, Honey, Alex',
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  _savedName = value;
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_savedName.isNotEmpty) {
                  _savePlantName(_savedName); // Save name to shared preferences
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FlowerPickPage()), // Navigate to FlowerPickPage
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('No name entered'),
                      content: const Text('Please provide a name for your plant.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                backgroundColor: brownText,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
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
