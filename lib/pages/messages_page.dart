import 'package:flutter/material.dart';

class MessagesPage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagesPage> {
  String selectedFlower = '';

  @override
  Widget build(BuildContext context) {
    return Text("Message Maker Page!");
  }
}