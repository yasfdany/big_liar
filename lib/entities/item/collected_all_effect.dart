import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

/// A one-shot animation that plays the "collected all items" effect
/// at the given [position] (in LevelEntity-local space), then removes itself.
class CollectedAllEffect extends SpriteAnimationComponent {
  CollectedAllEffect({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(32),
          removeOnFinish: true,
        );

  @override
  FutureOr<void> onLoad() async {
    final sheet = await Flame.images.load('items/collected.png');
    animation = SpriteAnimation.fromFrameData(
      sheet,
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.07,
        textureSize: Vector2.all(32),
        loop: false,
      ),
    );
  }
}
