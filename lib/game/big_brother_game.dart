import 'package:big_brother/entities/background/background_entity.dart';
import 'package:big_brother/entities/level/level_entity.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class BigBrotherGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  final Paint _backgroundColor = Paint()..color = const Color(0xff211f30);
  final level = LevelEntity();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.zoom = 1.5;

    world.add(BackgroundEntity());
    world.add(level);
  }

  @override
  void dispose() {
    world.removeAll(world.children);
    super.dispose();
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

class BigBrotherScreen extends StatefulWidget {
  const BigBrotherScreen({super.key});

  @override
  State<BigBrotherScreen> createState() => _BigBrotherScreenState();
}

class _BigBrotherScreenState extends State<BigBrotherScreen>
    with WidgetsBindingObserver {
  final game = BigBrotherGame();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        game.resumeEngine();
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        game.pauseEngine();
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: game);
  }
}
