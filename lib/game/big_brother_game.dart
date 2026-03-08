import 'dart:ui';

import 'package:big_brother/entities/background/background_entity.dart';
import 'package:big_brother/entities/level/level_entity.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class BigBrotherGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  final Paint _backgroundColor = Paint()..color = const Color(0xff211f30);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.zoom = 1.5;

    await world.add(BackgroundEntity());
    await world.add(LevelEntity());
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      _backgroundColor,
    );
    super.render(canvas);
  }
}
