import 'package:flame/components.dart';
import 'package:flame/input.dart';
import '../manager/gamaManager.dart';
import '../game/start_game.dart';
import '../role/adventurer.dart';

class AttackComponent extends SpriteComponent with Tappable {
  final GameAnimationManager gameManager;

  AttackComponent(this.gameManager, Sprite sprite, Vector2 position)
      : super(
    position: position,
    size: Vector2(50, 50),
    anchor: Anchor.center,
    sprite: sprite,
  );

  @override
  bool onTapDown(TapDownInfo event) {
    gameManager.isAttack = true;
    StartGame.parallax.parallax?.baseVelocity = Vector2.zero();

    switch (StartGame.adventurer.current) {
      case AdventurerAction.SWORD_ATTACK_ONE:
        gameManager.nextAttackStep = true;
        break;
      case AdventurerAction.SWORD_ATTACK_TWO:
        gameManager.nextAttackStep = true;
        break;
      case AdventurerAction.SWORD_ATTACK_THREE:
        gameManager.nextAttackStep = true;
        break;
      default:
        StartGame.adventurer.current = AdventurerAction.BOW_ATTACK;
        break;
    }
    return true;
  }
}
