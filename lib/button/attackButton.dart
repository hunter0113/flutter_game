import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter_game/manager/gamaManager.dart';

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
    GameManager.parallax.parallax?.baseVelocity = Vector2.zero();

    switch (GameManager.player.current) {
      case PlayerAction.Attack_One:
        GameManager.nextAttackStep = true;
        break;

      case PlayerAction.Attack_Two:
        GameManager.nextAttackStep = true;
        break;

      case PlayerAction.Attack_Three:
        GameManager.nextAttackStep = true;
        break;

      default:
        GameManager.player.current = PlayerAction.Attack_One;
        break;
    }

    return true;
  }
}
