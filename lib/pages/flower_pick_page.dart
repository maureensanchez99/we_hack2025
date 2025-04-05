import 'package:flutter/material.dart';

class FlowerPickPage extends StatefulWidget {
  @override
  _FlowerPickPageState createState() => _FlowerPickPageState();
}

class _FlowerPickPageState extends State<FlowerPickPage> {
  String selectedFlower = '';

  void selectFlower(String flower) {
    setState(() {
      selectedFlower = flower;
    });
  }

  Widget buildFlowerOption(String emoji, String label) {
    final isSelected = selectedFlower == label;
    return GestureDetector(
      onTap: () => selectFlower(label),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.brown : Colors.black54,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 40)),
            SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          width: 300,
          decoration: BoxDecoration(
            color: Color(0xFFDDF4A7), // light green
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Your\nPlant",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[900],
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildFlowerOption('🌻', 'Sunflower'),
                  buildFlowerOption('🌹', 'Rose'),
                  buildFlowerOption('🌼', 'Daisy'),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (selectedFlower.isNotEmpty) {
                    Navigator.pushNamed(context, '/viewFlower');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
