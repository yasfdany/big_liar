import 'dart:js_interop';

@JS('navigator')
external _JsNavigator get _jsNavigator;

extension type _JsNavigator._(JSObject _) implements JSObject {
  external JSArray<JSAny?> getGamepads();
}

extension type _JsGamepad._(JSObject _) implements JSObject {
  external JSArray<JSAny?> get axes;
  external JSArray<JSAny?> get buttons;
}

extension type _JsGamepadButton._(JSObject _) implements JSObject {
  @JS('pressed')
  external JSBoolean get _pressed;
  bool get isPressed => _pressed.toDart;
}

class GamepadChannel {
  bool get isSupported => true;

  double _horizontalAxis = 0;
  bool _aPressed = false;
  bool _bPressed = false;

  bool _prevAPressed = false;
  bool _prevBPressed = false;

  double get horizontalAxis => _horizontalAxis;

  bool get isAPressed => _aPressed;

  bool get isBPressed => _bPressed;

  bool get isAJustPressed => _aPressed && !_prevAPressed;

  bool get isBJustPressed => _bPressed && !_prevBPressed;

  void poll() {
    _prevAPressed = _aPressed;
    _prevBPressed = _bPressed;

    _JsGamepad? active;

    try {
      final gamepads = _jsNavigator.getGamepads();
      for (var i = 0; i < gamepads.length; i++) {
        final gp = gamepads[i];
        if (gp != null && !gp.isUndefinedOrNull) {
          active = gp as _JsGamepad;
          break;
        }
      }
    } on Object catch (_) {}

    if (active == null) {
      _horizontalAxis = 0;
      _aPressed = false;
      _bPressed = false;
      return;
    }

    _readGamepad(active);
  }

  void _readGamepad(_JsGamepad gamepad) {
    final axes = gamepad.axes;
    final buttons = gamepad.buttons;

    double axisX = 0;
    if (axes.length > 0) {
      final val = axes[0];
      if (val != null && !val.isUndefinedOrNull) {
        axisX = (val as JSNumber).toDartDouble;
      }
    }

    final dpadLeft = _btnPressed(buttons, 14);
    final dpadRight = _btnPressed(buttons, 15);

    if (dpadLeft) {
      _horizontalAxis = -1;
    } else if (dpadRight) {
      _horizontalAxis = 1;
    } else {
      _horizontalAxis = axisX.abs() > 0.15 ? axisX : 0;
    }

    _aPressed = _btnPressed(buttons, 1);
    _bPressed = _btnPressed(buttons, 2);
  }

  bool _btnPressed(JSArray<JSAny?> buttons, int index) {
    if (index >= buttons.length) {
      return false;
    }
    final btn = buttons[index];
    if (btn == null || btn.isUndefinedOrNull) {
      return false;
    }
    return (btn as _JsGamepadButton).isPressed;
  }

  void dispose() {}
}
