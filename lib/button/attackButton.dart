import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter_game/manager/gamaManager.dart';

import '../game/start_game.dart';
import '../role/player.dart';

class AttackComponent extends SpriteComponent with Tappable {
  AttackComponent(Sprite sprite, Vector2 position)
      : super(
          position: position,
          size: Vector2(50, 50),
          anchor: Anchor.center,
          sprite: sprite,
        );

  @override
  bool onTapDown(TapDownInfo event) {

    GameManager.isAttack = true;
    StartGame.parallax.parallax?.baseVelocity = Vector2.zero();

    switch (StartGame.player.current) {
      case PlayerAction.ATTACK_ONE:
        GameManager.nextAttackStep = true;
        break;

      case PlayerAction.ATTACK_TWO:
        GameManager.nextAttackStep = true;
        break;

      case PlayerAction.ATTACK_THREE:
        GameManager.nextAttackStep = true;
        break;

      default:
        StartGame.player.current = PlayerAction.ATTACK_ONE;
        break;
    }

    return true;
  }
}
