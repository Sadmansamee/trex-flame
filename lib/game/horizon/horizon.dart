import 'dart:ui';


import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/position_component.dart';
import 'package:trex/game/game.dart';
import 'package:trex/game/horizon/horizon_line.dart';

class Horizon extends PositionComponent with HasGameRef<TRexGame> {

  Horizon(Image spriteImage) {
    horizonLine = HorizonLine(spriteImage);
    addChild(horizonLine);
  }

  HorizonLine horizonLine;

  @override
  void update(dt) {
    horizonLine.y = y;
    super.update(dt);
  }

  void updateWithSpeed(double t, double speed) {
    if (size == null) {
      return;
    }

    y = (size.y / 2) + 21.0;

    for ( final c in children ) {
      final positionComponent = c as PositionComponent;
      positionComponent.y = y;
    }

    horizonLine.updateWithSpeed(t, speed);
    super.update(t);
  }

  void reset() {
    horizonLine.reset();
  }
}
