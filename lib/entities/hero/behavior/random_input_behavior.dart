import 'dart:math';

import 'package:big_brother/entities/hero/behavior/keyboard_movement_behavior.dart'
    show KeyboardMovementBehavior;
import 'package:big_brother/entities/hero/hero.dart';
import 'package:big_brother/entities/ui/input_button.dart';
import 'package:big_brother/entities/ui/input_button_icon.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

/// Randomly prompts the player to press a control button every 5–10 seconds.
///
/// Spawns an [InputButton] above the hero's head showing either a jump
/// ([InputButtonIcon.xboxA]) or dash ([InputButtonIcon.xboxB]) prompt.
/// The button auto-dismisses after 3 seconds if the player ignores it.
/// [KeyboardMovementBehavior] handles dismissing it early when the correct
/// key is pressed.
class RandomInputBehavior extends Behavior<HeroEntity> {
  static const double _promptDuration = 1.0;
  static const double _minInterval = 2.0;
  static const double _maxInterval = 4.0;

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
    final icon = _promptIcons[_random.nextInt(_promptIcons.length)];

    // Avoid duplicates — skip if this icon is already shown.
    final existing = parent.children.whereType<InputButton>();
    if (existing.any((b) => b.icon == icon)) {
      return;
    }

    final button = InputButton(
      icon: icon,
      duration: _promptDuration,
      // Center the prompt above the hero's head with a small gap.
      position: Vector2(parent.size.x / 2, 0),
      anchor: Anchor.bottomCenter,
    );

    parent.add(button);
  }
}
