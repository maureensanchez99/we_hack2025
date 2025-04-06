import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'daily_reminder.dart';
import 'tutorial_page.dart';
import 'messages_page.dart';
import 'flower_pick_page.dart';

class ViewFlowerPage extends StatefulWidget {
  @override
  _ViewFlowerPageState createState() => _ViewFlowerPageState();
}

class _ViewFlowerPageState extends State<ViewFlowerPage> {
  String plantName = '';
  int completedTasks = 0; // Number of completed tasks
  int daysPassed = 0; // Number of days passed
  String selectedFlower = 'Sunflower'; // Default flower
  int _selectedIndex = 1; // Default index for "View Flower"

  final List<Widget> _pages = [
    const DailyReminder(),
    ViewFlowerPage(),
    TutorialPage(),
    MessagesPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadPlantData();
  }

  // Load the saved plant data from SharedPreferences
  Future<void> _loadPlantData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      plantName = prefs.getString('plantName') ?? 'Your Plant';
      completedTasks = prefs.getInt('completedTasks') ?? 0;
      daysPassed = prefs.getInt('daysPassed') ?? 0;
      selectedFlower = prefs.getString('selectedFlower') ?? 'Sunflower';
    });
  }

  // Determine the stage of the plant and return the corresponding SVG file
  String _getPlantStageSvg() {
    if (daysPassed >= 7 && completedTasks >= 20) {
      return 'assets/images/$selectedFlower/full_grown.svg'; // Fully grown
    } else if (daysPassed >= 5 && completedTasks >= 15) {
      return 'assets/images/$selectedFlower/youngling.svg'; // Almost there
    } else if (daysPassed >= 3 && completedTasks >= 7) {
      return 'assets/images/$selectedFlower/seedling.svg'; // Taking root
    } else {
      return 'assets/images/pot.svg'; // Default pot
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => _pages[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DailyReminder.greenBg, // Set green background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              plantName,
              style: const TextStyle(
                fontSize: 32, // Adjusted font size to match the reference
                fontWeight: FontWeight.bold, // Adjusted font weight
                color: DailyReminder.brownText, // Set brown text color
              ),
            ),
            const SizedBox(height: 60), // Adjusted spacing between plant name and SVG
            // SVG Display
            SvgPicture.asset(
              _getPlantStageSvg(), // Display the appropriate SVG
              height: 200, // Adjusted SVG size to match the reference
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: DailyReminder.greenBg, // Set green background
        selectedItemColor: const Color(0xFFF9ADA0),
        unselectedItemColor: DailyReminder.brownText, // Set brown text color
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'Daily Reminder',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_vintage),
            label: 'View Flower',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Tutorial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.draw),
            label: 'Message Maker',
          ),
        ],
      ),
    );
  }
}