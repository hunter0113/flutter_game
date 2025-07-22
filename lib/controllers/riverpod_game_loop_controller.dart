import 'package:flame/components.dart';
import '../managers/riverpod_game_manager.dart';
import '../manager/riverpod_input_manager.dart';
import '../role/adventurer.dart';
import '../role/monster.dart';
import '../states/monster_state.dart';
import '../states/player_state.dart';
import '../constants/game_constants.dart';
import '../components/arrow.dart';

/// 使用 Riverpod 的遊戲循環控制器
/// 替代舊的 GameLoopController，完全基於 Riverpod 狀態管理
class RiverpodGameLoopController {
  final RiverpodGameManager gameManager;
  final RiverpodInputManager inputManager;
  final Function(Vector2) updateParallaxVelocity;
  final Function() getGameSize;
  final Iterable<T> Function<T extends Component>() getChildrenOfType;

  RiverpodGameLoopController({
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
      gameManager.setPlayerAction(AdventurerAction.normal);
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
    // 更新狀態：設為跑步狀態
    gameManager.setPlayerAction(AdventurerAction.run);
    gameManager.updatePlayerState(isMoving: true);

    // 更新朝向
    if (moveRight) {
      adventurer.isFlipped = false;
      gameManager.updatePlayerState(isFlipped: false);
    } else if (moveLeft) {
      adventurer.isFlipped = true;
      gameManager.updatePlayerState(isFlipped: true);
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
      adventurer.flipHorizontallyAroundCenter();
    }

    if (moveLeft && !gameManager.adventurerFlipped) {
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

    // 攻擊結束，更新狀態
    gameManager.setAttackState(false);
    gameManager.updatePlayerState(isAttacking: false);
  }

  /// 處理攻擊序列的下一步
  void _processNextAttackStep(Adventurer adventurer) {
    AdventurerAction nextAction;
    
    switch (adventurer.current) {
      case AdventurerAction.swordAttack:
        nextAction = AdventurerAction.swordAttackTwo;
        break;
      case AdventurerAction.swordAttackTwo:
        nextAction = AdventurerAction.swordAttackThree;
        break;
      case AdventurerAction.swordAttackThree:
        nextAction = AdventurerAction.swordAttack;
        break;
      default:
        nextAction = AdventurerAction.swordAttack;
        break;
    }
    
    adventurer.current = nextAction;
    gameManager.setPlayerAction(nextAction);
  }

  /// 處理怪物相關邏輯
  void handleMonsterLogic(Monster monster) {
    // 檢查怪物死亡
    if (monster.current == MonsterAction.death && monster.animation!.done()) {
      monster.removeFromParent();
      
      // 更新狀態：怪物已死亡
      gameManager.updateMonsterState(isAlive: false);
      
      // 增加分數
      gameManager.addScore(100);
      return;
    }

    // 處理怪物存活時的邏輯
    if (monster.life > 0) {
      _processArrowCollisions(monster);
      _updateMonsterAI(monster);
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
      
      // 使用 Riverpod 狀態管理來處理傷害
      final damage = GameConstants.monster.arrowDamage;
      gameManager.monsterTakeDamage(damage);
      
      // 如果怪物死亡，觸發死亡動畫
      if (gameManager.monsterState.health <= 0) {
        monster.current = MonsterAction.death;
        gameManager.setMonsterAction(MonsterAction.death);
      }
    }
  }

  /// 更新怪物 AI 邏輯
  void _updateMonsterAI(Monster monster) {
    // 簡單的 AI：如果玩家靠近，怪物會攻擊
    // final playerState = gameManager.playerState;
    
    // 這裡可以根據需要添加更複雜的 AI 邏輯
    // 例如：追蹤玩家、攻擊模式等
    
    // 示例：如果玩家在攻擊距離內，怪物開始攻擊
    // final distanceToPlayer = calculateDistanceToPlayer(monster);
    // if (distanceToPlayer < GameConstants.monster.attackRange) {
    //   gameManager.setMonsterAction(MonsterAction.attack);
    // }
  }

  /// 開始玩家攻擊
  void startPlayerAttack(AdventurerAction attackType) {
    gameManager.setAttackState(true);
    gameManager.updatePlayerState(isAttacking: true);
    gameManager.setPlayerAction(attackType);
  }

  /// 處理玩家受傷
  void handlePlayerDamage(int damage) {
    gameManager.playerTakeDamage(damage);
    
    // 檢查玩家是否死亡
    if (gameManager.playerState.health <= 0) {
      _handlePlayerDeath();
    }
  }

  /// 處理玩家死亡
  void _handlePlayerDeath() {
    print('玩家死亡！遊戲結束。');
    gameManager.gameActions.restartGame(); // 或者觸發遊戲結束畫面
  }

  /// 處理怪物攻擊玩家
  void handleMonsterAttackPlayer(int damage) {
    gameManager.gameActions.monsterAttackPlayer(damage);
    
    // 檢查玩家是否死亡
    if (gameManager.playerState.health <= 0) {
      _handlePlayerDeath();
    }
  }

  /// 設置碰撞狀態
  void setCollisionState({
    bool? left,
    bool? right,
    bool? top,
    bool? bottom,
  }) {
    gameManager.updateCollisionState(
      isLeftBlocked: left,
      isRightBlocked: right,
      isTopBlocked: top,
      isBottomBlocked: bottom,
    );
  }

  /// 處理關卡完成
  void handleLevelComplete() {
    gameManager.gameActions.nextLevel();
    print('關卡完成！進入下一關。');
  }

  /// 切換遊戲暫停狀態
  void togglePause() {
    gameManager.gameActions.togglePause();
  }

  /// 重新開始遊戲
  void restartGame() {
    gameManager.resetGame();
  }

  /// 獲取當前遊戲狀態摘要
  Map<String, dynamic> getGameStatus() {
    return gameManager.gameStatusSummary;
  }

  /// 調試方法：打印當前狀態
  void debugPrintStatus() {
    gameManager.debugPrintGameState();
  }

  /// 檢查玩家是否可以移動
  bool canPlayerMove(Vector2 direction) {
    if (direction.x < 0 && gameManager.isLeftCollisionBlock) {
      return false;
    }
    if (direction.x > 0 && gameManager.isRightCollisionBlock) {
      return false;
    }
    return true;
  }

  /// 處理特殊事件（例如撿取道具、觸發機關等）
  void handleSpecialEvent(String eventType, Map<String, dynamic> eventData) {
    switch (eventType) {
      case 'pickup_health':
        final healAmount = eventData['amount'] as int? ?? 20;
        gameManager.playerHeal(healAmount);
        break;
      case 'pickup_score':
        final scoreAmount = eventData['amount'] as int? ?? 50;
        gameManager.addScore(scoreAmount);
        break;
      case 'trigger_trap':
        final damage = eventData['damage'] as int? ?? 10;
        handlePlayerDamage(damage);
        break;
      default:
        print('未知事件類型: $eventType');
    }
  }
} 