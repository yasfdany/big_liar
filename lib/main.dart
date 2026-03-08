import 'package:big_brother/game/big_brother_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget(
      game: BigBrotherGame(),
    ),
  );
}
