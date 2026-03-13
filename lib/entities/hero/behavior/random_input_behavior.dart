import 'dart:math';

import 'package:big_brother/entities/hero/hero.dart';
import 'package:big_brother/entities/ui/input_button.dart';
import 'package:big_brother/entities/ui/input_button_icon.dart';
import 'package:big_brother/game/game_state.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class RandomInputBehavior extends Behavior<HeroEntity> {
  static const double _promptDuration = 3.0;
  static const double _minInterval = 2.0;
  static const double _maxInterval = 4.0;

  final _gameState = GameState.instance;

  static const List<InputButtonIcon> _promptIcons = [
    InputButtonIcon.xboxA,
    InputButtonIcon.xboxB,
  ];

  final Random _random = Random();
  double _timer = 0;
  late double _interval;

  @override
  void onLoad() {
    _interval = _nextInterval();
  }

  @override
  void update(double dt) {
    // Don't spawn input prompts if hero is hit (dead)
    if (parent.state == HeroState.hit) {
      return;
    }

    _timer += dt;

    if (_timer >= _interval) {
      _timer = 0;
      _interval = _nextInterval();
      _spawnButton();
    }
  }

  double _nextInterval() =>
      _minInterval + _random.nextDouble() * (_maxInterval - _minInterval);

  void _spawnButton() {
    // Don't spawn buttons if hero is hit
    if (parent.state == HeroState.hit) {
      return;
    }

    if (_gameState.allItemsCollected && _gameState.flagRaised) {
      return;
    }
    final icon = _promptIcons[_random.nextInt(_promptIcons.length)];

    final existing = parent.children.whereType<InputButton>();
    if (existing.any((b) => b.icon == icon)) {
      return;
    }

    final button = InputButton(
      icon: icon,
      duration: _promptDuration,
      position: Vector2(parent.size.x / 2, 0),
      anchor: Anchor.bottomCenter,
    );

    parent.add(button);
  }

  /// Removes all existing input button prompts
  void clearAllPrompts() {
    final buttons = parent.children.whereType<InputButton>().toList();
    for (final button in buttons) {
      button.removeFromParent();
    }
  }
}
