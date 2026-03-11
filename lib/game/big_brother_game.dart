import 'package:big_brother/entities/level/level_entity.dart';
import 'package:big_brother/entities/ui/circular_wipe_transition.dart';
import 'package:big_brother/game/game_state.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class BigBrotherGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  static const double _initialRevealDelay = 0.6;

  final Paint _backgroundColor = Paint()..color = const Color(0xff211f30);
  late LevelEntity level;
  CircularWipeTransition? _currentTransition;
  bool _transitioning = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.zoom = 1.5;

    level = LevelEntity(levelName: GameState.instance.levelName);
    world.add(level);

    GameState.instance.addLevelCompleteListener(_onLevelComplete);

    _transitioning = true;
    _currentTransition = CircularWipeTransition.opening(
      onComplete: _onTransitionComplete,
      delay: _initialRevealDelay,
    );
    camera.viewport.add(_currentTransition!);
  }

  void _onLevelComplete() {
    if (_transitioning) {
      return;
    }

    _transitioning = true;

    _currentTransition = CircularWipeTransition.closing(
      onComplete: _loadNextLevel,
    );

    camera.viewport.add(_currentTransition!);
  }

  void _loadNextLevel() {
    if (_currentTransition != null) {
      camera.viewport.remove(_currentTransition!);
      _currentTransition = null;
    }

    world.removeAll(world.children);

    final hasNextLevel = GameState.instance.nextLevel();
    if (!hasNextLevel) {
      return;
    }

    final nextLevelName = GameState.instance.levelName;
    level = LevelEntity(levelName: nextLevelName);
    world.add(level);

    _currentTransition = CircularWipeTransition.opening(
      onComplete: _onTransitionComplete,
    );

    camera.viewport.add(_currentTransition!);
  }

  void _onTransitionComplete() {
    _transitioning = false;
    if (_currentTransition != null) {
      camera.viewport.remove(_currentTransition!);
      _currentTransition = null;
    }
  }

  @override
  void dispose() {
    GameState.instance.removeLevelCompleteListener(_onLevelComplete);
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
