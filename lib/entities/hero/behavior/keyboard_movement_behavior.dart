import 'package:big_brother/entities/hero/hero.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/services.dart';

class KeyboardMovementBehavior extends Behavior<HeroEntity>
    with KeyboardHandler, HasGameReference {
  KeyboardMovementBehavior({
    this.speed = 200,
    this.jumpForce = 300,
    this.gravity = 1000,
    this.acceleration = 10,
  });

  final double speed;
  final double jumpForce;
  final double gravity;
  final double acceleration;

  double _targetMovement = 0;
  double _currentMovement = 0;
  bool _isJumping = false;
  bool _hasDoubleJumped = false;

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      _targetMovement = -1;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      _targetMovement = 1;
    } else {
      _targetMovement = 0;
    }

    if (keysPressed.contains(LogicalKeyboardKey.space)) {
      if (parent.isOnGround) {
        _isJumping = true;
      } else if (!_hasDoubleJumped) {
        _isJumping = true;
        _hasDoubleJumped = true;
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    _currentMovement +=
        (_targetMovement - _currentMovement) * acceleration * dt;

    if (_currentMovement.abs() < 0.01) {
      _currentMovement = 0;
    }

    if (parent.isOnGround) {
      _hasDoubleJumped = false;
    }

    if (!parent.isOnGround) {
      if (parent.verticalVelocity < 0) {
        if (_hasDoubleJumped) {
          parent.state = HeroState.doubleJump;
        } else {
          parent.state = HeroState.jump;
        }
      } else {
        parent.state = HeroState.fall;
      }
    } else {
      if (_currentMovement != 0) {
        parent.state = HeroState.run;
      } else {
        parent.state = HeroState.idle;
      }
    }

    parent.isOnGround = false;
    parent.position.x += _currentMovement * speed * dt;
    parent.previousY = parent.position.y;

    if (_isJumping) {
      parent.verticalVelocity = -jumpForce;
      _isJumping = false;
    }

    parent.verticalVelocity += gravity * dt;
    parent.position.y += parent.verticalVelocity * dt;

    final groundLevel = game.size.y - 50;
    if (parent.position.y + parent.size.y * (1 - parent.anchor.y) >=
        groundLevel) {
      parent.position.y = groundLevel - parent.size.y * (1 - parent.anchor.y);
      parent.verticalVelocity = 0;
      parent.isOnGround = true;
      _hasDoubleJumped = false;
    }

    if (_targetMovement > 0 && parent.isFlippedHorizontally) {
      parent.flipHorizontally();
    } else if (_targetMovement < 0 && !parent.isFlippedHorizontally) {
      parent.flipHorizontally();
    }
  }
}
