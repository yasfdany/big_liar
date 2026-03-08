import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/widgets.dart';

class BackgroundEntity extends Entity {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final parallaxComponent = await ParallaxComponent.load(
      [ParallaxImageData('bg/gray.png')],
      baseVelocity: Vector2(0, -20),
      size: Vector2(560, 320),
      repeat: ImageRepeat.repeat,
      filterQuality: FilterQuality.low,
      fill: LayerFill.none,
      anchor: Anchor.center,
    );

    await add(parallaxComponent);
  }
}
