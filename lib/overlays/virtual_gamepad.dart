import 'package:big_brother/entities/hero/behavior/keyboard_movement_behavior.dart';
import 'package:big_brother/entities/hero/hero.dart';
import 'package:big_brother/game/big_brother_game.dart';
import 'package:flutter/material.dart';

class VirtualGamepadOverlay extends StatefulWidget {
  const VirtualGamepadOverlay({
    required this.game,
    super.key,
  });

  final BigBrotherGame game;

  @override
  State<VirtualGamepadOverlay> createState() => _VirtualGamepadOverlayState();
}

class _VirtualGamepadOverlayState extends State<VirtualGamepadOverlay> {
  String _dpadDirection = '';

  bool _aButtonPressed = false;
  bool _bButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned(
            left: 32,
            top: (widget.game.size.y / 2) * 1.4,
            child: _buildDPad(),
          ),
          Positioned(
            right: 32,
            top: ((widget.game.size.y / 2) * 1.4) + 18,
            child: _buildActionButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildDPad() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(75),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 55,
            child: _buildDPadButton(
              'up',
              Icons.keyboard_arrow_up,
            ),
          ),
          Positioned(
            bottom: 10,
            left: 55,
            child: _buildDPadButton(
              'down',
              Icons.keyboard_arrow_down,
            ),
          ),
          Positioned(
            left: 10,
            top: 55,
            child: _buildDPadButton(
              'left',
              Icons.keyboard_arrow_left,
            ),
          ),
          Positioned(
            right: 10,
            top: 55,
            child: _buildDPadButton(
              'right',
              Icons.keyboard_arrow_right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDPadButton(String direction, IconData icon) {
    final isPressed = _dpadDirection == direction;

    return GestureDetector(
      onTapDown: (_) => _handleDPadPress(direction),
      onTapUp: (_) => _handleDPadRelease(),
      onTapCancel: _handleDPadRelease,
      onPanStart: (_) => _handleDPadPress(direction),
      onPanEnd: (_) => _handleDPadRelease(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isPressed
              ? Colors.white.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.6),
          ),
          boxShadow: isPressed
              ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isPressed ? Colors.black87 : Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: 160,
      height: 120,
      child: Stack(
        children: [
          Positioned(
            right: 20,
            bottom: 30,
            child: _buildActionButton(
              'A',
              _aButtonPressed,
              () => _handleActionPress('a'),
              () => _handleActionRelease('a'),
              Colors.green,
            ),
          ),
          Positioned(
            right: 90,
            bottom: 10,
            child: _buildActionButton(
              'B',
              _bButtonPressed,
              () => _handleActionPress('b'),
              () => _handleActionRelease('b'),
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    bool isPressed,
    VoidCallback onPress,
    VoidCallback onRelease,
    Color color,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        onPress();
      },
      onTapUp: (_) {
        onRelease();
      },
      onTapCancel: () {
        onRelease();
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isPressed
              ? color.withValues(alpha: 1.0)
              : color.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              offset: Offset(0, isPressed ? 1 : 4),
              blurRadius: isPressed ? 3 : 10,
            ),
            if (isPressed)
              BoxShadow(
                color: color.withValues(alpha: 0.8),
                blurRadius: 18,
              ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'lana_pixel',
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleDPadPress(String direction) {
    if (_dpadDirection != direction) {
      setState(() {
        _dpadDirection = direction;
      });
      _updateMovement();
    }
  }

  void _handleDPadRelease() {
    if (_dpadDirection.isNotEmpty) {
      setState(() {
        _dpadDirection = '';
      });
      _updateMovement();
    }
  }

  void _updateMovement() {
    final hero = _getHero();
    if (hero != null) {
      final movementBehavior =
          hero.children.whereType<KeyboardMovementBehavior>().firstOrNull;
      if (movementBehavior != null) {
        var direction = 0.0;
        if (_dpadDirection == 'left') {
          direction = -1.0;
        } else if (_dpadDirection == 'right') {
          direction = 1.0;
        }
        movementBehavior.setMovementDirection(direction);
      }
    }
  }

  void _handleActionPress(String button) {
    setState(() {
      if (button == 'a') {
        _aButtonPressed = true;
      } else if (button == 'b') {
        _bButtonPressed = true;
      }
    });

    final hero = _getHero();
    if (hero != null) {
      final movementBehavior =
          hero.children.whereType<KeyboardMovementBehavior>().firstOrNull;
      if (movementBehavior != null) {
        if (button == 'a') {
          movementBehavior.triggerJump();
        } else if (button == 'b') {
          movementBehavior.triggerDash();
        }
      }
    }
  }

  void _handleActionRelease(String button) {
    setState(() {
      if (button == 'a') {
        _aButtonPressed = false;
      } else if (button == 'b') {
        _bButtonPressed = false;
      }
    });
  }

  HeroEntity? _getHero() {
    final level = widget.game.level;
    return level.children.whereType<HeroEntity>().firstOrNull;
  }
}
