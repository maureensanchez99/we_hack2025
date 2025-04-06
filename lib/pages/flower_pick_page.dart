import 'package:flutter/material.dart';

class FlowerPickPage extends StatefulWidget {
  @override
  _FlowerPickPageState createState() => _FlowerPickPageState();
}

class _FlowerPickPageState extends State<FlowerPickPage> {
  String selectedFlower = '';
  String hoveredFlower = '';

  Widget buildDaisy() {
    return Container(
      height: 75,
      width: 75,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Stem
          Positioned(
            bottom: 0,
            child: Container(
              width: 4,
              height: 20,
              color: Color(0xFF90B564),
            ),
          ),
          // Left leaf
          Positioned(
            bottom: 5,
            left: 32,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 15,
                height: 18,
                decoration: BoxDecoration(
                  color: Color(0xFF90B564),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Color(0xFF75934F),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          // Right leaf
          Positioned(
            bottom: 5,
            right: 32,
            child: Transform.rotate(
              angle: 0.3,
              child: Container(
                width: 15,
                height: 18,
                decoration: BoxDecoration(
                  color: Color(0xFF90B564),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Color(0xFF75934F),
                    width: 1,
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
                width: 60,
                height: 25,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
            );
          }),
          // Center
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Color(0xFFF4AA41),
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFFE09931),
                width: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFlowerOption(String emoji, String label) {
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
        child: Container(
          width: 190,
          height: 170,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Color(0xFF2D5A27) : Colors.black54,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
            color: isSelected || isHovered ? Color(0xFF2D5A27) : Color(0xFFD9D9D9),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              label == 'Daisy' 
                  ? buildDaisy() 
                  : Text(emoji, style: TextStyle(fontSize: 55)),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: isSelected || isHovered ? Colors.white : Color(0xFF4F2027),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD7EAB4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 100),
            Text(
              "Select Your\nPlant",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F2027),
                fontFamily: 'Inter',
              ),
            ),
            SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildFlowerOption('🌻', 'Sunflower'),
                SizedBox(width: 30),
                buildFlowerOption('🌹', 'Rose'),
                SizedBox(width: 30),
                buildFlowerOption('🌼', 'Daisy'),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: selectedFlower.isEmpty 
                  ? null 
                  : () {
                      // Navigate to view flower page
                      Navigator.pushNamed(context, '/view_flower');
                    },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    return Color(0xFF4F2027); // Always return the same brown color
                  },
                ),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                elevation: MaterialStateProperty.all(0),
              ),
              child: Text(
                'Continue',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}