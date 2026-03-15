import 'dart:async';
import 'dart:ui' as ui;

import 'package:big_brother/entities/hero/hero.dart';
import 'package:big_brother/game/big_brother_game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';

class RestartButtonHud extends PositionedEntity
    with HasGameReference<BigBrotherGame>, TapCallbacks {
  RestartButtonHud({super.position});

  static const double _iconSize = 16;
  static const double _outlineWidth = 1.0;
  static const double _totalSize = _iconSize + _outlineWidth * 2;

  late SpriteComponent _sprite;

  @override
  FutureOr<void> onLoad() async {
    size = Vector2.all(_totalSize);

    final restartImage = await Flame.images.load('ui/restart.png');
    final outlinedImage = _createOutlinedImage(restartImage, _outlineWidth);

    _sprite = SpriteComponent(
      sprite: Sprite(outlinedImage),
      size: Vector2.all(_totalSize),
    );
    add(_sprite);
  }

  ui.Image _createOutlinedImage(ui.Image source, double outline) {
    final w = source.width + (outline * 2).toInt();
    final h = source.height + (outline * 2).toInt();
    final recorder = ui.PictureRecorder();
    final canvas =
        Canvas(recorder, Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()));

    final outlinePaint = Paint()
      ..colorFilter = const ColorFilter.mode(Colors.white, BlendMode.srcATop);

    // Draw white copies offset in 4 directions for the outline
    for (final offset in [
      Offset(-outline, 0),
      Offset(outline, 0),
      Offset(0, -outline),
      Offset(0, outline),
    ]) {
      canvas.drawImage(
        source,
        Offset(outline + offset.dx, outline + offset.dy),
        outlinePaint,
      );
    }

    // Draw the original sprite on top
    canvas.drawImage(source, Offset(outline, outline), Paint());

    final picture = recorder.endRecording();
    return picture.toImageSync(w, h);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _sprite.position = Vector2(0, 2);
  }

  @override
  void onTapUp(TapUpEvent event) {
    _sprite.position = Vector2.zero();
    final hero = game.world.descendants().whereType<HeroEntity>().firstOrNull;
    if (hero != null) {
      hero.die();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _sprite.position = Vector2.zero();
  }
}
