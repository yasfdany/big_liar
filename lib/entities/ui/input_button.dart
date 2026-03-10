import 'dart:async';

import 'package:big_brother/entities/hero/hero.dart';
import 'package:big_brother/entities/item/collected_all_effect.dart';
import 'package:big_brother/entities/ui/dialogue_box.dart';
import 'package:big_brother/entities/ui/input_button_icon.dart';
import 'package:big_brother/game/big_brother_game.dart';
import 'package:big_brother/game/game_state.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';

class InputButton extends PositionedEntity with HasGameReference {
  InputButton({
    required this.icon,
    this.duration,
    super.position,
    super.anchor = Anchor.center,
    this.onFinish,
  }) : super(
          size: Vector2(20, duration != null ? 20 : 16),
        );

  final VoidCallback? onFinish;
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
        resetButton();
      }
    }
  }

  void resetButton({bool collect = false}) {
    onFinish?.call();
    _animate = true;

    if (!collect) {
      // Increase suspicion level.
      GameState.instance.addSuspicion();

      // Screen shake
      game.camera.viewfinder.add(
        MoveEffect.by(
          Vector2(2, 2),
          EffectController(
            duration: 0.05,
            repeatCount: 2,
            alternate: true,
          ),
        ),
      );

      // Show the character complaint dialogue
      DialogueBox.showRandom(game.camera.viewport);
    }

    add(
      ScaleEffect.to(
        Vector2.zero(),
        EffectController(
          duration: 0.3,
          curve: Curves.elasticIn,
          onMax: () {
            _collectedAnimation(collect);
            removeFromParent();
          },
        ),
      ),
    );
  }

  void _collectedAnimation(bool collect) {
    if (collect) {
      final level = (game as BigBrotherGame).level;
      final hero = level.children.whereType<HeroEntity>().firstOrNull;
      if (hero != null) {
        level.add(
          CollectedAllEffect(
            position: hero.position - Vector2(0, hero.size.y - 6),
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
