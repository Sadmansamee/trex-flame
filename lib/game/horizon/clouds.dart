import 'dart:ui';

import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/position_component.dart';
import 'package:flame/components/sprite_component.dart';
import 'package:flame/sprite.dart';
import 'package:flame/extensions/vector2.dart';

import 'package:trex/game/custom/util.dart';
import 'package:trex/game/horizon/config.dart';

class CloudManager extends PositionComponent with HasGameRef {
  CloudManager(this.spriteImage) : super();

  Image spriteImage;

  void updateWithSpeed(double t, double speed) {
    final double cloudSpeed = HorizonConfig.bgCloudSpeed / 1000 * t * speed;
    final int numClouds = children.length;

    if (numClouds > 0) {
      for (final c in children) {
        final cloud = c as Cloud;
        cloud.updateWithSpeed(t, cloudSpeed);
      }

      final lastCloud = children.last as Cloud;
      if (numClouds < HorizonConfig.maxClouds &&
          (size.x / 2 - lastCloud.x) > lastCloud.cloudGap) {
        addCloud();
      }
    } else {
      addCloud();
    }
  }

  void addCloud() {
    final cloud = Cloud(spriteImage);
    cloud.x = size.x + CloudConfig.width + 10;
    cloud.y = (y / 2 - (CloudConfig.maxSkyLevel - CloudConfig.minSkyLevel)) +
        getRandomNum(CloudConfig.minSkyLevel, CloudConfig.maxSkyLevel);
    addChild(cloud);
  }

  void reset() {
    children.clear();
  }
}

class Cloud extends SpriteComponent {
  Cloud(Image spriteImage)
      : cloudGap =
            getRandomNum(CloudConfig.minCloudGap, CloudConfig.maxCloudGap),
        super.fromSprite(
          Vector2(
            CloudConfig.width,
            CloudConfig.height,
          ),
          Sprite(
            spriteImage,
            srcPosition: Vector2(2.0, 166.0),
            srcSize: Vector2(
              CloudConfig.width,
              CloudConfig.height,
            ),
          ),
        );

  final double cloudGap;
  bool toRemove = false;

  void updateWithSpeed(double t, double speed) {
    if (toRemove) {
      return;
    }
    x -= speed.ceil() * 50 * t;

    if (!isVisible) {
      toRemove = true;
    }
  }

  @override
  bool remove() {
    return toRemove;
  }

  bool get isVisible {
    return x + CloudConfig.width > 0;
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    y = (y / 2 - (CloudConfig.maxSkyLevel - CloudConfig.minSkyLevel)) +
        getRandomNum(CloudConfig.minSkyLevel, CloudConfig.maxSkyLevel);
  }
}
