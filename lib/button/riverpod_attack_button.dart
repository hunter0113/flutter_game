import 'package:flame/components.dart';
import 'package:flame/input.dart';
import '../managers/riverpod_game_manager.dart';
import '../role/adventurer.dart';
import '../states/player_state.dart';

/// 使用 Riverpod 的攻擊按鈕組件
class RiverpodAttackButton extends SpriteComponent with Tappable {
  final RiverpodGameManager gameManager;
  final Adventurer adventurer;
  final void Function() stopBackgroundScrolling;
  final void Function(AdventurerAction)? onAttackStart;

  RiverpodAttackButton({
    required this.gameManager,
    required this.adventurer,
    required this.stopBackgroundScrolling,
    this.onAttackStart,
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
      // 使用 Riverpod 狀態管理設置攻擊狀態
      gameManager.setAttackState(true);
      stopBackgroundScrolling();

      AdventurerAction attackAction;
      final currentAction = adventurer.current ?? AdventurerAction.normal;

      switch (currentAction) {
        case AdventurerAction.swordAttack:
        case AdventurerAction.swordAttackTwo:
        case AdventurerAction.swordAttackThree:
          gameManager.nextAttackStep = true;
          attackAction = _getNextSwordAttack(currentAction);
          break;
        default:
          attackAction = AdventurerAction.bowAttack;
          break;
      }

      // 更新玩家動作狀態
      gameManager.setPlayerAction(attackAction);
      adventurer.current = attackAction;

      // 觸發攻擊開始回調
      if (onAttackStart != null) {
        onAttackStart!(attackAction);
      }
      
      return true;
    } catch (e) {
      print('Riverpod 攻擊按鈕處理錯誤: $e');
      return false;
    }
  }

  /// 獲取下一個劍攻擊動作
  AdventurerAction _getNextSwordAttack(AdventurerAction currentAction) {
    switch (currentAction) {
      case AdventurerAction.swordAttack:
        return AdventurerAction.swordAttackTwo;
      case AdventurerAction.swordAttackTwo:
        return AdventurerAction.swordAttackThree;
      case AdventurerAction.swordAttackThree:
        return AdventurerAction.swordAttack;
      default:
        return AdventurerAction.swordAttack;
    }
  }
} 