import 'dart:async';
import 'dart:ui' show Rect;

import 'package:big_brother/entities/hero/behavior/keyboard_movement_behavior.dart';
import 'package:big_brother/entities/hero/behavior/one_way_platform_collision_behavior.dart';
import 'package:big_brother/entities/hero/behavior/particle_effect_behavior.dart';
import 'package:big_brother/entities/hero/behavior/random_input_behavior.dart';
import 'package:big_brother/entities/hero/behavior/solid_platform_collision_behavior.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

enum HeroState { idle, run, jump, fall, doubleJump, hit, wallJump, dash }

class HeroEntity extends PositionedEntity {
  HeroEntity({
    super.position,
  }) : super(
          size: Vector2.all(32),
          behaviors: [
            PropagatingCollisionBehavior(
              RectangleHitbox(
                position: Vector2(9, 0),
                size: Vector2(14, 32),
              ),
            ),
            OneWayPlatformCollisionBehavior(),
            SolidPlatformCollisionBehavior(),
            KeyboardMovementBehavior(),
            ParticleEffectBehavior(),
            RandomInputBehavior(),
          ],
        );

  double verticalVelocity = 0;
  double horizontalVelocity = 0;
  bool isOnGround = false;
  double previousY = 0;
  double previousX = 0;

  /// Set by the parent level after the hero is added.
  /// Used by movement behavior to clamp the player within map bounds.
  Rect? mapBounds;

  late final SpriteAnimationGroupComponent<HeroState> _animationComponent;

  HeroState get state => _animationComponent.current ?? HeroState.idle;
  set state(HeroState value) => _animationComponent.current = value;

  /// Returns the sprite being rendered on the current animation frame.
  /// Used by ParticleEffectBehavior to clone the hero ghost for the dash trail.
  Sprite? get currentSprite => _animationComponent.animationTicker?.getSprite();

  @override
  bool get isFlippedHorizontally => _animationComponent.isFlippedHorizontally;
  @override
  void flipHorizontally() => _animationComponent.flipHorizontally();

  @override
  FutureOr<void> onLoad() async {
    final idleSpriteSheet = await Flame.images.load('hero/idle.png');
    final runSpriteSheet = await Flame.images.load('hero/run.png');
    final jumpSpriteSheet = await Flame.images.load('hero/jump.png');
    final fallSpriteSheet = await Flame.images.load('hero/fall.png');
    final hitSpriteSheet = await Flame.images.load('hero/hit.png');
    final doubleJumpSpriteSheet =
        await Flame.images.load('hero/double_jump.png');
    final wallJumpSpriteSheet = await Flame.images.load('hero/wall_jump.png');

    final animations = {
      HeroState.idle: SpriteAnimation.fromFrameData(
        idleSpriteSheet,
        SpriteAnimationData.sequenced(
          amount: 11,
          stepTime: 0.05,
          textureSize: Vector2.all(32),
        ),
      ),
      HeroState.run: SpriteAnimation.fromFrameData(
        runSpriteSheet,
        SpriteAnimationData.sequenced(
          amount: 12,
          stepTime: 0.05,
          textureSize: Vector2.all(32),
        ),
      ),
      HeroState.dash: SpriteAnimation.fromFrameData(
        runSpriteSheet,
        SpriteAnimationData.sequenced(
          amount: 12,
          stepTime: 0.025,
          textureSize: Vector2.all(32),
        ),
      ),
      HeroState.jump: SpriteAnimation.fromFrameData(
        jumpSpriteSheet,
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 0.05,
          textureSize: Vector2.all(32),
        ),
      ),
      HeroState.fall: SpriteAnimation.fromFrameData(
        fallSpriteSheet,
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 0.05,
          textureSize: Vector2.all(32),
        ),
      ),
      HeroState.hit: SpriteAnimation.fromFrameData(
        hitSpriteSheet,
        SpriteAnimationData.sequenced(
          amount: 7,
          stepTime: 0.05,
          textureSize: Vector2.all(32),
          loop: false,
        ),
      ),
      HeroState.doubleJump: SpriteAnimation.fromFrameData(
        doubleJumpSpriteSheet,
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.05,
          textureSize: Vector2.all(32),
        ),
      ),
      HeroState.wallJump: SpriteAnimation.fromFrameData(
        wallJumpSpriteSheet,
        SpriteAnimationData.sequenced(
          amount: 5,
          stepTime: 0.05,
          textureSize: Vector2.all(32),
        ),
      ),
    };

    _animationComponent = SpriteAnimationGroupComponent<HeroState>(
      animations: animations,
      current: HeroState.idle,
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 0),
      size: size,
    );

    add(_animationComponent);
  }
}
