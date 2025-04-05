import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DailyReminder extends StatelessWidget {
  const DailyReminder({super.key});

  static const Color greenBg = Color(0xFFD7EAB4);
  static const Color brownText = Color(0xFF4F2027);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greenBg,
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
                backgroundColor: brownText,
                foregroundColor: greenBg,
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
          ],
        ),
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

    String 

    Color; getColor(Set<WidgetState> states) {
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          checkColor: Colors.white,
          fillColor: MaterialStateProperty.resolveWith(getColor),
          value: isChecked,
          onChanged: (bool? value) {
            setState(() {
              isChecked = value!;
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

