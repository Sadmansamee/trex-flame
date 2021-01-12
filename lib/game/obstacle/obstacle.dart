import 'dart:collection';
import 'dart:ui';

import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/position_component.dart';
import 'package:flame/components/sprite_component.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/sprite.dart';

import 'package:trex/game/collision/collision_box.dart';
import 'package:trex/game/custom/util.dart';
import 'package:trex/game/game.dart';
import 'package:trex/game/game_config.dart';
import 'package:trex/game/horizon/config.dart';
import 'package:trex/game/obstacle/config.dart';
import 'package:trex/game/obstacle/obstacle_type.dart';

class ObstacleManager extends PositionComponent with HasGameRef<TRexGame> {
  ObstacleManager(this.spriteImage) : super();

  ListQueue<ObstacleType> history = ListQueue();

  Image spriteImage;

  void updateWithSpeed(double t, double speed) {
    for (final c in children) {
      final cloud = c as Obstacle;
      cloud.updateWithSpeed(t, speed);
    }

    if (children.isNotEmpty) {
      final lastObstacle = children.last as Obstacle;

      if (lastObstacle != null &&
          !lastObstacle.followingObstacleCreated &&
          lastObstacle.isVisible &&
          (lastObstacle.x + lastObstacle.width + lastObstacle.gap) <
              HorizonDimensions.width) {
        addNewObstacle(speed);
        lastObstacle.followingObstacleCreated = true;
      }
    } else {
      addNewObstacle(speed);
    }
  }

  void addNewObstacle(double speed) {
    final type = getRandomNum(0.0, 1.0).round() == 0
        ? ObstacleType.cactusSmall
        : ObstacleType.cactusLarge;
    if (duplicateObstacleCheck(type) || speed < type.multipleSpeed) {
      return;
    } else {
      final obstacleSprite = ObstacleType.spriteForType(type, spriteImage);
      final obstacle = Obstacle(
        type,
        obstacleSprite,
        speed,
        GameConfig.gapCoefficient,
        type.width,
      );

      obstacle.x = size.x;
      addChild(obstacle);

      history.addFirst(type);
      if (history.length > 1) {
        final sublist =
            history.toList().sublist(0, GameConfig.maxObstacleDuplication);
        history = ListQueue.from(sublist);
      }
    }
  }

  bool duplicateObstacleCheck(ObstacleType nextType) {
    int duplicateCount = 0;
    for (final c in history) {
      duplicateCount += c == nextType ? 1 : 0;
    }
    return duplicateCount >= GameConfig.maxObstacleDuplication;
  }

  void reset() {
    children.clear();
    history.clear();
  }

  @override
  void update(dt) {
    for (final c in children) {
      final cloud = c as Obstacle;
      cloud.y = y + cloud.type.y - 75;
    }
    super.update(dt);
  }
}

class Obstacle extends SpriteComponent {
  Obstacle(
    this.type,
    Sprite sprite,
    double speed,
    double gapCoefficient, [
    double xOffset,
  ]) : super.fromSprite(
          Vector2(
            type.width,
            type.height,
          ),
          sprite,
        ) {
    cloneCollisionBoxes();

    internalSize = getRandomNum(
      1.0,
      ObstacleConfig.maxObstacleLength / 1,
    ).floor();
    x = HorizonDimensions.width + (xOffset ?? 0.0);

    if (internalSize > 1 && type.multipleSpeed > speed) {
      internalSize = 1;
    }

    width = type.width * internalSize;
    final actualSrc = this.sprite.src;
    this.sprite.src = Rect.fromLTWH(
      actualSrc.left,
      actualSrc.top,
      width,
      actualSrc.height,
    );

    gap = getGap(gapCoefficient, speed);
  }

  List<CollisionBox> collisionBoxes = [];
  ObstacleType type;

  bool toRemove = false;
  bool followingObstacleCreated = false;
  double gap = 0.0;
  int internalSize;

  void updateWithSpeed(double t, double speed) {
    if (toRemove) {
      return;
    }

    final increment = speed * 50 * t;
    x -= increment;

    if (!isVisible) {
      toRemove = true;
    }
  }

  double getGap(double gapCoefficient, double speed) {
    final minGap = (width * speed * type.minGap * gapCoefficient).round() / 1;
    final maxGap = (minGap * ObstacleConfig.maxGapCoefficient).round() / 1;
    return getRandomNum(minGap, maxGap);
  }

  @override
  bool remove() {
    return toRemove;
  }

  bool get isVisible => x + width > 0;

  void cloneCollisionBoxes() {
    final typeCollisionBoxes = type.collisionBoxes;

    for (final box in typeCollisionBoxes) {
      collisionBoxes
        ..add(
          CollisionBox(
            x: box.x,
            y: box.y,
            width: box.width,
            height: box.height,
          ),
        );
    }
  }
}
