import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// A circular wipe transition effect that expands a circle from the center
/// to reveal or conceal content underneath.
class CircularWipeTransition extends Component {
  CircularWipeTransition({
    required this.onComplete,
    this.duration = 1.0,
    this.delay = 0.0,
    this.color = const Color(0xFF211F30),
    this.expanding = false,
  });

  final VoidCallback onComplete;
  final double duration;
  final double delay;
  final Color color;
  final bool expanding; // true for revealing, false for concealing

  double _progress = 0.0;
  double _remainingDelay = 0.0;
  late double _maxRadius;
  bool _completed = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Calculate the maximum radius needed to cover the entire game screen
    final gameSize = findGame()?.size ?? Vector2.zero();
    _maxRadius = sqrt(gameSize.x * gameSize.x + gameSize.y * gameSize.y) / 2;

    // Revealing starts closed and grows the visible circle.
    // Concealing starts open and shrinks the visible circle.
    _progress = expanding ? 0.0 : 1.0;
    _remainingDelay = delay;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_completed) return;

    if (_remainingDelay > 0.0) {
      _remainingDelay = (_remainingDelay - dt).clamp(0.0, delay);
      return;
    }

    final deltaProgress = dt / duration;

    if (expanding) {
      // Opening: hole grows from nothing to full screen.
      _progress += deltaProgress;
      if (_progress >= 1.0) {
        _progress = 1.0;
        _completed = true;
        onComplete();
      }
    } else {
      // Closing: hole shrinks from full screen to nothing.
      _progress -= deltaProgress;
      if (_progress <= 0.0) {
        _progress = 0.0;
        _completed = true;
        onComplete();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final gameSize = findGame()?.size ?? Vector2.zero();
    if (gameSize == Vector2.zero()) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Calculate current radius based on progress
    final currentRadius = _maxRadius * _progress;

    // Create a path that covers everything except the circular hole
    final rect = Rect.fromLTWH(0, 0, gameSize.x, gameSize.y);
    final center = Offset(gameSize.x / 2, gameSize.y / 2);

    final path = Path()
      ..addRect(rect)
      ..addOval(Rect.fromCircle(center: center, radius: currentRadius));

    // Use even-odd fill rule to create a hole
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  /// Start the transition animation
  void start() {
    _completed = false;
    _progress = expanding ? 0.0 : 1.0;
    _remainingDelay = delay;
  }

  /// Factory method to create a closing transition (visible area shrinks to conceal)
  static CircularWipeTransition closing({
    required VoidCallback onComplete,
    double duration = 1.0,
    double delay = 0.0,
    Color color = const Color(0xFF211F30),
  }) {
    return CircularWipeTransition(
      onComplete: onComplete,
      duration: duration,
      delay: delay,
      color: color,
    );
  }

  /// Factory method to create an opening transition (visible area expands to reveal)
  static CircularWipeTransition opening({
    required VoidCallback onComplete,
    double duration = 1.0,
    double delay = 0.0,
    Color color = const Color(0xFF211F30),
  }) {
    return CircularWipeTransition(
      onComplete: onComplete,
      duration: duration,
      delay: delay,
      color: color,
      expanding: true,
    );
  }
}
