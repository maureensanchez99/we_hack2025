import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'daily_reminder.dart';
import 'tutorial_page.dart';
import 'messages_page.dart';
import 'flower_pick_page.dart';
import 'bluetooth.dart';

class ViewFlowerPage extends StatefulWidget {
  @override
  _ViewFlowerPageState createState() => _ViewFlowerPageState();
}

class _ViewFlowerPageState extends State<ViewFlowerPage> {
  String plantName = '';
  int completedTasks = 0; // Number of completed tasks
  String selectedFlower = 'Sunflower'; // Default flower
  int _selectedIndex = 1; // Default index for "View Flower"

  void sendWater() async {
    final messenger = BluetoothMessenger();

    // Send a single-character message (e.g., 'c' for water)
    await messenger.sendMessage("c");
  }

  void sendSun() async {
    final messenger = BluetoothMessenger();

    // Send a single-character message (e.g., 'y' for sunlight)
    await messenger.sendMessage("y");
  }

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
      selectedFlower = prefs.getString('selectedFlower') ?? 'Sunflower';
    });
  }

  // Determine the stage of the plant and return the corresponding SVG file
  String _getPlantStageSvg() {
    if (completedTasks >= 20) {
      return 'assets/images/$selectedFlower/full_grown.svg'; // Fully grown
    } else if (completedTasks >= 15) {
      return 'assets/images/$selectedFlower/youngling.svg'; // Almost there
    } else if (completedTasks >= 7) {
      return 'assets/images/$selectedFlower/seedling.svg'; // Taking root
    } else {
      return 'assets/images/pot.svg'; // Default pot
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DailyReminder.greenBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              plantName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: DailyReminder.brownText,
              ),
            ),
            const SizedBox(height: 60),
            SvgPicture.asset(
              _getPlantStageSvg(),
              height: 200,
            ),
            const SizedBox(height: 20),
            Text(
              'Tasks Completed: $completedTasks',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: DailyReminder.brownText,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => [
              const DailyReminder(),
              ViewFlowerPage(),
              TutorialPage(),
              MessagesPage(),
            ][index]),
          );
        },
        backgroundColor: DailyReminder.greenBg,
        selectedItemColor: const Color(0xFFF9ADA0),
        unselectedItemColor: DailyReminder.brownText,
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