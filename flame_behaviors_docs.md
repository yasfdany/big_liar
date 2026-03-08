# Flame Behaviors

The `flame_behaviors` package provides a structured way of writing game code that is both scalable and testable. It does this by applying separation of concerns in the form of Entities and Behaviors.

## Core Concepts

- **Entity**: An entity is a visual representation of a game object (e.g., a paddle or a ball). Each entity can have one or more behaviors to define how it should behave within your game.
- **Behavior**: Behaviors handle a single aspect of an entity and can be made generic so they are reusable over different types of entities. By separating the entity's behavioral aspects into behaviors, we can then test each behavior without having to worry about the others.

## Defining Entities

Entities usually extend `PositionedEntity` or `Entity`. Entities often define how they look by passing visual components to the `children` argument and pass logic to the `behaviors` argument. Persistent data specific to the entity (like velocity) should live on the entity, not on the behaviors.

Example of a Paddle Entity:

```dart
class Paddle extends PositionedEntity {
  Paddle._({
    required Vector2 center,
    required Behavior movingBehavior,
  }) : super(
          position: center,
          size: Vector2(8, 50),
          anchor: Anchor.center,
          children: [
            RectangleComponent.relative(Vector2.all(1), parentSize: Vector2(8, 50), paint: PongGame.paint),
            RectangleHitbox(),
          ],
          behaviors: [movingBehavior],
        );
}
```

## Defining Behaviors

Behaviors extend the `Behavior` class and can use mixins like `KeyboardHandler`, `HasGameRef`, `CollisionBehavior`, etc.

Example of a Moving Behavior:

```dart
class KeyboardMovingBehavior extends Behavior with KeyboardHandler, HasGameRef {
  KeyboardMovingBehavior({this.speed = 100, required this.downKey, required this.upKey});

  final LogicalKeyboardKey upKey;
  final LogicalKeyboardKey downKey;
  final double speed;
  double _movement = 0;

  @override
  bool onKeyEvent(RawKeyEvent event, Set keysPressed) {
    if (keysPressed.contains(upKey)) {
      _movement = -1;
    } else if (keysPressed.contains(downKey)) {
      _movement = 1;
    } else {
      _movement = 0;
    }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    parent.position.y += _movement * speed * dt;
    parent.position.y = parent.position.y.clamp(
      parent.size.y / 2 + Field.halfWidth,
      gameRef.size.y - parent.size.y / 2 - Field.halfWidth,
    );
  }
}
```

## Collision Behaviors

To implement collisions with behaviors, use `PropagatingCollisionBehavior` on the Entity. It handles receiving collisions and propagating them to behaviors extending `CollisionBehavior`.

Example:

```dart
class Ball extends PositionedEntity with HasGameRef {
  Ball({Iterable? behaviors}) : super(
    behaviors: [
      PropagatingCollisionBehavior(CircleHitbox()),
      if (behaviors != null) ...behaviors,
    ]
  );
}

class PaddleCollidingBehavior extends CollisionBehavior {
  @override
  void onCollisionStart(Set intersectionPoints, Paddle other) {
    parent.velocity.x *= -1; // Reverse velocity when hitting paddle
  }
}
```

## Testing Entities and Behaviors

Flame Behaviors applies separation of concerns, which makes the code 100% testable. Entities and behaviors can be tested independently. Using `FlameTester` from `flame_test`, behaviors can be tested by mocking the objects they interact with.
