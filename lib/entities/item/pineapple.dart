import 'dart:async';

import 'package:big_brother/entities/item/behavior/collectible_behavior.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class Pineapple extends PositionedEntity {
  Pineapple({
    super.position,
  }) : super(
          size: Vector2.all(32),
          behaviors: [
            PropagatingCollisionBehavior(RectangleHitbox()),
            CollectibleBehavior(),
          ],
        );

  @override
  FutureOr<void> onLoad() async {
    final spriteSheet = await Flame.images.load('items/pineapple.png');
    final data = SpriteAnimationData.sequenced(
      amount: 17,
      stepTime: 0.05,
      textureSize: Vector2.all(32),
    );
    final spriteAnimation =
        SpriteAnimationComponent.fromFrameData(spriteSheet, data);
    add(spriteAnimation);
  }
}
