import 'package:flutter/material.dart';

class ToBeContinuedOverlay extends StatelessWidget {
  const ToBeContinuedOverlay({super.key});

  static const Color backgroundColor = Color(0xff0f172a);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Text(
          'To Be Continued',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'lana_pixel',
            fontSize: 42,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
