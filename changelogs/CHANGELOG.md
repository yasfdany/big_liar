# Changelog

## [Unreleased] - 2026-03-10

### Changed

- **Hero movement smoothing** (`keyboard_movement_behavior.dart`): Replaced instant direction snapping with a lerp-based approach. A new `acceleration` parameter (default `10`) controls how quickly `_currentMovement` interpolates toward `_targetMovement` each frame, resulting in a much smoother, non-snappy feel when the player changes direction or decelerates.
  - Added `_targetMovement` (input intent, still snaps instantly) and `_currentMovement` (smoothed value used for actual movement and animation state).
  - Sprite flip logic continues to use `_targetMovement` so the character faces the correct direction immediately on input, while the body position eases naturally.
  - A micro-movement threshold (`< 0.01`) snaps `_currentMovement` to zero to avoid perpetual tiny drift.
