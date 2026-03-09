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

  double currentMovement = 0;
  double _targetMovement = 0;
  bool _isJumping = false;
  bool _hasDoubleJumped = false;

  // Dash state
  bool _isDashing = false;
  double _dashTimer = 0;
  double _dashCooldownTimer = 0;
  static const double _dashDuration = 0.15;
  static const double _dashCooldown = 0.5;
  static const double _dashMultiplier = 3.5;

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

    if (keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      if (parent.isOnGround) {
        _isJumping = true;
      } else if (!_hasDoubleJumped) {
        _isJumping = true;
        _hasDoubleJumped = true;
      }
    }

    if (event is KeyDownEvent &&
        keysPressed.contains(LogicalKeyboardKey.space)) {
      if (_dashCooldownTimer <= 0 && !_isDashing) {
        _isDashing = true;
        _dashTimer = _dashDuration;
        _dashCooldownTimer = _dashCooldown;
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    // Tick dash timers
    if (_dashCooldownTimer > 0) _dashCooldownTimer -= dt;
    if (_isDashing) {
      _dashTimer -= dt;
      if (_dashTimer <= 0) {
        _isDashing = false;
      }
    }

    currentMovement += (_targetMovement - currentMovement) * acceleration * dt;

    if (currentMovement.abs() < 0.01) {
      currentMovement = 0;
    }

    if (parent.isOnGround) {
      _hasDoubleJumped = false;
    }

    if (_isDashing) {
      parent.state = HeroState.dash;
    } else if (!parent.isOnGround) {
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
      if (currentMovement != 0) {
        parent.state = HeroState.run;
      } else {
        parent.state = HeroState.idle;
      }
    }

    parent.isOnGround = false;
    final effectiveSpeed = _isDashing ? speed * _dashMultiplier : speed;
    parent.position.x += currentMovement * effectiveSpeed * dt;
    parent.previousY = parent.position.y;

    // Clamp player within level horizontal bounds.
    final bounds = parent.mapBounds;
    if (bounds != null) {
      final halfW = parent.size.x * parent.anchor.x;
      parent.position.x = parent.position.x.clamp(
        bounds.left + halfW,
        bounds.right - halfW,
      );
    }

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
