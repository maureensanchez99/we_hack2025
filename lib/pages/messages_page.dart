import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'bluetooth.dart';

class MessagesPage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagesPage> with SingleTickerProviderStateMixin {
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

  void sendNotif() async {
      final messenger = BluetoothMessenger();

      // Send a single-character message (e.g., 'a')
      await messenger.sendMessage("m");
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
        sendNotif();
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
          sendNotif();
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

  void showFutureEntryDialog(DateTime key, String message) {
    TextEditingController updateController = TextEditingController(text: message);
    DateTime? updatedDateTime = key;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFD7EAB4),
          title: Text("Future Entry Options", style: TextStyle(color: const Color(0xFF4F2027))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: updateController,
                decoration: InputDecoration(
                  hintText: "Update your message",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: updatedDateTime ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(updatedDateTime ?? DateTime.now()),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        updatedDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(),
                child: Text(
                  updatedDateTime == null
                      ? "Pick a Date and Time"
                      : "Selected: ${updatedDateTime.toString()}",
                  style: TextStyle(color: Color(0xFF4F2027)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  if (updatedDateTime != null) {
                    futureEntries.remove(key);
                    futureEntries[updatedDateTime!] = updateController.text;
                    saveFutureEntries();
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text("Update", style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  futureEntries.remove(key);
                  saveFutureEntries();
                });
                Navigator.of(context).pop();
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel", style: TextStyle(color: const Color(0xFF4F2027))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: dataChangedNotifier,
      builder: (context, _, __) {
        return DefaultTabController(
          length: 3,
          initialIndex: 0,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFFD7EAB4),
              title: const Text(
                'Bloom Box',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F2027),
                ),
              ),
              bottom: TabBar(
                labelColor: const Color(0xFF4F2027),
                tabs: const [
                  Tab(icon: Icon(Icons.mark_email_read)),
                  Tab(icon: Icon(Icons.contact_mail)),
                  Tab(icon: Icon(Icons.attach_email)),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                Container(
                  decoration: BoxDecoration(color: Color(0xFF4F5D2F)),
                  child: itemsMap.isEmpty
                      ? Center(child: Text("No messages available", style: TextStyle(color: Colors.white)))
                      : ListView(
                          children: itemsMap.entries.toList().reversed.map((entry) {
                            return ListTile(
                              title: Text(entry.value, style: TextStyle(color: Colors.white)),
                              subtitle: Text(entry.key.toString(), style: TextStyle(color: Colors.grey)),
                              onTap: () => showItemDialog(entry.key, entry.value),
                            );
                          }).toList(),
                        ),
                ),
                Container(
                  decoration: BoxDecoration(color: Color(0xFF4F2027)),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isInboxExpanded = !isInboxExpanded;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              isInboxExpanded ? "Inbox (Tap to Collapse)" : "Inbox (Tap to Expand)",
                              style: TextStyle(color: Color(0xFF4F2027), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (isInboxExpanded)
                          ...unseenMessages.entries.map((entry) {
                            return ListTile(
                              title: Text(entry.value, style: TextStyle(color: Colors.white)),
                              subtitle: Text(entry.key.toString(), style: TextStyle(color: Colors.grey)),
                              onTap: () => markMessageAsSeen(entry.key),
                            );
                          }).toList(),
                        SizedBox(height: 16.0),
                        TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: "Enter your message",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: pickDateTime,
                          style: ElevatedButton.styleFrom(),
                          child: Text(
                            selectedDateTime == null
                                ? "Pick a Date and Time"
                                : "Selected: ${selectedDateTime.toString()}",
                            style: TextStyle(color: Color(0xFF4F2027)),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: submitMessage,
                          style: ElevatedButton.styleFrom(),
                          child: Text("Submit Message", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(color: Color(0xFF4F2027)),
                  child: futureEntries.isEmpty
                      ? Center(child: Text("No future entries available", style: TextStyle(color: Colors.white)))
                      : ListView(
                          children: futureEntries.entries.toList().map((entry) {
                            return ListTile(
                              title: Text(entry.value, style: TextStyle(color: Colors.white)),
                              subtitle: Text(entry.key.toString(), style: TextStyle(color: Colors.grey)),
                              onTap: () => showFutureEntryDialog(entry.key, entry.value),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
