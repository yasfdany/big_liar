# Changelog

## [Unreleased] - 2026-03-11

### Added

- **Dialogue system** (`lib/entities/ui/dialogue_box.dart`): Added a bottom-of-screen HUD dialogue panel triggered whenever the player ignores a button prompt (timer expires without a correct key press).
  - Shows the hero's face (idle sprite, frame 0) as a character avatar on the left side of the panel, surrounded by a decorative ring.
  - Text is revealed one character at a time using a **typewriter effect** (~0.04 s between characters).
  - Randomly selects from 6 complaint phrases every trigger: *"Hey… my button didn't do anything."*, *"Are you sure I'm playing?"*, *"Why is nothing happening when I press?"*, *"You didn't use my move…"*, *"Maybe my controller is broken?"*, *"Did you see me press it?"*
  - Panel **slides up from screen bottom** with a fade-in on entry, and auto-dismisses with a slide-down fade-out 2.5 s after text completes.
  - Rendered in `game.camera.viewport` (HUD / screen-space) — unaffected by world camera pan or zoom.
  - If a new dialogue fires before the old one finishes, the old box is replaced immediately (no stacking).
  - Panel background uses a **`NineTileBoxComponent`** with `assets/images/ui/dialogue_nine_box.png` (48×48, tileSize=16) — pixel-perfect corners that stretch to any panel size.
- **Dialogue trigger** (`lib/entities/ui/input_button.dart`): `resetButton()` now calls `DialogueBox.showRandom(game.camera.viewport)` on the failure path (`collect == false`), keeping the success/collect path silent.
- **Fruit Counter & Suspicion Level HUD** (`lib/game/game_state.dart`, `lib/entities/ui/fruit_counter_hud.dart`, `lib/entities/ui/suspicion_hud.dart`):
  - Created a `GameState` singleton to track global stats across levels.
  - **Fruit Counter**: Top-left icon + text that pops when a fruit is collected.
  - **Suspicion Bar**: Top-right fill bar that increases by +20% when a button prompt is failed.
  - **Passive Drain**: Suspicion level slowly decreases over time (3% per second) to reward active play.
  - **Visual Feedback**: The suspicion bar color shifts green → yellow → red and pulses at ≥80% suspicion.
  - Both HUDs are rendered in world-space as children of `LevelEntity` but track the camera viewfinder each frame to stay pinned to screen corners.

---


### Added

- **Random input button prompt** (`random_input_behavior.dart`): Implemented as a dedicated `RandomInputBehavior` (a `Behavior<HeroEntity>`) following the `flame_behaviors` separation-of-concerns pattern.
  - Registered in `HeroEntity`'s `behaviors` list alongside existing behaviors.
  - Spawns an `InputButton` prompt centered above the hero's head every **5–10 seconds** (re-randomized each interval).
  - Randomly selects from `[InputButtonIcon.xboxA, InputButtonIcon.xboxB]` (jump and dash hints).
  - Each prompt has a **3-second** progress bar — auto-dismisses if ignored.
  - Duplicate guard: skips spawning if an identical icon prompt is already visible on the hero.
  - `KeyboardMovementBehavior` already handles dismissing the matching prompt early when the correct key is pressed (`W`/Up for `xboxA`, `Space` for `xboxB`).
- **Screen shake on failure** (`lib/entities/ui/input_button.dart`): Added a horizontal and vertical camera jitter effect that triggers when the player fails to respond to a button prompt before the timer expires. Uses `MoveEffect.by` on the camera's viewfinder.

---

### Added

- **UI Buttons** (`lib/entities/ui/input_button.dart`, `lib/entities/ui/input_button_icon.dart`): Created a reusable `InputButton` entity that uses a `SpriteGroupComponent` to display various controller and keyboard icons from `assets/images/ui/buttons.png`.
  - Supports Xbox, PlayStation, Keyboard, and Mouse icons (34 distinct states).
  - Added optional **progress timer** with a visual rectangle bar below the icon.
  - Uses 20x16 sprite grid.

- **Item collected animation** (`collected_all_effect.dart`, `collectible_behavior.dart`): A 6-frame one-shot animation from `assets/images/items/collected.png` now plays at the item's position every time any item is collected by the hero, then auto-removes.
  - New `CollectedAllEffect` — `SpriteAnimationComponent` with `removeOnFinish: true`, anchored `center` at the item's center position.
  - `CollectibleBehavior` spawns the effect into `parent.parent` (LevelEntity) at the item's center before calling `removeFromParent()`.

- **Particle effects** (`particle_effect_behavior.dart`, `hero.dart`): Reworked `ParticleEffectBehavior` with:
  - **Run dust**: Brownish/tan `ComputedParticle` circles emitted from hero's feet every 80ms while in `run` state, fading and shrinking over 0.25–0.45s.
  - **Dash burst**: On dash activation — radial cyan/purple spark ring (18 particles with blur glow), direction streak blobs (6 particles trailing opposite to facing), and a flat ground shockwave ring when on ground.
  - **Sprite ghost trail**: Fading copies of the actual hero sprite rendered every 40ms while dashing with a blue/violet `ColorFilter` tint, correctly mirrored when hero is flipped.
  - Added `currentSprite` getter to `HeroEntity` (via `animationTicker?.getSprite()`) so the behavior can snapshot the live animation frame.

### Fixed

- **Particle spawn coordinates** (`particle_effect_behavior.dart`): Particles are now spawned into `parent.parent` (LevelEntity) at `parent.position` coordinates rather than `game.world` with `absolutePosition`, eliminating all world-space / camera-zoom conversion issues.
- **Dust not appearing** (`particle_effect_behavior.dart`): Dust was always suppressed because `KeyboardMovementBehavior` sets `parent.isOnGround = false` _after_ setting `state = HeroState.run`, so by the time `ParticleEffectBehavior.update()` ran, `isOnGround` was always `false`. Fixed by checking only `state == HeroState.run`.

- **Dash mechanic** (`keyboard_movement_behavior.dart`, `hero.dart`): Hero can now dash by pressing `Space`. Dash multiplies horizontal speed by `3.5×` for `0.15s`, with a `0.5s` cooldown before it can be used again. Dash can only be triggered via `KeyDownEvent` (no hold-to-spam). A new `HeroState.dash` was added to the enum, playing the `run` sprite sheet at double speed (`stepTime: 0.025`) as a visual approximation since no dedicated dash sprite exists.

### Changed

- **Jump keybinding** (`keyboard_movement_behavior.dart`): Jump is now triggered by `W` or `Up Arrow` instead of `Space`. Double-jump logic remains unchanged.
- **Spacebar** reassigned from jump to dash (see above).

---

### Added

- **Flag entity** (`entities/object/flag/flag.dart`, `flag_touch_behavior.dart`): Created a finish-line flag with `SpriteAnimationGroupComponent<FlagState>` supporting three states:
  - `pole` → static 1-frame sprite, shown before the hero arrives.
  - `raise` → 26-frame one-shot animation triggered when the hero touches the flag (`FlagTouchBehavior`). Auto-transitions to `idle` via `onComplete`.
  - `idle` → 10-frame looping waving animation shown after raising.
  - The flag can be placed in Tiled maps using the object name `flag` in the `items` layer. Sprite textures use 64×64 frames from `assets/images/objects/`.

- **Map boundary clamping** (`hero.dart`, `keyboard_movement_behavior.dart`, `level.dart`): Hero is now prevented from walking beyond the horizontal edges of the map. Changed `mapBounds` on `HeroEntity` from `Vector2?` to `Rect?` to support a left-edge offset. Level sets static bounds based on a **35×20 tile map at 16px**, with a 1-tile border giving a **33×18 playable area starting at tile (1,1)** — pixels `(16, 16) → (544, 304)`. Clamp in movement behavior now uses `bounds.left + halfWidth` and `bounds.right - halfWidth`.

### Changed

- **Hero movement smoothing** (`keyboard_movement_behavior.dart`): Replaced instant direction snapping with a lerp-based approach. A new `acceleration` parameter (default `10`) controls how quickly `_currentMovement` interpolates toward `_targetMovement` each frame, resulting in a much smoother, non-snappy feel when the player changes direction or decelerates.
  - Added `_targetMovement` (input intent, still snaps instantly) and `_currentMovement` (smoothed value used for actual movement and animation state).
  - Sprite flip logic continues to use `_targetMovement` so the character faces the correct direction immediately on input, while the body position eases naturally.
  - A micro-movement threshold (`< 0.01`) snaps `_currentMovement` to zero to avoid perpetual tiny drift.
