class GameState {
  GameState._();

  static final GameState instance = GameState._();

  final List<String> levels = [
    'level_1',
    'level_2',
  ];

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

  bool _flagAnimationComplete = false;
  bool get flagAnimationComplete => _flagAnimationComplete;

  int _currentLevel = 0;
  int get currentLevel => _currentLevel;

  bool _levelComplete = false;
  bool get levelComplete => _levelComplete;

  String get levelName => levels[currentLevel];

  void completeFlagAnimation() {
    _flagAnimationComplete = true;
    _levelComplete = true;
    _notify(_levelCompleteListeners);
  }

  bool nextLevel() {
    if (_currentLevel + 1 > levels.length - 1) {
      return false;
    }
    _currentLevel++;
    _flagRaised = false;
    _flagAnimationComplete = false;
    _levelComplete = false;
    return true;
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
    _flagRaised = false;
    _flagAnimationComplete = false;
    _levelComplete = false;
    _notify(_itemListeners);
    _notify(_suspicionListeners);
  }

  final List<void Function()> _itemListeners = [];
  final List<void Function()> _suspicionListeners = [];
  final List<void Function()> _levelCompleteListeners = [];

  void addFruitListener(void Function() cb) => _itemListeners.add(cb);
  void removeFruitListener(void Function() cb) => _itemListeners.remove(cb);

  void addSuspicionListener(void Function() cb) => _suspicionListeners.add(cb);
  void removeSuspicionListener(void Function() cb) =>
      _suspicionListeners.remove(cb);

  void addLevelCompleteListener(void Function() cb) =>
      _levelCompleteListeners.add(cb);
  void removeLevelCompleteListener(void Function() cb) =>
      _levelCompleteListeners.remove(cb);

  void _notify(List<void Function()> listeners) {
    for (final cb in List.of(listeners)) {
      cb();
    }
  }
}
