import 'package:big_brother/entities/hero/hero_entity.dart';
import 'package:big_brother/entities/item/collected_all_effect.dart';
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

    // Spawn the collected animation at the item's position before removing it.
    final level = parent.parent;
    if (level != null) {
      level.add(
        CollectedAllEffect(
          position: parent.position,
        ),
      );
    }

    parent.removeFromParent();
  }
}
