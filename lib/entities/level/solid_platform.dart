import 'package:flame/collisions.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class SolidPlatform extends PositionedEntity {
  SolidPlatform({
    required super.position,
    required super.size,
  }) : super(
          behaviors: [
            PropagatingCollisionBehavior(RectangleHitbox()),
          ],
        );
}
