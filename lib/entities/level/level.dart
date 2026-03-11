import 'dart:ui' show Rect;

import 'package:big_brother/entities/background/background.dart';
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
import 'package:big_brother/entities/level/solid_platform.dart';
import 'package:big_brother/entities/object/flag/flag.dart';
import 'package:big_brother/entities/ui/item_counter_hud.dart';
import 'package:big_brother/entities/ui/suspicion_hud.dart';
import 'package:big_brother/game/game_state.dart';
import 'package:collection/collection.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled_utils/flame_tiled_utils.dart';

class LevelEntity extends PositionedEntity with HasGameReference {
  LevelEntity({this.levelName});

  final String? levelName;

  int totalItems = 0;
  late String bgImage;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    GameState.instance.reset();

    final levelFile = '$levelName.tmx';

    final imageCompiler = ImageBatchCompiler();
    final tiledMap = await TiledComponent.load(
      levelFile,
      Vector2.all(16),
      prefix: 'assets/images/tiles/',
      images: Images(
        prefix: 'assets/images/tiles/',
      )..load('tile.png'),
    );
    position = -tiledMap.size / 2;
    size = tiledMap.size;

    final itemGroups = tiledMap.tileMap.getLayer<ObjectGroup>(
      'items',
    );
    final positionGroups = tiledMap.tileMap.getLayer<ObjectGroup>(
      'position',
    );
    final frameGroups = tiledMap.tileMap.getLayer<TileLayer>(
      'frame',
    );

    bgImage =
        frameGroups?.properties.byName['background']?.value.toString() ?? '';
    game.world.add(BackgroundEntity(bgImage: bgImage, priority: -1));

    final maps = imageCompiler.compileMapLayer(
      tileMap: tiledMap.tileMap,
      layerNames: ['items', 'ground', 'position', 'frame'],
    );

    for (final item in itemGroups?.objects ?? <TiledObject>[]) {
      switch (item.name) {
        case 'apple':
          totalItems++;
          add(Apple()..position = item.position);
        case 'bananas':
          totalItems++;
          add(Bananas()..position = item.position);
        case 'cherries':
          totalItems++;
          add(Cherries()..position = item.position);
        case 'kiwi':
          totalItems++;
          add(Kiwi()..position = item.position);
        case 'melon':
          totalItems++;
          add(Melon()..position = item.position);
        case 'orange':
          totalItems++;
          add(Orange()..position = item.position);
        case 'pineapple':
          totalItems++;
          add(Pineapple()..position = item.position);
        case 'strawberry':
          totalItems++;
          add(Strawberry()..position = item.position);
        case 'flag':
          add(FlagEntity()..position = item.position);
        default:
          break;
      }
    }

    // Set total collectible items in GameState
    GameState.instance.totalItems = totalItems;

    add(maps);

    final groundLayer = tiledMap.tileMap.getLayer<TileLayer>('ground');
    if (groundLayer != null) {
      final tileData = groundLayer.tileData;
      if (tileData != null) {
        for (var y = 0; y < tileData.length; y++) {
          for (var x = 0; x < tileData[y].length; x++) {
            final tile = tileData[y][x];

            final tileObj = tiledMap.tileMap.map.tileByGid(tile.tile);
            if (tileObj != null && (tileObj.class_ == 'platform')) {
              final platformPosition = Vector2(
                x * tiledMap.tileMap.destTileSize.x,
                y * tiledMap.tileMap.destTileSize.y,
              );

              add(
                OneWayPlatform(
                  position: platformPosition,
                  size: tiledMap.tileMap.destTileSize,
                ),
              );
            } else if (tileObj != null && (tileObj.class_ == 'solid')) {
              final solidPosition = Vector2(
                x * tiledMap.tileMap.destTileSize.x,
                y * tiledMap.tileMap.destTileSize.y,
              );

              add(
                SolidPlatform(
                  position: solidPosition,
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
    final endPositions = (positionGroups?.objects ?? [])
        .firstWhereOrNull((e) => e.name == 'end')
        ?.position;

    if (endPositions != null) {
      add(FlagEntity(position: endPositions));
    }

    if (startPositions != null) {
      final hero = HeroEntity(position: startPositions);
      const tileSize = 16.0;
      hero.mapBounds = const Rect.fromLTRB(
        1 * tileSize,
        1 * tileSize,
        32 * tileSize,
        17 * tileSize,
      );
      add(hero);
    }

    add(ItemCounterHud());
    add(SuspicionHud(position: Vector2(size.x - 88, -20)));
  }
}
