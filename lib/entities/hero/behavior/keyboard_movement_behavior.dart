import 'package:big_brother/entities/hero/behavior/solid_platform_collision_behavior.dart';
import 'package:big_brother/entities/hero/hero.dart';
import 'package:big_brother/entities/level/solid_platform.dart';
import 'package:big_brother/entities/ui/input_button.dart';
import 'package:big_brother/entities/ui/input_button_icon.dart';
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
      if (parent.isOnGround || !_hasDoubleJumped) {
        final inputButton = parent.children.whereType<InputButton>();
        for (final button in inputButton) {
          if (button.icon == InputButtonIcon.xboxA) {
            button.resetButton(collect: true);
          }
        }
      }

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
        final inputButton = parent.children.whereType<InputButton>();
        for (final button in inputButton) {
          if (button.icon == InputButtonIcon.xboxB) {
            button.resetButton(collect: true);
          }
        }

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
    if (_dashCooldownTimer > 0) {
      _dashCooldownTimer -= dt;
    }
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

    // Store previous positions for collision detection
    parent.previousX = parent.position.x;
    parent.previousY = parent.position.y;

    // Set horizontal velocity for collision detection
    parent.horizontalVelocity = currentMovement * effectiveSpeed;

    // Calculate new horizontal position
    final newX = parent.position.x + currentMovement * effectiveSpeed * dt;

    // Only move horizontally if it won't hit a solid platform
    final collisionBehavior =
        parent.findBehavior<SolidPlatformCollisionBehavior>();
    if (!collisionBehavior.wouldHitSolidPlatform(newX, parent.position.y)) {
      parent.position.x = newX;
    } else {
      parent.horizontalVelocity = 0;
    }

    if (_isJumping) {
      parent.verticalVelocity = -jumpForce;
      _isJumping = false;
    }

    parent.verticalVelocity += gravity * dt;

    // Calculate new vertical position
    final newY = parent.position.y + parent.verticalVelocity * dt;

    // Only move vertically if it won't hit a solid platform
    if (collisionBehavior.wouldHitSolidPlatform(parent.position.x, newY) !=
        true) {
      parent.position.y = newY;
    } else {
      if (parent.verticalVelocity > 0) {
        // Falling - find the closest platform we're actually hitting from above
        final level = parent.parent;
        final solidPlatforms =
            level?.children.whereType<SolidPlatform>() ?? <SolidPlatform>[];

        const hitboxOffsetX = SolidPlatformCollisionBehavior.hitboxOffsetX;
        const hitboxWidth = SolidPlatformCollisionBehavior.hitboxWidth;
        const hitboxHeight = SolidPlatformCollisionBehavior.hitboxHeight;

        SolidPlatform? closestPlatform;
        var closestDistance = double.infinity;

        for (final platform in solidPlatforms) {
          final heroLeft = parent.position.x + hitboxOffsetX;
          final heroRight = parent.position.x + hitboxOffsetX + hitboxWidth;
          final heroBottom = parent.position.y + hitboxHeight;

          // Check if horizontally aligned and hero is above this platform
          if (heroRight > platform.position.x &&
              heroLeft < platform.position.x + platform.size.x &&
              heroBottom <= platform.position.y + 2) {
            // Small tolerance

            final distance = platform.position.y - heroBottom;
            if (distance >= 0 && distance < closestDistance) {
              closestDistance = distance;
              closestPlatform = platform;
            }
          }
        }

        if (closestPlatform != null) {
          parent.position.y = closestPlatform.position.y - parent.size.y;
          parent.isOnGround = true;
        }
      }
      parent.verticalVelocity = 0;
    }

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

    // Clamp player within level bounds (final enforcement after all movement logic).
    final bounds = parent.mapBounds;
    if (bounds != null) {
      final halfW = parent.size.x * parent.anchor.x;
      final halfH = parent.size.y * parent.anchor.y;

      parent.position.x = parent.position.x.clamp(
        bounds.left + halfW,
        bounds.right - halfW,
      );

      parent.position.y = parent.position.y.clamp(
        bounds.top + halfH,
        bounds.bottom - halfH,
      );

      // If player is at the bottom boundary, they should be considered on ground
      if ((parent.position.y - (bounds.bottom - halfH)).abs() < 0.1) {
        parent.isOnGround = true;
        parent.verticalVelocity = 0;
        _hasDoubleJumped = false;
      }
    }
  }
}
