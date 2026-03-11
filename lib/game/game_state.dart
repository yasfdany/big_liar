class GameState {
  GameState._();

  static final GameState instance = GameState._();

  int _itemCollected = 0;
  int get itemCollected => _itemCollected;

  int _totalItems = 0;
  int get totalItems => _totalItems;
  set totalItems(int value) {
    _totalItems = value;
    _notify(_itemListeners);
  }

  bool _flagRaised = false;
  bool get flagRaised => _flagRaised;
  set flagRaised(bool value) {
    _flagRaised = value;
    if (value) {
      _notify(_itemListeners);
    }
  }

  bool get allItemsCollected =>
      _totalItems > 0 && _itemCollected >= _totalItems;

  void collectFruit() {
    _itemCollected++;
    _notify(_itemListeners);
  }

  double _suspicion = 0;
  double get suspicion => _suspicion;

  static const double _drainRate = 3.0;

  static const double _suspicionPerFailure = 20.0;

  void addSuspicion([double amount = _suspicionPerFailure]) {
    _suspicion = (_suspicion + amount).clamp(0, 100);
    _notify(_suspicionListeners);
  }

  void tick(double dt) {
    final before = _suspicion;
    _suspicion = (_suspicion - _drainRate * dt).clamp(0, 100);
    if ((_suspicion - before).abs() > 0.01) {
      _notify(_suspicionListeners);
    }
  }

  void reset() {
    _itemCollected = 0;
    _totalItems = 0;
    _suspicion = 0;
    _notify(_itemListeners);
    _notify(_suspicionListeners);
  }

  final List<void Function()> _itemListeners = [];
  final List<void Function()> _suspicionListeners = [];

  void addFruitListener(void Function() cb) => _itemListeners.add(cb);
  void removeFruitListener(void Function() cb) => _itemListeners.remove(cb);

  void addSuspicionListener(void Function() cb) => _suspicionListeners.add(cb);
  void removeSuspicionListener(void Function() cb) =>
      _suspicionListeners.remove(cb);

  void _notify(List<void Function()> listeners) {
    for (final cb in List.of(listeners)) {
      cb();
    }
  }
}
