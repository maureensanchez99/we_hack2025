import 'package:flutter/material.dart';
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

  Widget buildDaisy(double size) {
    return Container(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Stem
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 0.05,
              height: size * 0.25,
              color: Color(0xFF90B564),
            ),
          ),
          // Left leaf
          Positioned(
            bottom: size * 0.07,
            left: size * 0.4,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: size * 0.2,
                height: size * 0.24,
                decoration: BoxDecoration(
                  color: Color(0xFF90B564),
                  borderRadius: BorderRadius.circular(size * 0.08),
                  border: Border.all(
                    color: Color(0xFF75934F),
                    width: size * 0.015,
                  ),
                ),
              ),
            ),
          ),
          // Right leaf
          Positioned(
            bottom: size * 0.07,
            right: size * 0.4,
            child: Transform.rotate(
              angle: 0.3,
              child: Container(
                width: size * 0.2,
                height: size * 0.24,
                decoration: BoxDecoration(
                  color: Color(0xFF90B564),
                  borderRadius: BorderRadius.circular(size * 0.08),
                  border: Border.all(
                    color: Color(0xFF75934F),
                    width: size * 0.015,
                  ),
                ),
              ),
            ),
          ),
          // Petals
          ...List.generate(6, (index) {
            return Transform.rotate(
              angle: index * (3.14159 / 3), // 6 petals evenly spaced
              child: Container(
                width: size * 0.8,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size * 0.12),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: size * 0.015,
                  ),
                ),
              ),
            );
          }),
          // Center
          Container(
            width: size * 0.4,
            height: size * 0.4,
            decoration: BoxDecoration(
              color: Color(0xFFF4AA41),
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFFE09931),
                width: size * 0.015,
              ),
            ),
          ),
        ],
      ),
    );
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
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size * 2.5,
              height: size * 2.2,
              padding: EdgeInsets.all(size * 0.15),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Color(0xFF2D5A27) : Colors.black54,
                  width: size * 0.05,
                ),
                borderRadius: BorderRadius.circular(size * 0.2),
                color: isSelected || isHovered ? Color(0xFF2D5A27) : Color(0xFFD9D9D9),
              ),
              child: label == 'Daisy'
                  ? buildDaisy(size)
                  : Center(
                      child: Text(
                        emoji,
                        style: TextStyle(fontSize: size * 1.5),
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
    final flowerSize = screenWidth * 0.15; // Adjust flower size based on screen width

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
                  fontStyle: FontStyle.italic
                ),
              ),
              const SizedBox(height: 40),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      buildFlowerOption('🌻', 'Sunflower', flowerSize),
                      buildFlowerOption('🌹', 'Rose', flowerSize),
                      buildFlowerOption('🌼', 'Daisy', flowerSize),
                    ],
                  );
                },
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