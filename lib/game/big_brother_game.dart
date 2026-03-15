import 'package:big_brother/entities/level/level_entity.dart';
import 'package:big_brother/entities/ui/circular_wipe_transition.dart';
import 'package:big_brother/game/game_state.dart';
import 'package:big_brother/game/sfx_manager.dart';
import 'package:big_brother/overlays/to_be_continued_overlay.dart';
import 'package:big_brother/overlays/virtual_gamepad.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class BigBrotherGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  static const double _initialRevealDelay = 0.6;
  static const double _baseZoom = 1.5;
  static const double _portraitZoomFactor = 0.5;

  final Paint _backgroundColor = Paint()..color = const Color(0xff211f30);
  late LevelEntity level;
  CircularWipeTransition? _currentTransition;
  bool _transitioning = false;
  bool _wasPortrait = false;

  double _calculateOptimalZoom() {
    final isPortrait = size.y > size.x;

    if (isPortrait) {
      return _baseZoom * _portraitZoomFactor;
    } else {
      return _baseZoom;
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    camera.viewfinder.zoom = _calculateOptimalZoom();
    _handleOrientationChange();
  }

  void _handleOrientationChange() {
    final isPortrait = size.y > size.x;

    if (isPortrait && !_wasPortrait) {
      // Switched to portrait - show virtual gamepad
      overlays.add('virtual_gamepad');
    } else if (!isPortrait && _wasPortrait) {
      // Switched to landscape - hide virtual gamepad
      overlays.remove('virtual_gamepad');
    }

    _wasPortrait = isPortrait;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    SfxManager.instance.initialize().catchError((error) {
      debugPrint(
        'Game: Audio initialization failed, continuing without sound: $error',
      );
    });

    camera.viewfinder.zoom = _calculateOptimalZoom();

    level = LevelEntity(levelName: GameState.instance.levelName);
    world.add(level);

    GameState.instance.addLevelCompleteListener(_onLevelComplete);

    _transitioning = true;
    _currentTransition = CircularWipeTransition.opening(
      onComplete: _onTransitionComplete,
      delay: _initialRevealDelay,
    );
    camera.viewport.add(_currentTransition!);

    // Check initial orientation
    _handleOrientationChange();
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
      _transitioning = false;
      overlays.remove('virtual_gamepad');
      overlays.add('to_be_continued');
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

  void restartCurrentLevel() {
    if (_transitioning) {
      return;
    }

    _transitioning = true;

    _currentTransition = CircularWipeTransition.closing(
      onComplete: _reloadCurrentLevel,
    );

    camera.viewport.add(_currentTransition!);
  }

  void _reloadCurrentLevel() {
    if (_currentTransition != null) {
      camera.viewport.remove(_currentTransition!);
      _currentTransition = null;
    }

    world.removeAll(world.children);

    GameState.instance.reset();

    final currentLevelName = GameState.instance.levelName;
    level = LevelEntity(levelName: currentLevelName);
    world.add(level);

    _currentTransition = CircularWipeTransition.opening(
      onComplete: _onTransitionComplete,
    );

    camera.viewport.add(_currentTransition!);
  }

  @override
  void dispose() {
    GameState.instance.removeLevelCompleteListener(_onLevelComplete);
    world.removeAll(world.children);

    SfxManager.instance.dispose().catchError((error) {
      debugPrint('Game: Failed to dispose audio resources: $error');
    });

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
  bool _gameStarted = false;

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
    if (!_gameStarted) {
      return _buildStartScreen();
    }
    return GameWidget(
      game: game,
      overlayBuilderMap: {
        'virtual_gamepad': (_, __) => VirtualGamepadOverlay(game: game),
        'to_be_continued': (_, __) => const ToBeContinuedOverlay(),
      },
    );
  }

  Widget _buildStartScreen() {
    return Scaffold(
      backgroundColor: const Color(0xff211f30),
      body: GestureDetector(
        onTap: _startGame,
        behavior: HitTestBehavior.opaque,
        child: const Center(
          child: Text(
            'Click to start',
            style: TextStyle(
              fontFamily: 'lana_pixel',
              fontSize: 32,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
    });
  }
}
