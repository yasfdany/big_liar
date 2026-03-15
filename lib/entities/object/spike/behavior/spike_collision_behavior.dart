import 'package:big_brother/entities/hero/hero_entity.dart';
import 'package:big_brother/entities/object/spike/spike.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

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

    // Play death sounds simultaneously
    other.die();
  }
}
