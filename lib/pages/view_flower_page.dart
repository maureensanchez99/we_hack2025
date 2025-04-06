import 'package:flutter/material.dart';

class ViewFlowerPage extends StatefulWidget {
  @override
  _ViewFlowerPageState createState() => _ViewFlowerPageState();
}

class _ViewFlowerPageState extends State<ViewFlowerPage> {
  String selectedFlower = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(
            "View Flower Page!"
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}