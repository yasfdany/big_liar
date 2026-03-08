import 'package:big_brother/entities/hero/hero.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/services.dart';

class KeyboardMovementBehavior extends Behavior<HeroEntity>
    with KeyboardHandler, HasGameReference {
  KeyboardMovementBehavior({
    this.speed = 200,
    this.jumpForce = 400,
    this.gravity = 1000,
  });

  final double speed;
  final double jumpForce;
  final double gravity;

  double _horizontalMovement = 0;
  bool _isJumping = false;
  final double _verticalVelocity = 0;
  final bool _isOnGround = false;

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      _horizontalMovement = -1;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      _horizontalMovement = 1;
    } else {
      _horizontalMovement = 0;
    }

    if (keysPressed.contains(LogicalKeyboardKey.space) && _isOnGround) {
      _isJumping = true;
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    // Apply horizontal movement
    parent.position.x += _horizontalMovement * speed * dt;

    // Apply jumping
    // if (_isJumping) {
    //   _verticalVelocity = -jumpForce;
    //   _isOnGround = false;
    //   _isJumping = false;
    // }

    // Apply gravity
    // _verticalVelocity += gravity * dt;
    // parent.position.y += _verticalVelocity * dt;

    // Basic ground collision for testing purposes since proper platform
    // collisions might require level map integration.
    // final groundY =
    //     game.size.y - parent.size.y / 2 - 50; // Arbitrary ground level
    // if (parent.position.y >= groundY) {
    //   parent.position.y = groundY;
    //   _verticalVelocity = 0;
    //   _isOnGround = true;
    // } else {
    //   _isOnGround = false;
    // }

    // // Update animations based on state
    // if (!_isOnGround) {
    //   if (_verticalVelocity < 0) {
    //     parent.state = HeroState.jump;
    //   } else {
    //     parent.state = HeroState.fall;
    //   }
    // } else {
    if (_horizontalMovement != 0) {
      parent.state = HeroState.run;
    } else {
      parent.state = HeroState.idle;
    }
    // }

    // Flip sprite depending on horizontal movement direction
    if (_horizontalMovement > 0 && parent.isFlippedHorizontally) {
      parent.flipHorizontally();
    } else if (_horizontalMovement < 0 && !parent.isFlippedHorizontally) {
      parent.flipHorizontally();
    }
  }
}
