import 'package:big_brother/game/big_brother_game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BigBrotherApp());
}

class BigBrotherApp extends StatelessWidget {
  const BigBrotherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Big Brother',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'lana_pixel',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const BigBrotherScreen(),
    );
  }
}
