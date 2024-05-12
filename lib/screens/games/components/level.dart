import 'dart:async';

import 'package:app_asd_diagnostic/screens/games/components/background_tile.dart';
import 'package:app_asd_diagnostic/screens/games/components/checkpoint.dart';
import 'package:app_asd_diagnostic/screens/games/components/chicken.dart';
import 'package:app_asd_diagnostic/screens/games/components/collision_block.dart';
import 'package:app_asd_diagnostic/screens/games/components/fruit.dart';
import 'package:app_asd_diagnostic/screens/games/components/player.dart';
import 'package:app_asd_diagnostic/screens/games/components/saw.dart';
import 'package:app_asd_diagnostic/screens/games/pixel_adventure.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  final String levelName;
  final Player player;
  Level({required this.levelName, required this.player});
  late TiledComponent level;
  List<CollisionBlock> colisionBlocks = [];
  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(levelName, Vector2(16, 16));
    level.priority = 10;
    add(level);

    _scrollingBackground();
    _spawingObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');

    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('BackgroundColor');
      final backgroundTile = BackgroundTile(
        color: backgroundColor ?? 'Gray',
        position: Vector2(0, 0),
      );
      add(backgroundTile);
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                isPlatform: true);
            colisionBlocks.add(platform);
            break;
          default:
            final block = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                isPlatform: false);
            colisionBlocks.add(block);
            break;
        }
      }
    }
    player.collisionBlocks = colisionBlocks;
  }

  void _spawingObjects() {
    // Load the spawn points in the layer
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointsLayer != null) {
      // Loop through all the spawn points
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            player.scale.x = 1;
            add(player);
            break;

          case 'Fruit':
            final fruit = Fruit(
                fruit: spawnPoint.name,
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2(spawnPoint.width, spawnPoint.height));
            add(fruit);
            break;
          case 'Saw':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final saw = Saw(
                isVertical: isVertical,
                offNeg: offNeg,
                offPos: offPos,
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2(spawnPoint.width, spawnPoint.height));
            add(saw);
            break;
          case 'Checkpoint':
            final checkpoint = Checkpoint(
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2(spawnPoint.width, spawnPoint.height));
            add(checkpoint);
            break;
          case 'Chicken':
            final chicken = Chicken(
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2(spawnPoint.width, spawnPoint.height),
                offNeg: spawnPoint.properties.getValue('offNeg'),
                offPos: spawnPoint.properties.getValue('offPos'));
            add(chicken);
            break;
        }
      }
    }
  }
}
