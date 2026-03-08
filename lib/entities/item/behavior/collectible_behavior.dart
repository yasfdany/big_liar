import 'package:big_brother/entities/hero/hero_entity.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class CollectibleBehavior
    extends CollisionBehavior<HeroEntity, PositionedEntity> {
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    HeroEntity other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    // Remove the item from the game when collided with.
    // Later this can be scoped strictly to a Player entity.
    parent.removeFromParent();
  }
}
