import 'dart:math';
import 'dart:ui';

import 'package:big_brother/entities/hero/behavior/keyboard_movement_behavior.dart';
import 'package:big_brother/entities/hero/hero.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class ParticleEffectBehavior extends Behavior<HeroEntity> {
  late final movementBehavior = parent.findBehavior<KeyboardMovementBehavior>();

  double _dustTimer = 0;
  static const double _dustInterval = 0.1;

  double _dashTrailTimer = 0;
  static const double _dashTrailInterval = 0.04;

  static final _rng = Random();

  Vector2 get _feetLocal =>
      parent.position + Vector2(parent.size.x / 2, parent.size.y);

  void _spawnInLevel(Component component) {
    parent.parent?.add(component);
  }

  void _spawnDustPuff() {
    final origin = _feetLocal;

    _spawnInLevel(
      ParticleSystemComponent(
        position: origin,
        particle: Particle.generate(
          count: 4,
          lifespan: 0.45,
          applyLifespanToChildren: false,
          generator: (i) {
            final angle = pi + (_rng.nextDouble() - 0.5) * pi * 0.55;
            final speed = 18 + _rng.nextDouble() * 28;
            final radius = 2.0 + _rng.nextDouble() * 2.5;
            final lifespan = 0.25 + _rng.nextDouble() * 0.2;
            final baseColor = Color.lerp(
              const Color(0xFFB89060),
              const Color(0xFFD4BE88),
              _rng.nextDouble(),
            )!;

            return AcceleratedParticle(
              lifespan: lifespan,
              acceleration: Vector2(0, -15),
              speed: Vector2(cos(angle), sin(angle)) * speed,
              child: ComputedParticle(
                lifespan: lifespan,
                renderer: (canvas, particle) {
                  final t = 1.0 - particle.progress;
                  final scale = 1.0 - particle.progress * 0.7;
                  final paint = Paint()
                    ..color = baseColor.withOpacity((t * 0.75).clamp(0, 1));
                  canvas.save();
                  canvas.scale(scale);
                  canvas.drawCircle(Offset.zero, radius, paint);
                  canvas.restore();
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _spawnSpriteGhost() {
    final sprite = parent.currentSprite;
    if (sprite == null) return;

    final origin = parent.position.clone();
    final isFlipped = parent.isFlippedHorizontally;
    final size = parent.size.clone();

    // Slight colour tint: icy blue to violet
    final tintColor = Color.lerp(
      const Color(0xFF00DDFF),
      const Color(0xFF8844EE),
      _rng.nextDouble(),
    )!;

    _spawnInLevel(
      ParticleSystemComponent(
        position: origin,
        particle: ComputedParticle(
          lifespan: 0.18,
          renderer: (canvas, particle) {
            final alpha = (1.0 - particle.progress).clamp(0.0, 1.0);
            canvas.save();
            if (isFlipped) {
              // Mirror horizontally around the center of the sprite
              canvas.translate(size.x, 0);
              canvas.scale(-1, 1);
            }
            sprite.render(
              canvas,
              position: Vector2.zero(),
              size: size,
              overridePaint: Paint()
                ..colorFilter = ColorFilter.mode(
                  tintColor.withValues(alpha: alpha * 0.65),
                  BlendMode.srcATop,
                )
                ..color =
                    const Color(0xFFFFFFFF).withValues(alpha: alpha * 0.5),
            );
            canvas.restore();
          },
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    final state = parent.state;

    if (state == HeroState.dash) {
      _dashTrailTimer += dt;
      if (_dashTrailTimer >= _dashTrailInterval) {
        _dashTrailTimer = 0;
        _spawnSpriteGhost();
      }
    }

    if (state == HeroState.run) {
      _dustTimer += dt;
      if (_dustTimer >= _dustInterval) {
        _dustTimer = 0;
        if (movementBehavior.currentMovement.abs() > 0.05) {
          _spawnDustPuff();
        }
      }
    } else {
      _dustTimer = 0;
    }
  }
}
