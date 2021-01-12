import 'dart:ui';

import 'package:flame/components/position_component.dart';
import 'package:flame/components/sprite_animation_component.dart';
import 'package:flame/components/sprite_component.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/sprite.dart';
import 'package:flame/sprite_animation.dart';
import 'package:trex/game/t_rex/config.dart';

enum TRexStatus { crashed, ducking, jumping, running, waiting, intro }

class TRex extends PositionComponent {
  TRex(Image spriteImage)
      : runningTRex = RunningTRex(spriteImage),
        idleTRex = WaitingTRex(spriteImage),
        jumpingTRex = JumpingTRex(spriteImage),
        surprisedTRex = SurprisedTRex(spriteImage),
        super();

  bool isIdle = true;

  TRexStatus status = TRexStatus.waiting;
  Vector2 gameSize = Vector2.zero();

  WaitingTRex idleTRex;
  RunningTRex runningTRex;
  JumpingTRex jumpingTRex;
  SurprisedTRex surprisedTRex;

  double jumpVelocity = 0.0;
  bool reachedMinHeight = false;
  int jumpCount = 0;
  bool hasPlayedIntro = false;

  PositionComponent get actualDino {
    switch (status) {
      case TRexStatus.waiting:
        return idleTRex;
      case TRexStatus.jumping:
        return jumpingTRex;
      case TRexStatus.crashed:
        return surprisedTRex;
      case TRexStatus.intro:
      case TRexStatus.running:
      default:
        return runningTRex;
    }
  }

  void startJump(double speed) {
    if (status == TRexStatus.jumping || status == TRexStatus.ducking) {
      return;
    }

    status = TRexStatus.jumping;
    jumpVelocity = TRexConfig.initialJumpVelocity - (speed / 10);

    reachedMinHeight = false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    actualDino.render(canvas);
  }

  void reset() {
    y = groundYPos;
    jumpVelocity = 0.0;
    jumpCount = 0;
    status = TRexStatus.running;
  }

  @override
  void update(dt) {
    super.update(dt);
    if (status == TRexStatus.jumping) {
      y += jumpVelocity;
      jumpVelocity += TRexConfig.gravity;
      if (y > groundYPos) {
        reset();
        jumpCount++;
      }
    } else {
      y = groundYPos;
    }

    // intro related
    if (jumpCount == 1 && !playingIntro && !hasPlayedIntro) {
      status = TRexStatus.intro;
    }
    if (playingIntro && x < TRexConfig.startXPos) {
      x += (TRexConfig.startXPos / TRexConfig.introDuration) * dt * 5000;
    }
    actualDino.update(dt);
  }

  double get groundYPos {
    if (gameSize == null) {
      return null;
    }
    return (gameSize.y / 2) - TRexConfig.height / 2;
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    this.gameSize = gameSize;
  }

  bool get playingIntro => status == TRexStatus.intro;

  bool get ducking => status == TRexStatus.ducking;
}

class RunningTRex extends SpriteAnimationComponent {
  RunningTRex(Image spriteImage)
      : super(
          Vector2(
            88.0,
            90.0,
          ),
          SpriteAnimation.spriteList(
            [
              Sprite(
                spriteImage,
                srcSize: Vector2(TRexConfig.width, TRexConfig.height),
                srcPosition: Vector2(4.0, 1514.0),
              ),
              Sprite(
                spriteImage,
                srcSize: Vector2(TRexConfig.width, TRexConfig.height),
                srcPosition: Vector2(4.0, 1602.0),
              ),
            ],
            stepTime: 0.2,
            loop: true,
          ),
        );
}

class WaitingTRex extends SpriteComponent {
  WaitingTRex(Image spriteImage)
      : super.fromSprite(
          Vector2(TRexConfig.width, TRexConfig.height),
          Sprite(
            spriteImage,
            srcSize: Vector2(TRexConfig.width, TRexConfig.height),
            srcPosition: Vector2(76.0, 6.0),
          ),
        );
}

class JumpingTRex extends SpriteComponent {
  JumpingTRex(Image spriteImage)
      : super.fromSprite(
          Vector2(TRexConfig.width, TRexConfig.height),
          Sprite(
            spriteImage,
            srcSize: Vector2(TRexConfig.width, TRexConfig.height),
            srcPosition: Vector2(1339.0, 6.0),
          ),
        );
}

class SurprisedTRex extends SpriteComponent {
  SurprisedTRex(Image spriteImage)
      : super.fromSprite(
          Vector2(TRexConfig.width, TRexConfig.height),
          Sprite(
            spriteImage,
            srcSize: Vector2(TRexConfig.width, TRexConfig.height),
            srcPosition: Vector2(1782.0, 6.0),
          ),
        );
}
