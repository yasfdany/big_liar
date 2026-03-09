import 'package:big_brother/entities/hero/hero_entity.dart';
import 'package:big_brother/entities/object/flag/flag.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

/// Behavior that listens for a collision with [HeroEntity] and triggers
/// the flag raise animation, then transitions to the idle waving state.
class FlagTouchBehavior extends CollisionBehavior<HeroEntity, FlagEntity> {
  bool _triggered = false;

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    HeroEntity other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (_triggered) {
      return;
    }
    _triggered = true;
    parent.raise();
  }
}
