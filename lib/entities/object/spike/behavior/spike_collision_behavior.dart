import 'package:big_brother/entities/hero/behavior/random_input_behavior.dart';
import 'package:big_brother/entities/hero/hero_entity.dart';
import 'package:big_brother/entities/object/spike/spike.dart';
import 'package:big_brother/game/big_brother_game.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/geometry.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';

class SpikeCollisionBehavior extends CollisionBehavior<HeroEntity, Spike> {
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    HeroEntity other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other.state == HeroState.hit) {
      return;
    }

    fall(other);

    other.state = HeroState.hit;

    other.horizontalVelocity = 0;
    other.verticalVelocity = 0;

    final randomInputBehavior = other.findBehavior<RandomInputBehavior>();
    randomInputBehavior.clearAllPrompts();

    final game = parent.findGame() as BigBrotherGame?;
    if (game != null) {
      final restartTimer = TimerComponent(
        period: 1.0,
        onTick: game.restartCurrentLevel,
        removeOnFinish: true,
      );
      game.add(restartTimer);
    }
  }

  void fall(HeroEntity player) {
    const jumpHeight = 50.0;
    const jumpDuration = 0.3;
    const fallDuration = 1.0;

    final jumpUp = MoveByEffect(
      Vector2(0, -jumpHeight),
      EffectController(
        duration: jumpDuration,
        curve: Curves.easeOut,
      ),
    );

    final fallDown = MoveByEffect(
      Vector2(0, jumpHeight * 10),
      EffectController(
        duration: fallDuration,
        curve: Curves.easeIn,
      ),
    );

    player.add(
      SequenceEffect([
        jumpUp,
        fallDown,
      ]),
    );
    player.add(
      RotateEffect.by(
        tau / (player.isFlippedHorizontally ? 8 : -8),
        EffectController(
          duration: 0.5,
          curve: Curves.easeIn,
        ),
      ),
    );
  }
}
