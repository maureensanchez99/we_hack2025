import 'package:flutter/material.dart';
import 'daily_reminder.dart';
import 'view_flower_page.dart';
import 'tutorial_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MessagesPage extends StatefulWidget {
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 3;

  final List<Widget> _pages = [
    const DailyReminder(),
    ViewFlowerPage(),
    TutorialPage(),
    MessagesPage(),
  ];

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
  void initState() {
    super.initState();
    initializePreferences();
    startPeriodicCheck();
  }

  Future<void> initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    await loadItems();
    await loadFutureEntries();
    await loadUnseenMessages();
    checkExpiredEntries();
  }

  void startPeriodicCheck() {
    Future.delayed(Duration(seconds: 5), () {
      checkExpiredEntries();
      startPeriodicCheck();
    });
  }

  Future<void> loadItems() async {
    String? itemsMapJson = prefs.getString("itemsMap");
    if (itemsMapJson == null) {
      Map<DateTime, String> defaultItems = {
        DateTime(2025, 4, 6, 10, 0): "Default Message 1",
        DateTime(2025, 4, 7, 12, 30): "Default Message 2",
      };
      setState(() {
        itemsMap = defaultItems;
      });
      prefs.setString(
        "itemsMap",
        jsonEncode(defaultItems.map((key, value) => MapEntry(key.toIso8601String(), value))),
      );
    } else {
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

  void checkExpiredEntries() {
    DateTime now = DateTime.now();
    List<DateTime> expiredKeys = [];
    futureEntries.forEach((key, value) {
      if (key.isBefore(now)) {
        expiredKeys.add(key);
        unseenMessages[key] = value;
      }
    });
    if (expiredKeys.isNotEmpty) {
      for (DateTime key in expiredKeys) {
        futureEntries.remove(key);
      }
      saveFutureEntries();
      saveUnseenMessages();
      dataChangedNotifier.value = !dataChangedNotifier.value;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Some entries have been moved to the inbox."),
          ),
        );
      }
    }
  }

  void addFutureEntry(DateTime dateTime, String message) {
    setState(() {
      futureEntries[dateTime] = message;
      saveFutureEntries();
    });
  }

  void markMessageAsSeen(DateTime key) {
    setState(() {
      String? message = unseenMessages.remove(key);
      if (message != null) {
        itemsMap[key] = message;
        saveUnseenMessages();
        prefs.setString(
          "itemsMap",
          jsonEncode(itemsMap.map((key, value) => MapEntry(key.toIso8601String(), value))),
        );
      }
    });
  }

  void submitMessage() {
    if (messageController.text.isNotEmpty && selectedDateTime != null) {
      setState(() {
        if (selectedDateTime!.isAfter(DateTime.now())) {
          futureEntries[selectedDateTime!] = messageController.text;
          saveFutureEntries();
        } else {
          itemsMap[selectedDateTime!] = messageController.text;
          prefs.setString(
            "itemsMap",
            jsonEncode(itemsMap.map((key, value) => MapEntry(key.toIso8601String(), value))),
          );
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

  void removeItem(DateTime key) {
    setState(() {
      itemsMap.remove(key);
      prefs.setString(
        "itemsMap",
        jsonEncode(itemsMap.map((key, value) => MapEntry(key.toIso8601String(), value))),
      );
    });
  }

  void resetToDummyValues() {
    Map<DateTime, String> dummyValues = {
      DateTime(2025, 4, 5, 9, 0): "Loading Message 1...",
      DateTime(2025, 4, 5, 10, 0): "Loading Message 2...",
    };
    setState(() {
      itemsMap = dummyValues;
      prefs.setString(
        "itemsMap",
        jsonEncode(dummyValues.map((key, value) => MapEntry(key.toIso8601String(), value))),
      );
    });
  }

  void showItemDialog(DateTime key, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFD7EAB4),
          title: Text("Message Details", style: TextStyle(color: const Color(0xFF4F2027))),
          content: Text(message, style: TextStyle(color: const Color(0xFF4F2027))),
          actions: [
            TextButton(
              onPressed: () {
                removeItem(key);
                Navigator.of(context).pop();
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close", style: TextStyle(color: const Color(0xFF4F2027))),
            ),
          ],
        );
      },
    );
  }

  // Remainder of build method and UI logic here...

  @override
  Widget build(BuildContext context) {
    // Return UI widgets here...
    return Scaffold(
      body: Center(child: Text("Message Maker Page!")),
    );
  }
}