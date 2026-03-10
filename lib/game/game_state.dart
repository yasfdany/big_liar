/// Singleton that tracks global game state shared across components.
///
/// Components subscribe via [addFruitListener] / [addSuspicionListener] to
/// react to state changes (e.g. HUD components refreshing their display).
class GameState {
  GameState._();

  static final GameState instance = GameState._();

  // ── Fruit counter ─────────────────────────────────────────────────────────

  int _fruitsCollected = 0;
  int get fruitsCollected => _fruitsCollected;

  void collectFruit() {
    _fruitsCollected++;
    _notify(_fruitListeners);
  }

  // ── Suspicion level (0–100) ───────────────────────────────────────────────

  double _suspicion = 0;
  double get suspicion => _suspicion;

  /// How many points are drained per second passively.
  static const double _drainRate = 3.0;

  /// Fixed increase applied on each button-prompt failure.
  static const double _suspicionPerFailure = 20.0;

  void addSuspicion([double amount = _suspicionPerFailure]) {
    _suspicion = (_suspicion + amount).clamp(0, 100);
    _notify(_suspicionListeners);
  }

  /// Called every frame by a HUD component so the level drains passively.
  void tick(double dt) {
    final before = _suspicion;
    _suspicion = (_suspicion - _drainRate * dt).clamp(0, 100);
    if ((_suspicion - before).abs() > 0.01) {
      _notify(_suspicionListeners);
    }
  }

  /// Resets all state (e.g. when a level is reloaded).
  void reset() {
    _fruitsCollected = 0;
    _suspicion = 0;
    _notify(_fruitListeners);
    _notify(_suspicionListeners);
  }

  // ── Listener plumbing ─────────────────────────────────────────────────────

  final List<void Function()> _fruitListeners = [];
  final List<void Function()> _suspicionListeners = [];

  void addFruitListener(void Function() cb) => _fruitListeners.add(cb);
  void removeFruitListener(void Function() cb) => _fruitListeners.remove(cb);

  void addSuspicionListener(void Function() cb) =>
      _suspicionListeners.add(cb);
  void removeSuspicionListener(void Function() cb) =>
      _suspicionListeners.remove(cb);

  void _notify(List<void Function()> listeners) {
    for (final cb in List.of(listeners)) {
      cb();
    }
  }
}
