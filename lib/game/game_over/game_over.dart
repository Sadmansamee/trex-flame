import 'dart:ui';

import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/position_component.dart';
import 'package:flame/components/sprite_component.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/sprite.dart';
import 'package:trex/game/game_over/config.dart';

import '../game.dart';

class GameOverPanel extends PositionComponent with HasGameRef<TRexGame>  {
  GameOverPanel(Image spriteImage) : super() {
    gameOverText = GameOverText(spriteImage);
    gameOverRestart = GameOverRestart(spriteImage);

    addChild(gameOverText);
    addChild(gameOverRestart);
  }

  bool visible = false;

  GameOverText gameOverText;
  GameOverRestart gameOverRestart;

  @override
  void render(Canvas canvas) {
    if (visible) {
      super.render(canvas);
    }
  }
}

class GameOverText extends SpriteComponent {
  GameOverText(Image spriteImage)
      : super.fromSprite(
          Vector2(
            GameOverConfig.textWidth,
            GameOverConfig.textHeight,
          ),
          Sprite(
            spriteImage,
            srcPosition: Vector2(955.0, 26.0),
            srcSize: Vector2(
              GameOverConfig.textWidth,
              GameOverConfig.textHeight,
            ),
          ),
        );

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    if (width > gameSize.y * 0.8) {
      width = gameSize.x * 0.8;
    }
    y = gameSize.y * .25;
    x = (gameSize.x / 2) - width / 2;
  }

}

class GameOverRestart extends SpriteComponent {
  GameOverRestart(Image spriteImage)
      : super.fromSprite(
          Vector2(
            GameOverConfig.textWidth,
            GameOverConfig.textHeight,
          ),
          Sprite(
            spriteImage,
            srcPosition: Vector2(2.0, 2.0),
            srcSize: Vector2(
              GameOverConfig.restartWidth,
              GameOverConfig.restartHeight,
            ),
          ),
        );

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    y = gameSize.y * .75;
    x = (gameSize.x / 2) - GameOverConfig.restartWidth / 2;
  }

}
