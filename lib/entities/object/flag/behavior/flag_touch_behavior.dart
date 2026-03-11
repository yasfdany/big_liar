import 'package:big_brother/entities/hero/hero_entity.dart';
import 'package:big_brother/entities/object/flag/flag.dart';
import 'package:big_brother/game/game_state.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

/// Behavior that listens for a collision with [HeroEntity] and triggers
/// the flag raise animation only if all items have been collected.
class FlagTouchBehavior extends CollisionBehavior<HeroEntity, FlagEntity> {
  bool _triggered = false;
  final _gameState = GameState.instance;

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    HeroEntity other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (_triggered) {
      return;
    }

    // Only raise flag if all items have been collected
    if (_gameState.allItemsCollected) {
      _gameState.flagRaised = true;
      _triggered = true;
      parent.raise();
    }
  }
}
