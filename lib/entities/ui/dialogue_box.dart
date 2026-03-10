import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

/// Phrases shown when the player is late to press a button prompt.
const List<String> _dialoguePhrases = [
  "Hey… my button didn't do anything.",
  "Are you sure I'm playing?",
  'Why is nothing happening when I press?',
  "You didn't use my move…",
  'Maybe my controller is broken?',
  'Did you see me press it?',
];

/// A bottom-of-screen HUD panel that shows a character avatar alongside
/// typewriter-effect complaint text when the player is late to press a prompt.
///
/// Add instances to `game.camera.viewport` so they render in screen-space
/// regardless of world camera position/zoom.
class DialogueBox extends PositionComponent with HasGameReference, HasPaint {
  DialogueBox({required this.phrase, super.anchor = Anchor.center});

  final String phrase;

  static const double _panelHeight = 56.0;
  static const double _panelPadding = 24.0;
  static const double _avatarSize = 56.0;
  static const double _charInterval = 0.04; // seconds per character
  static const double _holdDuration = 2.5; // seconds after text is complete
  static const double _fadeDuration = 0.35;

  static const Color _textColor = Color(0xFFe8e4ff);

  // ---- typewriter state ----
  int _visibleChars = 0;
  double _charTimer = 0;
  bool _textComplete = false;
  double _holdTimer = 0;

  late TextComponent _label;

  @override
  FutureOr<void> onLoad() async {
    final screenW = game.size.x;

    size = Vector2(560, _panelHeight + _panelPadding * 2);
    position = Vector2(game.size.x / 2, game.size.y - size.y);
    opacity = 0;

    // ── Nine-tile box frame ────────────────────────────────────────────────
    final frameSheet = await Flame.images.load('ui/dialogue_nine_box.png');
    final frameSprite = Sprite(frameSheet);
    add(
      NineTileBoxComponent(
        nineTileBox: NineTileBox(frameSprite, tileSize: 16),
        size: size,
      ),
    );

    // ── Avatar ─────────────────────────────────────────────────────────────
    try {
      final idleSheet = await Flame.images.load('hero/idle.png');
      final avatarSprite = Sprite(
        idleSheet,
        srcPosition: Vector2.zero(),
        srcSize: Vector2.all(32),
      );
      add(
        SpriteComponent(
          sprite: avatarSprite,
          size: Vector2.all(_avatarSize),
          position: Vector2(_panelPadding, _panelPadding),
        ),
      );
    } on Exception catch (_) {
      // Avatar is optional — continue without it if image fails to load.
    }

    // Avatar decorative border ring
    add(
      RectangleComponent(
        size: Vector2.all(_avatarSize + 4),
        position: Vector2(
          _panelPadding + _avatarSize / 2,
          _panelPadding + _avatarSize / 2,
        ),
        anchor: Anchor.center,
        paint: Paint()
          ..color = const Color(0xFF4e4b7a)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      ),
    );

    // ── Text label ─────────────────────────────────────────────────────────
    const textX = _panelPadding + _avatarSize + (_panelPadding / 2);
    final availableW = screenW - textX - _panelPadding;

    _label = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 18,
          color: _textColor,
          fontFamily: 'lana_pixel',
        ),
      ),
      position: Vector2(textX, _panelPadding + 4),
      size: Vector2(availableW, _panelHeight),
    );
    add(_label);

    // ── Slide-up + fade-in ─────────────────────────────────────────────────
    add(
      OpacityEffect.to(
        1,
        EffectController(duration: 0.25, curve: Curves.easeOut),
      ),
    );
    add(
      MoveEffect.by(
        Vector2(0, -6),
        EffectController(duration: 0.25, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_textComplete) {
      _charTimer += dt;
      final charsToReveal = (_charTimer / _charInterval).floor();
      if (charsToReveal > 0) {
        _charTimer -= charsToReveal * _charInterval;
        _visibleChars = (_visibleChars + charsToReveal).clamp(0, phrase.length);
        _label.text = phrase.substring(0, _visibleChars);

        if (_visibleChars >= phrase.length) {
          _textComplete = true;
        }
      }
    } else {
      _holdTimer += dt;
      if (_holdTimer >= _holdDuration) {
        _dismiss();
      }
    }
  }

  void _dismiss() {
    if (!isMounted) {
      return;
    }
    _holdTimer = -9999; // sentinel so this won't fire again

    add(
      OpacityEffect.to(
        0,
        EffectController(
          duration: _fadeDuration,
          curve: Curves.easeIn,
          onMax: removeFromParent,
        ),
      ),
    );
    add(
      MoveEffect.by(
        Vector2(0, 6),
        EffectController(duration: _fadeDuration, curve: Curves.easeIn),
      ),
    );
  }

  // ── Static helpers ────────────────────────────────────────────────────────

  static final Random _random = Random();

  /// Shows a [DialogueBox] with a random complaint phrase on [viewport].
  /// Removes any existing [DialogueBox] instances first.
  static void showRandom(Component viewport) {
    for (final old in viewport.children.whereType<DialogueBox>().toList()) {
      old.removeFromParent();
    }

    final phrase = _dialoguePhrases[_random.nextInt(_dialoguePhrases.length)];
    viewport.add(DialogueBox(phrase: phrase));
  }
}
