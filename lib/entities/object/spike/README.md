# Spike Component Documentation

The Spike component supports 4 different orientations with appropriate hitboxes and visual rotation.

## Spike Variants

### bottom_spike (Default)
- **Direction**: `SpikeDirection.bottom`
- **Visual**: Spikes point upward
- **Rotation**: 0° (original orientation)
- **Hitbox**: Bottom half of sprite (Y: 8-16, X: 0-16)
- **Use case**: Floor traps

### top_spike
- **Direction**: `SpikeDirection.top`
- **Visual**: Spikes point downward
- **Rotation**: 180°
- **Hitbox**: Top half of sprite (Y: 0-8, X: 0-16)
- **Use case**: Ceiling traps

### left_spike
- **Direction**: `SpikeDirection.left`
- **Visual**: Spikes point rightward
- **Rotation**: -90° (counter-clockwise)
- **Hitbox**: Left half of sprite (Y: 0-16, X: 0-8)
- **Use case**: Left wall traps

### right_spike
- **Direction**: `SpikeDirection.right`
- **Visual**: Spikes point leftward
- **Rotation**: 90° (clockwise)
- **Hitbox**: Right half of sprite (Y: 0-16, X: 8-16)
- **Use case**: Right wall traps

## Usage in Tiled Map Editor

Add objects to the "items" layer with the following names:
- `spike` or `bottom_spike` - for upward pointing spikes
- `top_spike` - for downward pointing spikes
- `left_spike` - for rightward pointing spikes
- `right_spike` - for leftward pointing spikes

## Implementation

All spike variants:
1. Use the same 16x16 sprite rotated appropriately
2. Have collision detection only on the "dangerous" half of the sprite
3. Restart the level when touched by the player
4. Add suspicion to the game state

## Hitbox Visualization

```
bottom_spike (↑)     top_spike (↓)       left_spike (→)      right_spike (←)
┌────────────────┐   ┌────────────────┐  ┌────────────────┐  ┌────────────────┐
│                │   │ ████████████ │  │ ████│            │  │            │████│
│                │   │ ████████████ │  │ ████│            │  │            │████│
│                │   │ ████████████ │  │ ████│            │  │            │████│
│                │   │ ████████████ │  │ ████│            │  │            │████│
├────────────────┤   ├────────────────┤  │ ████│            │  │            │████│
│ ████████████ │   │                │  │ ████│            │  │            │████│
│ ████████████ │   │                │  │ ████│            │  │            │████│
│ ████████████ │   │                │  │ ████│            │  │            │████│
│ ████████████ │   │                │  │ ████│            │  │            │████│
└────────────────┘   └────────────────┘  └────────────────┘  └────────────────┘
```

The `████` areas represent the active collision hitboxes.