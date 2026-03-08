import 'package:flame/collisions.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class OneWayPlatform extends PositionedEntity {
  OneWayPlatform({
    required super.position,
    required super.size,
  }) : super(
          behaviors: [
            PropagatingCollisionBehavior(RectangleHitbox()),
          ],
        );
}
