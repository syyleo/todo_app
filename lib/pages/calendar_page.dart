import 'package:flutter/material.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Stack(
        children: [
          // Centered Image
          Center(
            child: Image.asset(
              'assets/calendar_image.png',
              width: 150,
              height: 150,
            ),
          ),
        ],
      ),
    );
  }
}
// TODO: CHANGE INTO STATEFUL WIDGETS.