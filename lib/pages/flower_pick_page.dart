import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view_flower_page.dart';

class FlowerPickPage extends StatefulWidget {
  @override
  _FlowerPickPageState createState() => _FlowerPickPageState();
}

class _FlowerPickPageState extends State<FlowerPickPage> {
  String selectedFlower = '';
  String hoveredFlower = '';

  static const Color greenBg = Color(0xFFD7EAB4);
  static const Color brownText = Color(0xFF4F2027);

  @override
  void initState() {
    super.initState();
    _loadSelectedFlower();
  }

  // Load the saved flower selection from SharedPreferences
  Future<void> _loadSelectedFlower() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedFlower = prefs.getString('selectedFlower') ?? '';
    });
  }

  // Save the flower selection to SharedPreferences
  Future<void> _saveSelectedFlower(String flower) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedFlower', flower);
  }

  Widget buildFlowerOption(String emoji, String label, double size) {
    final isSelected = selectedFlower == label;
    final isHovered = hoveredFlower == label;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredFlower = label),
      onExit: (_) => setState(() => hoveredFlower = ''),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFlower = label;
          });
          _saveSelectedFlower(label); // Save the selected flower
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size * 2.2,
              height: size * 2.0,
              padding: EdgeInsets.all(size * 0.1),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? const Color(0xFF2D5A27) : Colors.black54,
                  width: size * 0.05,
                ),
                borderRadius: BorderRadius.circular(size * 0.2),
                color: isSelected || isHovered ? const Color(0xFF2D5A27) : const Color(0xFFD9D9D9),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: size * 1.4),
                ),
              ),
            ),
            SizedBox(height: size * 0.2),
            Text(
              label,
              style: TextStyle(
                fontSize: size * 0.5,
                fontWeight: FontWeight.w500,
                color: isSelected || isHovered ? Colors.white : brownText,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final flowerSize = screenWidth * 0.12; // Dynamically adjust flower size based on screen width

    return Scaffold(
      backgroundColor: greenBg,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Text(
                "Select Your\nPlant",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28, // Matches the title font size in welcome_page.dart
                  fontWeight: FontWeight.bold,
                  color: brownText,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Choose a flower to represent your plant!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18, // Matches the subtitle font size in welcome_page.dart
                  fontWeight: FontWeight.w300,
                  color: brownText,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildFlowerOption('🌻', 'Sunflower', flowerSize),
                  buildFlowerOption('🌹', 'Rose', flowerSize),
                  buildFlowerOption('🌼', 'Daisy', flowerSize),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: selectedFlower.isEmpty
                    ? null
                    : () {
                        // Navigate to ViewFlowerPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ViewFlowerPage()),
                        );
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
      ),
    );
  }
}