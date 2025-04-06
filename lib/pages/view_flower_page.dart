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
    _loadPlantName();
  }

  // Load the saved plant name from SharedPreferences
  Future<void> _loadPlantName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      plantName = prefs.getString('plantName') ?? 'Your Plant';
    });
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
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: DailyReminder.brownText, // Set brown text color
              ),
            ),
            const SizedBox(height: 100),
            SvgPicture.asset(
              'assets/images/pot.svg',
              height: 150,
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      "days until your plant reaches the next stage!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: DailyReminder.brownText, // Set brown text color
                      ),
                    ),
                  ],
                ),
              ),
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