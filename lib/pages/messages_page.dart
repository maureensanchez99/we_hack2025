import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'daily_reminder.dart';
import 'view_flower_page.dart';
import 'tutorial_page.dart';
import 'bluetooth.dart';

class MessagesPage extends StatefulWidget {
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 3; // Default index for "Message Maker"
  Map<DateTime, String> itemsMap = {
    DateTime(2025, 4, 5, 9, 0): "Loading Message 1...",
    DateTime(2025, 4, 5, 10, 0): "Loading Message 2...",
  };
  Map<DateTime, String> unseenMessages = {
    DateTime(2025, 4, 6, 11, 0): "Unseen Message 1",
    DateTime(2025, 4, 6, 12, 0): "Unseen Message 2",
  };
  Map<DateTime, String> futureEntries = {};
  late SharedPreferences prefs;
  bool isInboxExpanded = false;
  final TextEditingController messageController = TextEditingController();
  DateTime? selectedDateTime;
  final ValueNotifier<bool> dataChangedNotifier = ValueNotifier(false);

  void sendMessageNotif() async {
      final messenger = BluetoothMessenger();

      // Send a single-character message (e.g., 'a')
      await messenger.sendMessage("m");
    }

  @override
  void initState() {
    super.initState();
    initializePreferences();
  }

  Future<void> initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    await loadItems();
    await loadFutureEntries();
    await loadUnseenMessages();
  }

  Future<void> loadItems() async {
    String? itemsMapJson = prefs.getString("itemsMap");
    if (itemsMapJson != null) {
      Map<String, dynamic> decodedMap = jsonDecode(itemsMapJson);
      setState(() {
        itemsMap = decodedMap.map((key, value) => MapEntry(DateTime.parse(key), value as String));
      });
    }
  }

  Future<void> loadFutureEntries() async {
    String? futureEntriesJson = prefs.getString("futureEntries");
    if (futureEntriesJson != null) {
      Map<String, dynamic> decodedMap = jsonDecode(futureEntriesJson);
      setState(() {
        futureEntries = decodedMap.map((key, value) => MapEntry(DateTime.parse(key), value as String));
      });
    }
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

  void saveFutureEntries() {
    prefs.setString(
      "futureEntries",
      jsonEncode(futureEntries.map((key, value) => MapEntry(key.toIso8601String(), value))),
    );
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
          sendMessageNotif();
          futureEntries[selectedDateTime!] = messageController.text;
          saveFutureEntries();
        } else {
          unseenMessages[selectedDateTime!] = messageController.text;
          saveUnseenMessages();
        }
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
      MaterialPageRoute(builder: (_) => [
        const DailyReminder(),
        ViewFlowerPage(),
        TutorialPage(),
        MessagesPage(),
      ][index]),
    );
  }

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder(
      valueListenable: dataChangedNotifier,
      builder: (context, _, __) {
        return DefaultTabController(
          length: 3,
          initialIndex: 1, 
          child: Scaffold(
            backgroundColor: const Color(0xFF4F2027),
            body: Column(
              children: [
                // Title and TabBar Section
                Container(
                  color: const Color(0xFF4F2027),
                  padding: const EdgeInsets.only(top: 40.0, bottom: 8.0),
                  child: Column(
                    children: const [
                      Text(
                        "Bloom Box",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD7EAB4),
                        ),
                      ),
                      TabBar(
                        labelColor: Color(0xFFD7EAB4),
                        indicatorColor: Color(0xFFF9ADA0),
                        tabs: [
                          Tab(icon: Icon(Icons.mark_email_read)),
                          Tab(icon: Icon(Icons.contact_mail)),
                          Tab(icon: Icon(Icons.attach_email)),
                        ],
                      ),
                    ],
                  ),
                ),
                // TabBarView Section
                Expanded(
                  child: TabBarView(
                    children: [
                      // Inbox Tab
                      Container(
                        color: const Color(0xFF4F2027),
                        child: itemsMap.isEmpty
                            ? const Center(
                                child: Text(
                                  "No messages available",
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : ListView(
                                children: itemsMap.entries.map((entry) {
                                  return ListTile(
                                    title: Text(entry.value, style: const TextStyle(color: Colors.white)),
                                    subtitle: Text(entry.key.toString(), style: const TextStyle(color: Colors.grey)),
                                  );
                                }).toList(),
                              ),
                      ),
                      // Unseen Messages Tab
                      Container(
                        color: const Color(0xFF4F2027),
                        child: unseenMessages.isEmpty
                            ? const Center(
                                child: Text(
                                  "No unseen messages",
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : ListView(
                                children: unseenMessages.entries.map((entry) {
                                  return ListTile(
                                    title: Text(entry.value, style: const TextStyle(color: Colors.white)),
                                    subtitle: Text(entry.key.toString(), style: const TextStyle(color: Colors.grey)),
                                  );
                                }).toList(),
                              ),
                      ),
                      // Future Entries Tab
                      Container(
                        color: const Color(0xFF4F2027),
                        child: futureEntries.isEmpty
                            ? const Center(
                                child: Text(
                                  "No future entries",
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : ListView(
                                children: futureEntries.entries.map((entry) {
                                  return ListTile(
                                    title: Text(entry.value, style: const TextStyle(color: Colors.white)),
                                    subtitle: Text(entry.key.toString(), style: const TextStyle(color: Colors.grey)),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
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
          ),
        );
      },
    );
  }
}