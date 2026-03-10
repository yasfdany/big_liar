import 'dart:async';

import 'package:big_brother/game/game_state.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';

/// HUD showing how many fruits have been collected.
///
/// Lives inside the level entity (world space) but uses a fixed-position
/// offset from the camera so it always appears anchored to the top-left of the
/// visible screen.
class FruitCounterHud extends PositionedEntity with HasGameReference {
  static const double _iconSize = 16;
  static const Color _textColor = Color(0xFFe8e4ff);

  late TextComponent _countLabel;

  void Function()? _fruitListener;

  @override
  FutureOr<void> onLoad() async {
    position = Vector2(_iconSize / 2, -_iconSize);
    // ── Fruit icon ──────────────────────────────────────────────────────────
    final iconCoin = await Flame.images.load('ui/icon_coin.png');
    final appleSprite = Sprite(
      iconCoin,
    );

    add(
      SpriteComponent(
        sprite: appleSprite,
        size: Vector2.all(_iconSize),
      ),
    );

    // ── Count label ─────────────────────────────────────────────────────────
    _countLabel = TextComponent(
      text: '× ${GameState.instance.fruitsCollected}',
      position: Vector2(_iconSize + 4, 2),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 12,
          color: _textColor,
          fontFamily: 'lana_pixel',
          shadows: [
            Shadow(
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    );
    add(_countLabel);

    // ── Subscribe to GameState ───────────────────────────────────────────────
    _fruitListener = _onFruitChanged;
    GameState.instance.addFruitListener(_fruitListener!);
  }

  @override
  void onRemove() {
    if (_fruitListener != null) {
      GameState.instance.removeFruitListener(_fruitListener!);
    }
    super.onRemove();
  }

  void _onFruitChanged() {
    _countLabel.text = '× ${GameState.instance.fruitsCollected}';
    _popAnimation();
  }

  void _popAnimation() {
    add(
      MoveEffect.by(
        Vector2(0, -2),
        EffectController(
          duration: 0.08,
          alternate: true,
        ),
      ),
    );
  }
}
