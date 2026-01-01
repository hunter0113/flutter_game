import 'package:flame/components.dart';
import '../manager/game_manager.dart';
import '../manager/input_manager.dart';
import '../role/adventurer.dart';
import '../role/monster.dart';
import '../states/monster_state.dart';
import '../states/player_state.dart';
import '../constants/game_constants.dart';
import '../components/arrow.dart';

/// 負責遊戲主循環邏輯的控制器
class GameLoopController {
  final GameManager gameManager;
  final InputManager inputManager;
  final Function(Vector2) updateParallaxVelocity;
  final Function() getGameSize;
  final Iterable<T> Function<T extends Component>() getChildrenOfType;

  GameLoopController({
    required this.gameManager,
    required this.inputManager,
    required this.updateParallaxVelocity,
    required this.getGameSize,
    required this.getChildrenOfType,
  });

  /// 處理玩家移動邏輯
  void handlePlayerMovement(double dt, Adventurer adventurer) {
    if (gameManager.isAttack) {
      return;
    }

    final joystickDelta = inputManager.joystick.relativeDelta;
    
    if (joystickDelta.isZero()) {
      adventurer.current = AdventurerAction.normal;
      updateParallaxVelocity(Vector2.zero());
      return;
    }

    final moveLeft = joystickDelta[0] < 0;
    final moveRight = joystickDelta[0] > 0;
    final playerVectorX = (joystickDelta * (GameConstants.player.speed * 1.2) * dt)[0];
    
    _executePlayerMovement(adventurer, playerVectorX, moveLeft, moveRight);
  }

  /// 執行具體的玩家移動
  void _executePlayerMovement(Adventurer adventurer, double playerVectorX, bool moveLeft, bool moveRight) {
    adventurer.current = AdventurerAction.run;

    // 更新朝向
    if (moveRight) {
      adventurer.isFlipped = false;
    } else if (moveLeft) {
      adventurer.isFlipped = true;
    }

    final gameSize = getGameSize();
    
    // 處理位置移動
    if (moveLeft && adventurer.x > 0 && !gameManager.isLeftCollisionBlock) {
      adventurer.position.add(Vector2(playerVectorX, 0));
    }

    if (moveRight && adventurer.x < gameSize[0] && !gameManager.isRightCollisionBlock) {
      adventurer.position.add(Vector2(playerVectorX, 0));
    }

    // 處理角色翻轉
    _handleCharacterFlipping(adventurer, moveLeft, moveRight);

    // 更新背景滾動
    _updateBackgroundScrolling(moveLeft, moveRight);
  }

  /// 處理角色翻轉邏輯
  void _handleCharacterFlipping(Adventurer adventurer, bool moveLeft, bool moveRight) {
    if (moveRight && gameManager.adventurerFlipped) {
      gameManager.adventurerFlipped = false;
      adventurer.flipHorizontallyAroundCenter();
    }

    if (moveLeft && !gameManager.adventurerFlipped) {
      gameManager.adventurerFlipped = true;
      adventurer.flipHorizontallyAroundCenter();
    }
  }

  /// 更新背景滾動
  void _updateBackgroundScrolling(bool moveLeft, bool moveRight) {
    if (moveRight && !gameManager.isRightCollisionBlock) {
      updateParallaxVelocity(Vector2(GameConstants.settings.backgroundBaseVelocity, 0));
    } else if (moveLeft && !gameManager.isLeftCollisionBlock) {
      updateParallaxVelocity(Vector2(-GameConstants.settings.backgroundBaseVelocity, 0));
    } else {
      updateParallaxVelocity(Vector2.zero());
    }
  }

  /// 處理攻擊邏輯
  void handleAttackSequence(Adventurer adventurer) {
    if (!gameManager.isAttack || !adventurer.animation!.done()) {
      return;
    }

    adventurer.animation!.reset();

    if (gameManager.nextAttackStep) {
      _processNextAttackStep(adventurer);
      gameManager.nextAttackStep = false;
      return;
    }

    gameManager.isAttack = false;
  }

  /// 處理攻擊序列的下一步
  void _processNextAttackStep(Adventurer adventurer) {
    switch (adventurer.current) {
      case AdventurerAction.swordAttack:
        adventurer.current = AdventurerAction.swordAttackTwo;
        break;
      case AdventurerAction.swordAttackTwo:
        adventurer.current = AdventurerAction.swordAttackThree;
        break;
      case AdventurerAction.swordAttackThree:
        adventurer.current = AdventurerAction.swordAttack;
        break;
      default:
        adventurer.current = AdventurerAction.swordAttack;
        break;
    }
  }

  /// 處理怪物相關邏輯
  void handleMonsterLogic(Monster monster) {
    // 檢查怪物死亡
    if (monster.current == MonsterAction.death && monster.animation!.done()) {
      monster.removeFromParent();
      return;
    }

    // 處理怪物存活時的邏輯
    if (monster.life > 0) {
      _processArrowCollisions(monster);
    }
  }

  /// 處理箭矢碰撞
  void _processArrowCollisions(Monster monster) {
    final arrows = getChildrenOfType<Arrow>();
    
    for (final arrow in arrows) {
      if (arrow.isRemoving) {
        continue;
      }

      if (!monster.containsPoint(arrow.absoluteCenter)) {
        continue;
      }
      
      arrow.removeFromParent();
      monster.loss(GameConstants.monster.arrowDamage);
    }
  }
} 