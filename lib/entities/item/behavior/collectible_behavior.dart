import 'package:big_brother/entities/hero/hero_entity.dart';
import 'package:big_brother/entities/item/collected_all_effect.dart';
import 'package:big_brother/game/game_state.dart';
import 'package:big_brother/game/sfx_manager.dart';
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

    final gameState = GameState.instance;
    double collectRate;

    if (gameState.totalItems <= 1) {
      collectRate = 1.0;
    } else {
      final progress = gameState.itemCollected / (gameState.totalItems - 1);
      collectRate = 0.85 + (progress * 0.3); // 0.85 to 1.15 range
    }

    // Clamp to safe range to prevent distorted audio
    collectRate = collectRate.clamp(0.75, 2.0);

    SfxManager.instance.playCollect(rate: collectRate);

    GameState.instance.collectFruit();

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
