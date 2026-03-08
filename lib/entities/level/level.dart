import 'package:big_brother/entities/hero/hero_entity.dart';
import 'package:big_brother/entities/item/apple.dart';
import 'package:big_brother/entities/item/bananas.dart';
import 'package:big_brother/entities/item/cherries.dart';
import 'package:big_brother/entities/item/kiwi.dart';
import 'package:big_brother/entities/item/melon.dart';
import 'package:big_brother/entities/item/orange.dart';
import 'package:big_brother/entities/item/pineapple.dart';
import 'package:big_brother/entities/item/strawberry.dart';
import 'package:collection/collection.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_tiled/flame_tiled.dart';

class LevelEntity extends PositionedEntity {
  LevelEntity() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load the Tiled map using the custom prefix
    final tiledMap = await TiledComponent.load(
      'level1.tmx',
      Vector2.all(16), // tile size in the map
      prefix: 'assets/images/tiles/',
      images: Images(
        prefix: 'assets/images/tiles/',
      )..load('tile.png'),
    );

    final itemGroups = tiledMap.tileMap.getLayer<ObjectGroup>(
      'items',
    );
    final positionGroups = tiledMap.tileMap.getLayer<ObjectGroup>(
      'position',
    );

    for (final item in itemGroups?.objects ?? <TiledObject>[]) {
      switch (item.name) {
        case 'apple':
          add(Apple()..position = item.position);
        case 'bananas':
          add(Bananas()..position = item.position);
        case 'cherries':
          add(Cherries()..position = item.position);
        case 'kiwi':
          add(Kiwi()..position = item.position);
        case 'melon':
          add(Melon()..position = item.position);
        case 'orange':
          add(Orange()..position = item.position);
        case 'pineapple':
          add(Pineapple()..position = item.position);
        case 'strawberry':
          add(Strawberry()..position = item.position);
        default:
          break;
      }
    }

    // Update the size of the entity to match the map so the center anchor works
    size = tiledMap.size;

    // Add the tiled map as a child to visually represent this entity
    await add(tiledMap);

    final startPositions = (positionGroups?.objects ?? [])
        .firstWhereOrNull((e) => e.name == 'start')
        ?.position;
    if (startPositions != null) {
      add(HeroEntity(position: startPositions));
    }
  }
}
