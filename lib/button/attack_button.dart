import 'package:flame/components.dart';
import 'package:flame/input.dart';
import '../manager/game_manager.dart';
import '../role/adventurer.dart';
import '../states/player_state.dart';

/// 攻擊按鈕組件
class AttackButton extends SpriteComponent with Tappable {
  final GameManager gameManager;
  final Adventurer adventurer;
  final void Function() stopBackgroundScrolling;

  AttackButton({
    required this.gameManager,
    required this.adventurer,
    required this.stopBackgroundScrolling,
    required Sprite sprite,
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2(50, 50),
    anchor: Anchor.center,
    sprite: sprite,
  );

  @override
  bool onTapDown(TapDownInfo event) {
    try {
      gameManager.isAttack = true;
      stopBackgroundScrolling();

      switch (adventurer.current) {
        case AdventurerAction.swordAttack:
        case AdventurerAction.swordAttackTwo:
        case AdventurerAction.swordAttackThree:
          gameManager.nextAttackStep = true;
          break;
        default:
          adventurer.current = AdventurerAction.bowAttack;
          break;
      }
      
      return true;
    } catch (e) {
      print('攻擊按鈕處理錯誤: $e');
      return false;
    }
  }
}
