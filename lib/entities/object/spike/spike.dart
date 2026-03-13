import 'dart:async';
import 'dart:math' as math;

import 'package:big_brother/entities/object/spike/behavior/spike_collision_behavior.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

enum SpikeDirection {
  bottom,
  top,
  left,
  right,
}

class Spike extends PositionedEntity {
  Spike({
    super.position,
    this.direction = SpikeDirection.bottom,
  }) : super(
          size: Vector2.all(16),
          behaviors: [
            PropagatingCollisionBehavior(
              _getHitboxForDirection(direction),
            ),
            SpikeCollisionBehavior(),
          ],
        );

  final SpikeDirection direction;

  static RectangleHitbox _getHitboxForDirection(SpikeDirection direction) {
    switch (direction) {
      case SpikeDirection.bottom:
        return RectangleHitbox(
          position: Vector2(0, 8),
          size: Vector2(16, 8),
        );
      case SpikeDirection.top:
        return RectangleHitbox(
          position: Vector2(0, 0),
          size: Vector2(16, 8),
        );
      case SpikeDirection.left:
        return RectangleHitbox(
          position: Vector2(0, 0),
          size: Vector2(8, 16),
        );
      case SpikeDirection.right:
        return RectangleHitbox(
          position: Vector2(8, 0),
          size: Vector2(8, 16),
        );
    }
  }

  @override
  FutureOr<void> onLoad() async {
    final spriteImage = await Flame.images.load('traps/spikes/idle.png');

    final spriteComponent = SpriteComponent(
      sprite: Sprite(spriteImage),
      size: Vector2.all(16),
      angle: _getRotationAngle(direction),
      anchor: Anchor.center,
    );

    spriteComponent.position = size / 2;

    add(spriteComponent);
  }

  double _getRotationAngle(SpikeDirection direction) {
    switch (direction) {
      case SpikeDirection.bottom:
        return 0;
      case SpikeDirection.top:
        return math.pi;
      case SpikeDirection.left:
        return -math.pi / 2;
      case SpikeDirection.right:
        return math.pi / 2;
    }
  }
}
