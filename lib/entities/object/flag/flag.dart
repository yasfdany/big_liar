import 'dart:async';

import 'package:big_brother/entities/object/flag/behavior/flag_touch_behavior.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

enum FlagState { pole, raise, idle }

/// A finish-line flag entity.
///
/// States:
/// - [FlagState.pole]  → static pole, shown before the hero arrives.
/// - [FlagState.raise] → one-shot raise animation, plays on hero touch.
/// - [FlagState.idle]  → looping wave animation shown after raising.
class FlagEntity extends PositionedEntity {
  FlagEntity({super.position})
      : super(
          size: Vector2.all(64),
          anchor: Anchor.center,
          behaviors: [
            PropagatingCollisionBehavior(
              RectangleHitbox(),
            ),
            FlagTouchBehavior(),
          ],
        );

  late final SpriteAnimationGroupComponent<FlagState> _animationComponent;

  FlagState get state => _animationComponent.current ?? FlagState.pole;

  /// Triggers the raise animation and automatically switches to idle once done.
  void raise() {
    _animationComponent.current = FlagState.raise;

    // SpriteAnimation.onComplete fires after the last frame of a non-looping
    // animation, giving us the perfect hook to move to idle.
    _animationComponent.animationTicker?.onComplete = () {
      _animationComponent.current = FlagState.idle;
    };
  }

  @override
  FutureOr<void> onLoad() async {
    final poleSheet = await Flame.images.load('objects/flag_pole.png');
    final raiseSheet = await Flame.images.load('objects/flag_raise.png');
    final idleSheet = await Flame.images.load('objects/flag_idle.png');

    final animations = {
      // Static single-frame pole — looping doesn't matter for 1 frame.
      FlagState.pole: SpriteAnimation.fromFrameData(
        poleSheet,
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 1,
          textureSize: Vector2.all(64),
          loop: false,
        ),
      ),

      // One-shot raise sequence: 26 frames across a 1664 × 64 sheet.
      FlagState.raise: SpriteAnimation.fromFrameData(
        raiseSheet,
        SpriteAnimationData.sequenced(
          amount: 26,
          stepTime: 0.05,
          textureSize: Vector2.all(64),
          loop: false,
        ),
      ),

      // Looping idle wave: 10 frames across a 640 × 64 sheet.
      FlagState.idle: SpriteAnimation.fromFrameData(
        idleSheet,
        SpriteAnimationData.sequenced(
          amount: 10,
          stepTime: 0.05,
          textureSize: Vector2.all(64),
        ),
      ),
    };

    _animationComponent = SpriteAnimationGroupComponent<FlagState>(
      animations: animations,
      current: FlagState.pole,
      size: size,
    );

    add(_animationComponent);
  }
}
