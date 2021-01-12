import 'dart:math';
import 'dart:ui';

import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/position_component.dart';
import 'package:flame/components/sprite_component.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/sprite.dart';
import 'package:trex/game/game.dart';
import 'package:trex/game/horizon/clouds.dart';
import 'package:trex/game/horizon/config.dart';
import 'package:trex/game/obstacle/obstacle.dart';

Random rnd = Random();

class HorizonLine extends PositionComponent with HasGameRef<TRexGame> {
  HorizonLine(Image spriteImage) {
    final softSprite = Sprite(
      spriteImage,
      srcSize: Vector2(
        HorizonDimensions.width,
        HorizonDimensions.height,
      ),
      srcPosition: Vector2(
        104.0,
        2.0,
      ),
    );

    final bumpySprite = Sprite(
      spriteImage,
      srcSize: Vector2(
        HorizonDimensions.width,
        HorizonDimensions.height,
      ),
      srcPosition: Vector2(
        104.0,
        2.0,
      ),
    );

    cloudManager = CloudManager(spriteImage);
    obstacleManager = ObstacleManager(spriteImage);
    firstGround = HorizonGround(softSprite);
    secondGround = HorizonGround(bumpySprite);
    thirdGround = HorizonGround(softSprite);

    
    this
      ..addChild(firstGround)
      ..addChild(secondGround)
      ..addChild(thirdGround)
      ..addChild(cloudManager)
      ..addChild(obstacleManager);
  }

  HorizonGround firstGround;
  HorizonGround secondGround;
  HorizonGround thirdGround;

  CloudManager cloudManager;
  ObstacleManager obstacleManager;

  final double bumpThreshold = 0.5;

  bool getRandomType() {
    return rnd.nextDouble() > bumpThreshold;
  }

  void updateXPos(int indexFirst, double increment) {
    final grounds = [firstGround, secondGround, thirdGround];

    final first = grounds[indexFirst];
    final second = grounds[(indexFirst + 1) % 3];
    final third = grounds[(indexFirst + 2) % 3];

    first.x -= increment;
    second.x = first.x + HorizonDimensions.width;
    third.x = second.x + HorizonDimensions.width;

    if (first.x <= -HorizonDimensions.width) {
      first.x += HorizonDimensions.width * 3;
    }
  }

  void updateWithSpeed(double t, double speed) {
    final increment = speed * 50 * t;
    final int index = firstGround.x <= 0
        ? 0
        : secondGround.x <= 0
            ? 1
            : 2;
    updateXPos(index, increment);

    cloudManager.updateWithSpeed(t, speed);
    obstacleManager.updateWithSpeed(t, speed);

    super.update(t);
  }

  @override
  void update(dt) {
    super.update(dt);
    for (final c in children) {
      final positionComponent = c as PositionComponent;
      positionComponent.y = y;
    }
  }

  void reset() {
    cloudManager.reset();
    obstacleManager.reset();

    firstGround.x = 0.0;
    secondGround.y = HorizonDimensions.width;
  }
}

class HorizonGround extends SpriteComponent {
  HorizonGround(Sprite sprite)
      : super.fromSprite(
          Vector2(
            HorizonDimensions.width,
            HorizonDimensions.height,
          ),
          sprite,
        );
}
