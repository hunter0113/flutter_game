import 'package:flame/components.dart';
import 'package:flame/input.dart';
import '../manager/game_manager.dart';
import '../game/start_game.dart';
import '../states/player_state.dart';

class AttackButton extends SpriteComponent with Tappable {
  final GameManager gameManager;

  AttackButton(this.gameManager, Sprite sprite, Vector2 position)
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
      case AdventurerAction.swordAttack:
        gameManager.nextAttackStep = true;
        break;
      case AdventurerAction.swordAttackTwo:
        gameManager.nextAttackStep = true;
        break;
      case AdventurerAction.swordAttackThree:
        gameManager.nextAttackStep = true;
        break;
      default:
        StartGame.adventurer.current = AdventurerAction.bowAttack;
        break;
    }
    return true;
  }
}
