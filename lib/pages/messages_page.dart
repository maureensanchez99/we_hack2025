import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'daily_reminder.dart';
import 'view_flower_page.dart';
import 'tutorial_page.dart';

class MessagesPage extends StatefulWidget {
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 3; // Default index for "Message Maker"
  Map<DateTime, String> unseenMessages = {
    DateTime(2025, 4, 6, 12, 0): "Unseen Message 2",
  };
  Map<DateTime, String> futureEntries = {};
  late SharedPreferences prefs;
  bool isInboxExpanded = false;
  final TextEditingController messageController = TextEditingController();
  DateTime? selectedDateTime;
  final ValueNotifier<bool> dataChangedNotifier = ValueNotifier(false);

  final List<Widget> _pages = [
    const DailyReminder(),
    ViewFlowerPage(),
    TutorialPage(),
    MessagesPage(),
  ];

  @override
  void initState() {
    super.initState();
    initializePreferences();
  }

  Future<void> initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    await loadUnseenMessages();
  }

  Future<void> loadUnseenMessages() async {
    String? unseenMessagesJson = prefs.getString("unseenMessages");
    if (unseenMessagesJson != null) {
      Map<String, dynamic> decodedMap = jsonDecode(unseenMessagesJson);
      setState(() {
        unseenMessages = decodedMap.map((key, value) => MapEntry(DateTime.parse(key), value as String));
      });
    }
  }

  void saveUnseenMessages() {
    prefs.setString(
      "unseenMessages",
      jsonEncode(unseenMessages.map((key, value) => MapEntry(key.toIso8601String(), value))),
    );
  }

  void submitMessage() {
    if (messageController.text.isNotEmpty && selectedDateTime != null) {
      setState(() {
        if (selectedDateTime!.isAfter(DateTime.now())) {
          futureEntries[selectedDateTime!] = messageController.text;
        } else {
          unseenMessages[selectedDateTime!] = messageController.text;
        }
        saveUnseenMessages();
        messageController.clear();
        selectedDateTime = null;
      });
    }
  }

  Future<void> pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
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
    return ValueListenableBuilder(
      valueListenable: dataChangedNotifier,
      builder: (context, _, __) {
        return Scaffold(
          backgroundColor: const Color(0xFF4F2027),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title Section
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                  child: Text(
                    "Bloom Box",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD7EAB4),
                    ),
                  ),
                ),
                // Inbox Section
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isInboxExpanded = !isInboxExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      isInboxExpanded ? "Inbox (Tap to Collapse)" : "Inbox (Tap to Expand)",
                      style: const TextStyle(
                        color: Color(0xFF4F2027),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (isInboxExpanded)
                  ...unseenMessages.entries.map((entry) {
                    return ListTile(
                      title: Text(entry.value, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(entry.key.toString(), style: const TextStyle(color: Colors.grey)),
                    );
                  }).toList(),
                const SizedBox(height: 16.0),
                // Message Input Section
                TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: "Enter your message",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: pickDateTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF9ADA0),
                  ),
                  child: Text(
                    selectedDateTime == null
                        ? "Pick a Date and Time"
                        : "Selected: ${selectedDateTime.toString()}",
                    style: const TextStyle(color: Color(0xFF4F2027)),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: submitMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF9ADA0),
                  ),
                  child: const Text(
                    "Submit Message",
                    style: TextStyle(color: Color(0xFF4F2027)),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: const Color(0xFFD7EAB4),
            selectedItemColor: const Color(0xFFF9ADA0),
            unselectedItemColor: const Color(0xFF4F2027),
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
      },
    );
  }
}