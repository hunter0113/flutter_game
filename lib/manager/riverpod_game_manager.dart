import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../states/player_state.dart';
import '../states/monster_state.dart';
import '../interfaces/game_manager_interface.dart';

/// 使用 Riverpod 的遊戲管理器
/// 這個類替代了舊的 GameManager，使用 Riverpod 提供者來管理狀態
class RiverpodGameManager implements IGameManager {
  final ProviderContainer container;
  final double screenWidth;
  final double screenHeight;

  // 角色動畫（保持現有結構）
  late final SpriteAnimation normalAnimation;
  late final SpriteAnimation bowAttackAni;
  late final SpriteAnimation swordAttackAni_One;
  late final SpriteAnimation swordAttackAni_Two;
  late final SpriteAnimation swordAttackAni_Three;
  late final SpriteAnimation runAnimation;

  // 怪物動畫
  late final SpriteAnimation monsterWalk;
  late final SpriteAnimation monsterNormal;
  late final SpriteAnimation monsterAttack;
  late final SpriteAnimation monsterDeath;

  // 背景與x座標軸上的速度
  final Map<String, double> bgLayerInfo = {
    'background_11.png': 0.5,
    'background_10.png': 0.75,
    'background_9.png': 1.0,
    'background_8.png': 1.25,
    'background_7.png': 1.5,
    'background_6.png': 1.75,
    'background_5.png': 2.0,
    'background_4.png': 2.25,
    'background_3.png': 2.5,
    'background_2.png': 2.75,
    'background_1.png': 3.0,
    'background_0.png': 3.25,
  };

  RiverpodGameManager({required this.container})
      : screenWidth = MediaQueryData.fromView(window).size.width,
        screenHeight = MediaQueryData.fromView(window).size.height;

  // === Riverpod 狀態存取方法 ===

  /// 獲取當前玩家狀態
  PlayerState get playerState => container.read(playerStateProvider);

  /// 獲取當前怪物狀態
  MonsterState get monsterState => container.read(monsterStateProvider);

  /// 獲取遊戲操作實例
  GameActions get gameActions => container.read(gameActionsProvider);

  // === 便利屬性（為了向後兼容） ===

  /// 是否正在攻擊
  bool get isAttack => container.read(playerIsAttackingProvider);
  set isAttack(bool value) => container.read(playerStateProvider.notifier).setAttacking(value);

  /// 冒險者是否翻轉
  bool get adventurerFlipped => container.read(playerStateProvider).isFlipped;
  set adventurerFlipped(bool value) => container.read(playerStateProvider.notifier).setFlipped(value);

  /// 下一攻擊步驟（從舊邏輯遷移）
  bool get nextAttackStep => _nextAttackStep;
  set nextAttackStep(bool value) => _nextAttackStep = value;
  bool _nextAttackStep = false;

  /// 左側碰撞阻擋
  bool get isLeftCollisionBlock => container.read(isLeftBlockedProvider);

  /// 右側碰撞阻擋
  bool get isRightCollisionBlock => container.read(isRightBlockedProvider);

  // === 狀態更新方法（使用 Riverpod） ===

  /// 更新玩家狀態
  void updatePlayerState({
    bool? isAttacking,
    bool? isMoving,
    bool? isFlipped,
    AdventurerAction? currentAction,
    int? health,
  }) {
    final notifier = container.read(playerStateProvider.notifier);
    
    if (isAttacking != null) {
      notifier.setAttacking(isAttacking);
    }
    if (isMoving != null) {
      notifier.setMoving(isMoving);
    }
    if (isFlipped != null) {
      notifier.setFlipped(isFlipped);
    }
    if (currentAction != null) {
      notifier.updateAction(currentAction);
    }
    if (health != null) {
      notifier.updateHealth(health);
    }
  }

  /// 更新怪物狀態
  void updateMonsterState({
    MonsterAction? currentAction,
    double? health,
    bool? isAlive,
  }) {
    final notifier = container.read(monsterStateProvider.notifier);
    
    if (currentAction != null) {
      notifier.updateAction(currentAction);
    }
    if (health != null) {
      notifier.updateHealth(health);
    }
    if (isAlive != null) {
      notifier.setAlive(isAlive);
    }
  }

  /// 更新碰撞狀態
  void updateCollisionState({
    bool? isLeftBlocked,
    bool? isRightBlocked,
    bool? isTopBlocked,
    bool? isBottomBlocked,
  }) {
    final notifier = container.read(collisionStateProvider.notifier);
    
    if (isLeftBlocked != null) {
      notifier.setLeftBlocked(isLeftBlocked);
    }
    if (isRightBlocked != null) {
      notifier.setRightBlocked(isRightBlocked);
    }
    if (isTopBlocked != null) {
      notifier.setTopBlocked(isTopBlocked);
    }
    if (isBottomBlocked != null) {
      notifier.setBottomBlocked(isBottomBlocked);
    }
  }

  // === 高級遊戲操作 ===

  /// 玩家受到傷害
  void playerTakeDamage(int damage) {
    container.read(playerStateProvider.notifier).takeDamage(damage);
  }

  /// 玩家治療
  void playerHeal(int amount) {
    container.read(playerStateProvider.notifier).heal(amount);
  }

  /// 怪物受到傷害
  void monsterTakeDamage(double damage) {
    container.read(monsterStateProvider.notifier).takeDamage(damage);
  }

  /// 設置攻擊狀態
  void setAttackState(bool isAttacking) {
    container.read(playerStateProvider.notifier).setAttacking(isAttacking);
  }

  /// 設置玩家動作
  void setPlayerAction(AdventurerAction action) {
    container.read(playerStateProvider.notifier).updateAction(action);
  }

  /// 設置怪物動作
  void setMonsterAction(MonsterAction action) {
    container.read(monsterStateProvider.notifier).updateAction(action);
  }

  /// 重置遊戲狀態
  void resetGame() {
    container.read(gameActionsProvider).restartGame();
    _nextAttackStep = false;
  }

  /// 增加分數
  void addScore(int points) {
    container.read(gameActionsProvider).addScore(points);
  }

  /// 檢查遊戲是否結束
  bool get isGameOver => container.read(gameIsOverProvider);

  /// 檢查是否獲勝
  bool get isGameWon => container.read(gameIsWonProvider);

  /// 設置遊戲暫停狀態
  void setPaused(bool isPaused) {
    container.read(gameIsPausedProvider.notifier).state = isPaused;
  }

  // === 監聽狀態變化 ===

  /// 監聽玩家血量變化
  void listenToPlayerHealth(void Function(int? previous, int next) callback) {
    container.listen(playerHealthProvider, callback);
  }

  /// 監聽怪物死亡
  void listenToMonsterDeath(void Function(bool? previous, bool next) callback) {
    container.listen(monsterIsDeadProvider, callback);
  }

  /// 監聽遊戲結束
  void listenToGameOver(void Function(bool? previous, bool next) callback) {
    container.listen(gameIsOverProvider, callback);
  }

  /// 獲取遊戲狀態摘要
  Map<String, dynamic> get gameStatusSummary => container.read(gameStatusSummaryProvider);

  /// 打印當前遊戲狀態（用於調試）
  void debugPrintGameState() {
    final playerState = container.read(playerStateProvider);
    final monsterState = container.read(monsterStateProvider);
    final gameStatus = container.read(gameStatusSummaryProvider);
    
    print('=== 遊戲狀態 ===');
    print('玩家血量: ${playerState.health}');
    print('玩家動作: ${playerState.currentAction}');
    print('怪物血量: ${monsterState.health}');
    print('怪物動作: ${monsterState.currentAction}');
    print('遊戲狀態: ${gameStatus['status']}');
    print('分數: ${gameStatus['score']}');
    print('關卡: ${gameStatus['level']}');
    print('===============');
  }
} 