import 'package:flutter/material.dart';
import 'daily_reminder.dart';
import 'view_flower_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'messages_page.dart';

class TutorialPage extends StatefulWidget {
  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  int _selectedIndex = 2;

  final List<Widget> _pages = [
    const DailyReminder(),
    ViewFlowerPage(),
    TutorialPage(),
    MessagesPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => _pages[index]),
    );
  }

  static const Color greenBg = Color(0xFFD7EAB4);
  //static const Color brownText = Color(0xFF4F2027);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greenBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Your Plant Grows With You.',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: DailyReminder.brownText,
              ),
            ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: const Text(
                  'As you grow within, your plant grows with you.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: DailyReminder.brownText,
                  ),
                ),
              ),
            SvgPicture.asset(
              'assets/images/ls_diagram.svg',
              height: 350,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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