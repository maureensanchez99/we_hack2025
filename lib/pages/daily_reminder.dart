import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:we_hack2025/pages/flower_pick_page.dart';
import 'package:we_hack2025/pages/messages_page.dart';
import 'package:we_hack2025/pages/tutorial_page.dart';
import 'package:we_hack2025/pages/view_flower_page.dart';

class DailyReminder extends StatefulWidget {
  const DailyReminder({super.key});

  static const Color greenBg = Color(0xFFD7EAB4);
  static const Color brownText = Color(0xFF4F2027);

  @override
  State<DailyReminder> createState() => _DailyReminderState();
}

class DailyReminderHome extends StatelessWidget {
  const DailyReminderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DailyReminder.greenBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CheckboxSet(text: 'Water Plant'),
            CheckboxSet(text: 'Send Message'),
            CheckboxSet(text: 'Clean Pot'),
            ElevatedButton(
              onPressed: () {
                // Placeholder for navigation
                // Navigator.push(context, MaterialPageRoute(builder: (_) => NextPage()));
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 11),
                backgroundColor: DailyReminder.brownText,
                foregroundColor: DailyReminder.greenBg,
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
            ElevatedButton(onPressed: () {
              Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FlowerPickPage()),
                  );
            }, child: Text("Annika's Page"))
          ],
        ),
      ),
    );
  }
}

class _DailyReminderState extends State<DailyReminder> {
  int _selectedIndex = 0;

  //!SECTION Bottom Navigation Bar
  final List<Widget> _pages = [
    const DailyReminderHome(),
    ViewFlowerPage(),
    TutorialPage(),
    MessagesPage(),
  ];

  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: DailyReminder.greenBg,
        selectedItemColor: Color(0xFFF9ADA0),
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

class CheckboxSet extends StatefulWidget {
  final String text;

  const CheckboxSet({super.key, required this.text});

  @override
  State<CheckboxSet> createState() => _CheckboxState();
}

class _CheckboxState extends State<CheckboxSet> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context){

    // person.name = 'Shilpa';
    // String newString = 'This is my name: ${person.name}';

    getColor(Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = <WidgetState> {
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
      };
      if(states.any(interactiveStates.contains)){
        // Change to fit theme
        return Colors.blue;
      }
      // Change to fit theme
      return Colors.red;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          checkColor: Colors.white,
          fillColor: WidgetStateProperty.resolveWith(getColor),
          value: isChecked,
          onChanged: (bool? value) {
            setState(() {
              isChecked = value!;
            });
          },
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

