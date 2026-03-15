/// Non-web stub for GamepadChannel.
/// Returns no-op behavior on platforms that don't support the Web Gamepad API.
class GamepadChannel {
  bool get isSupported => false;

  void poll() {}

  double get horizontalAxis => 0;
  bool get isAPressed => false;
  bool get isBPressed => false;
  bool get isAJustPressed => false;
  bool get isBJustPressed => false;

  void dispose() {}
}
