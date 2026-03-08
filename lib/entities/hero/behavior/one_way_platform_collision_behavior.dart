import 'package:big_brother/entities/hero/hero.dart';
import 'package:big_brother/entities/level/one_way_platform.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class OneWayPlatformCollisionBehavior
    extends CollisionBehavior<OneWayPlatform, HeroEntity> {
  @override
  void onCollision(Set<Vector2> intersectionPoints, OneWayPlatform other) {
    super.onCollision(intersectionPoints, other);
    if (parent.verticalVelocity > 0) {
      final heroBottom =
          parent.position.y + parent.size.y * (1 - parent.anchor.y);
      final heroLeft = parent.position.x - parent.size.x * parent.anchor.x;
      final heroRight =
          parent.position.x + parent.size.x * (1 - parent.anchor.x);

      final previousHeroBottom =
          parent.previousY + parent.size.y * (1 - parent.anchor.y);

      final platformTop = other.position.y;
      final platformLeft = other.position.x;
      final platformRight = other.position.x + other.size.x;

      // Check horizontal overlap
      if (heroRight > platformLeft && heroLeft < platformRight) {
        // Check if previously above and now intersecting or below the platform top
        if (previousHeroBottom <= platformTop && heroBottom >= platformTop) {
          parent.position.y =
              platformTop - parent.size.y * (1 - parent.anchor.y);
          parent.verticalVelocity = 0;
          parent.isOnGround = true;
          // Note: keyboard_movement_behavior handles resetting _hasDoubleJumped
          // via `parent.isOnGround` directly in its update loop
        }
      }
    }
  }
}
