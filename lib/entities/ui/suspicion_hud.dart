import 'dart:async';

import 'package:big_brother/game/game_state.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';

/// HUD showing the current suspicion level as a colour-coded fill bar.
///
/// Lives inside the level entity world space but tracks the camera viewport
/// so it stays pinned to the top-right of the visible screen.
class SuspicionHud extends PositionedEntity with HasGameReference {
  SuspicionHud({
    super.position,
    this.barWidth = 80.0,
    this.barHeight = 6.0,
  });
  final double barWidth;
  final double barHeight;
  static const Color _textColor = Color(0xFFe8e4ff);

  late RectangleComponent _fillBar;
  late TextComponent _label;

  void Function()? _suspicionListener;

  @override
  FutureOr<void> onLoad() async {
    // ── Label ────────────────────────────────────────────────────────────────
    _label = TextComponent(
      text: 'SUSPICION',
      anchor: Anchor.topRight,
      position: Vector2(barWidth, 0),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 10,
          color: _textColor,
          fontFamily: 'lana_pixel',
          shadows: [
            Shadow(
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    );
    add(_label);

    // ── Background bar ───────────────────────────────────────────────────────
    add(
      RectangleComponent(
        position: Vector2(0, 14),
        size: Vector2(barWidth, barHeight),
        paint: Paint()..color = const Color(0xFF2a2840),
      ),
    );

    // ── Fill bar ─────────────────────────────────────────────────────────────
    _fillBar = RectangleComponent(
      position: Vector2(0, 14),
      size: Vector2(0, barHeight),
      paint: Paint()..color = _suspicionColor(0),
    );
    add(_fillBar);

    // ── Subscribe to GameState ────────────────────────────────────────────────
    _suspicionListener = _onSuspicionChanged;
    GameState.instance.addSuspicionListener(_suspicionListener!);

    // Init display.
    _onSuspicionChanged();
  }

  @override
  void onRemove() {
    if (_suspicionListener != null) {
      GameState.instance.removeSuspicionListener(_suspicionListener!);
    }
    super.onRemove();
  }

  void _onSuspicionChanged() {
    _popAnimation();
    final level = GameState.instance.suspicion;
    final targetWidth = (barWidth * level / 100).clamp(0.0, barWidth);
    final color = _suspicionColor(level);

    // Kill existing size effects.
    _fillBar.children.whereType<SizeEffect>().toList().forEach(
          (e) => e.removeFromParent(),
        );

    _fillBar.add(
      SizeEffect.to(
        Vector2(targetWidth, barHeight),
        EffectController(duration: 0.2, curve: Curves.easeOut),
      ),
    );
    _fillBar.paint.color = color;

    // Pulse at high suspicion.
    if (level >= 80) {
      _fillBar.children.whereType<ColorEffect>().toList().forEach(
            (e) => e.removeFromParent(),
          );
      _fillBar.add(
        ColorEffect(
          const Color(0xFFFF1A1A),
          EffectController(
            duration: 0.15,
            alternate: true,
            repeatCount: 1,
          ),
        ),
      );
    }
  }

  static Color _suspicionColor(double level) {
    if (level < 50) {
      // green → yellow
      return Color.lerp(
        const Color(0xFF4cca6a),
        const Color(0xFFf5c542),
        level / 50,
      )!;
    } else {
      // yellow → red
      return Color.lerp(
        const Color(0xFFf5c542),
        const Color(0xFFe63a3a),
        (level - 50) / 50,
      )!;
    }
  }

  void _popAnimation() {
    add(
      MoveEffect.by(
        Vector2(0, -2),
        EffectController(
          duration: 0.08,
          alternate: true,
        ),
      ),
    );
  }
}
