import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../states/game_state.dart';
import '../states/player_state.dart';
import '../states/monster_state.dart';
import '../states/collision_state.dart';
import 'player_providers.dart';
import 'monster_providers.dart';
import 'collision_providers.dart';

/// 遊戲狀態管理器
class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(GameState());

  /// 重置整個遊戲狀態
  void resetGame() {
    state = GameState();
  }

  /// 更新遊戲狀態（通常由其他狀態管理器觸發）
  void updateFromSubStates(PlayerState player, MonsterState monster, CollisionState collision) {
    state = GameState(
      player: player,
      monster: monster,
      collision: collision,
    );
  }
}

/// 遊戲狀態提供者
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

/// 組合的遊戲狀態提供者 - 自動監聽所有子狀態的變化
final combinedGameStateProvider = Provider<GameState>((ref) {
  final player = ref.watch(playerStateProvider);
  final monster = ref.watch(monsterStateProvider);
  final collision = ref.watch(collisionStateProvider);
  
  return GameState(
    player: player,
    monster: monster,
    collision: collision,
  );
});

/// 遊戲是否暫停的提供者
final gameIsPausedProvider = StateProvider<bool>((ref) => false);

/// 遊戲分數的提供者
final gameScoreProvider = StateProvider<int>((ref) => 0);

/// 遊戲關卡的提供者
final gameLevelProvider = StateProvider<int>((ref) => 1);

/// 遊戲是否結束的提供者
final gameIsOverProvider = Provider<bool>((ref) {
  final playerIsDead = ref.watch(playerIsDeadProvider);
  return playerIsDead;
});

/// 遊戲是否勝利的提供者（怪物死亡且玩家存活）
final gameIsWonProvider = Provider<bool>((ref) {
  final monsterIsDead = ref.watch(monsterIsDeadProvider);
  final playerIsDead = ref.watch(playerIsDeadProvider);
  return monsterIsDead && !playerIsDead;
});

/// 遊戲狀態摘要提供者
final gameStatusSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final isOver = ref.watch(gameIsOverProvider);
  final isWon = ref.watch(gameIsWonProvider);
  final isPaused = ref.watch(gameIsPausedProvider);
  final score = ref.watch(gameScoreProvider);
  final level = ref.watch(gameLevelProvider);
  
  return {
    'isOver': isOver,
    'isWon': isWon,
    'isPaused': isPaused,
    'score': score,
    'level': level,
    'status': isOver 
        ? (isWon ? 'victory' : 'defeat')
        : (isPaused ? 'paused' : 'playing'),
  };
});

/// 遊戲操作提供者 - 提供常用的遊戲操作方法
final gameActionsProvider = Provider<GameActions>((ref) {
  return GameActions(ref);
});

/// 遊戲操作類
class GameActions {
  final Ref ref;
  
  GameActions(this.ref);

  /// 重新開始遊戲
  void restartGame() {
    ref.read(playerStateProvider.notifier).reset();
    ref.read(monsterStateProvider.notifier).reset();
    ref.read(collisionStateProvider.notifier).reset();
    ref.read(gameScoreProvider.notifier).state = 0;
    ref.read(gameLevelProvider.notifier).state = 1;
    ref.read(gameIsPausedProvider.notifier).state = false;
  }

  /// 暫停/恢復遊戲
  void togglePause() {
    final currentPause = ref.read(gameIsPausedProvider);
    ref.read(gameIsPausedProvider.notifier).state = !currentPause;
  }

  /// 增加分數
  void addScore(int points) {
    final currentScore = ref.read(gameScoreProvider);
    ref.read(gameScoreProvider.notifier).state = currentScore + points;
  }

  /// 下一關
  void nextLevel() {
    final currentLevel = ref.read(gameLevelProvider);
    ref.read(gameLevelProvider.notifier).state = currentLevel + 1;
    
    // 重置玩家和怪物狀態但保留分數
    ref.read(playerStateProvider.notifier).reset();
    ref.read(monsterStateProvider.notifier).reset();
    ref.read(collisionStateProvider.notifier).reset();
  }

  /// 玩家攻擊怪物
  void playerAttackMonster(double damage) {
    ref.read(monsterStateProvider.notifier).takeDamage(damage);
    if (ref.read(monsterIsDeadProvider)) {
      addScore(100); // 擊敗怪物獲得分數
    }
  }

  /// 怪物攻擊玩家
  void monsterAttackPlayer(int damage) {
    ref.read(playerStateProvider.notifier).takeDamage(damage);
  }
} 