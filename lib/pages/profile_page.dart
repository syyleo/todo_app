import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
        body: Stack(
          children: [
            // Centered Image
            Center(
              child: Image.asset(
                'assets/images.png',
                width: 150, // Adjust width and height as needed
                height: 150,
              ),
            ),
          ],
        ),
    );
  }
}
// TODO: CHANGE INTO STATEFUL WIDGETS.