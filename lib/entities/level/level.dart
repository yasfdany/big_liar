import 'package:big_brother/entities/hero/hero_entity.dart';
import 'package:big_brother/entities/item/apple.dart';
import 'package:big_brother/entities/item/bananas.dart';
import 'package:big_brother/entities/item/cherries.dart';
import 'package:big_brother/entities/item/kiwi.dart';
import 'package:big_brother/entities/item/melon.dart';
import 'package:big_brother/entities/item/orange.dart';
import 'package:big_brother/entities/item/pineapple.dart';
import 'package:big_brother/entities/item/strawberry.dart';
import 'package:big_brother/entities/level/one_way_platform.dart';
import 'package:collection/collection.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled_utils/flame_tiled_utils.dart';

class LevelEntity extends PositionedEntity {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final imageCompiler = ImageBatchCompiler();
    final tiledMap = await TiledComponent.load(
      'level_1.tmx',
      Vector2.all(16), // tile size in the map
      prefix: 'assets/images/tiles/',
      images: Images(
        prefix: 'assets/images/tiles/',
      )..load('tile.png'),
    );
    position = -tiledMap.size / 2;

    final itemGroups = tiledMap.tileMap.getLayer<ObjectGroup>(
      'items',
    );
    final positionGroups = tiledMap.tileMap.getLayer<ObjectGroup>(
      'position',
    );

    final maps = imageCompiler.compileMapLayer(
      tileMap: tiledMap.tileMap,
      layerNames: ['items', 'ground', 'position', 'frame'],
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

    await add(maps);

    final groundLayer = tiledMap.tileMap.getLayer<TileLayer>('ground');
    if (groundLayer != null) {
      final tileData = groundLayer.tileData;
      if (tileData != null) {
        for (var y = 0; y < tileData.length; y++) {
          for (var x = 0; x < tileData[y].length; x++) {
            final tile = tileData[y][x];
            // Get the tile object to check its class/type
            final tileObj = tiledMap.tileMap.map.tileByGid(tile.tile);
            if (tileObj != null && (tileObj.class_ == 'platform')) {
              final platformPosition = Vector2(
                x * tiledMap.tileMap.destTileSize.x,
                y * tiledMap.tileMap.destTileSize.y,
              );
              // Adding OneWayPlatform
              add(
                OneWayPlatform(
                  position: platformPosition,
                  size: tiledMap.tileMap.destTileSize,
                ),
              );
            }
          }
        }
      }
    }

    final startPositions = (positionGroups?.objects ?? [])
        .firstWhereOrNull((e) => e.name == 'start')
        ?.position;
    if (startPositions != null) {
      add(HeroEntity(position: startPositions));
    }
  }
}
