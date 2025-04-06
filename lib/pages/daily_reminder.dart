import 'package:flutter/material.dart';
import 'package:we_hack2025/pages/messages_page.dart';
import 'package:we_hack2025/pages/tutorial_page.dart';
import 'package:we_hack2025/pages/view_flower_page.dart';
import 'bluetooth.dart';

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

    /*void sendBlinkCommand() async {
      final messenger = BluetoothMessenger();

      // Send a single-character message (e.g., 'a')
      await messenger.sendMessage("g");
    }*/

    void sendSuccess() async {
      final messenger = BluetoothMessenger();

      // Send a single-character message (e.g., 'a')
      await messenger.sendMessage("g");
    }

    void sendFail() async {
      final messenger = BluetoothMessenger();

      // Send a single-character message (e.g., 'a')
      await messenger.sendMessage("r");
    }

    return Scaffold(
      backgroundColor: DailyReminder.greenBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Text(
              'Daily Reminders:',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: DailyReminder.brownText,
              ),
            ),
            // Subtitle
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 25),
              child: Text(
                'Ensure your plant is healthy and loved!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: DailyReminder.brownText,
                ),
              ),
            ),
            // Checkboxes
            const CheckboxSet(text: 'Water Plant'),
            const CheckboxSet(text: 'Send Message'),
            const CheckboxSet(text: 'Clean Pot'),
            // Continue Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: ElevatedButton(
                onPressed: () {
                  // Placeholder for navigation
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => NextPage()));
                  CheckboxManager().saveCheckboxStates();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 11),
                  backgroundColor: DailyReminder.brownText,
                  foregroundColor: DailyReminder.greenBg,
                  elevation: 0,
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyReminderState extends State<DailyReminder> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DailyReminderHome(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const DailyReminderHome(),
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

class CheckboxSet extends StatefulWidget {
  final String text;

  const CheckboxSet({super.key, required this.text});

  @override
  State<CheckboxSet> createState() => _CheckboxState();
}

class _CheckboxState extends State<CheckboxSet> {
  bool isChecked = false;
  final CheckboxManager manager = CheckboxManager();

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = <WidgetState>{
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return const Color(0xFFF9ADA0);
      }
      return DailyReminder.brownText;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          checkColor: DailyReminder.greenBg,
          fillColor: WidgetStateProperty.resolveWith(getColor),
          value: manager.getCheckboxState("checkbox"),
          onChanged: (value) {
              setState(() {
                manager.updateCheckboxState("checkbox", value ?? false);
              });
          },
        ),
        Text(
          widget.text,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}

class CheckboxManager {
  static final CheckboxManager _instance = CheckboxManager._internal();
  factory CheckboxManager() => _instance;

  CheckboxManager._internal();

  Map<String, bool> checkboxStates = {};

  void updateCheckboxState(String key, bool value) {
    checkboxStates[key] = value;
  }

  bool getCheckboxState(String key) {
    return checkboxStates[key] ?? false; // Default to false if the key doesn't exist
  }

  void saveCheckboxStates() {
    checkboxStates.forEach((key, value) {
      print('Checkbox $key is ${value ? "checked" : "unchecked"}');
    });
  }
}
