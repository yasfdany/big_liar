import 'package:big_brother/entities/hero/hero.dart';
import 'package:big_brother/entities/level/solid_platform.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class SolidPlatformCollisionBehavior
    extends CollisionBehavior<SolidPlatform, HeroEntity> {
  // Hitbox constants - same as defined in hero.dart (Vector2(9, 0), Vector2(14, 32))
  static const double hitboxOffsetX = 9.0;
  static const double hitboxOffsetY = 0.0;
  static const double hitboxWidth = 14.0;
  static const double hitboxHeight = 32.0;

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, SolidPlatform other) {
    super.onCollisionStart(intersectionPoints, other);

    // Simple: just stop all movement when hitting solid platform
    parent.horizontalVelocity = 0;
    parent.verticalVelocity = 0;
  }

  // Check if there's a solid platform blocking movement
  bool wouldHitSolidPlatform(double newX, double newY) {
    final level = parent.parent;
    if (level == null) return false;

    final solidPlatforms = level.children.whereType<SolidPlatform>();

    // Calculate hero hitbox bounds at new position
    final heroLeft = newX + hitboxOffsetX;
    final heroRight = newX + hitboxOffsetX + hitboxWidth;
    final heroTop = newY + hitboxOffsetY;
    final heroBottom = newY + hitboxOffsetY + hitboxHeight;

    for (final platform in solidPlatforms) {
      final platformLeft = platform.position.x;
      final platformRight = platform.position.x + platform.size.x;
      final platformTop = platform.position.y;
      final platformBottom = platform.position.y + platform.size.y;

      // Check if hero hitbox would overlap with this platform
      if (heroRight > platformLeft &&
          heroLeft < platformRight &&
          heroBottom > platformTop &&
          heroTop < platformBottom) {
        return true;
      }
    }
    return false;
  }
}
