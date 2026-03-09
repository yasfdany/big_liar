import 'dart:async';

import 'package:big_brother/entities/ui/input_button_icon.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';

class InputButton extends PositionedEntity {
  InputButton({
    required this.icon,
    this.duration,
    super.position,
    super.anchor = Anchor.center,
  }) : super(
          size: Vector2(20, duration != null ? 20 : 16),
        );

  final InputButtonIcon icon;
  final double? duration;

  late final SpriteGroupComponent<InputButtonIcon> _spriteGroup;
  Timer? _timer;
  RectangleComponent? _progressBar;
  bool _animate = false;

  @override
  FutureOr<void> onLoad() async {
    final image = await Flame.images.load('ui/buttons.png');

    final sprites = <InputButtonIcon, Sprite>{};

    for (var i = 0; i < InputButtonIcon.values.length; i++) {
      final state = InputButtonIcon.values[i];
      final row = i ~/ 10;
      final col = i % 10;

      sprites[state] = Sprite(
        image,
        srcPosition: Vector2(col * 20.0, row * 16.0),
        srcSize: Vector2(20, 16),
      );
    }

    _spriteGroup = SpriteGroupComponent<InputButtonIcon>(
      sprites: sprites,
      current: icon,
      size: Vector2(20, 16),
    );

    add(_spriteGroup);

    if (duration != null) {
      _timer = Timer(duration!);
      _progressBar = RectangleComponent(
        position: Vector2(0, 18),
        size: Vector2(size.x, 2),
        paint: Paint()..color = Colors.white,
      );
      add(_progressBar!);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_timer != null) {
      _timer!.update(dt);
      _progressBar?.size.x = 20 * (1 - _timer!.progress);

      if ((_timer?.finished ?? false) && !_animate) {
        _animate = true;
        add(
          ScaleEffect.to(
            Vector2.zero(),
            EffectController(
              duration: 0.3,
              curve: Curves.elasticIn,
              onMax: removeFromParent,
            ),
          ),
        );
      }
    }
  }

  set currentIcon(InputButtonIcon value) {
    _spriteGroup.current = value;
  }

  void resetTimer() => _timer?.reset();
}
