import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../states/player_state.dart';

/// 玩家狀態管理器，繼承 StateNotifier 來管理 PlayerState
class PlayerStateNotifier extends StateNotifier<PlayerState> {
  PlayerStateNotifier() : super(PlayerState());

  /// 更新玩家動作
  void updateAction(AdventurerAction action) {
    state = PlayerState(
      isAttacking: state.isAttacking,
      isMoving: state.isMoving,
      isFlipped: state.isFlipped,
      currentAction: action,
      health: state.health,
    );
  }

  /// 設置攻擊狀態
  void setAttacking(bool isAttacking) {
    state = PlayerState(
      isAttacking: isAttacking,
      isMoving: state.isMoving,
      isFlipped: state.isFlipped,
      currentAction: state.currentAction,
      health: state.health,
    );
  }

  /// 設置移動狀態
  void setMoving(bool isMoving) {
    state = PlayerState(
      isAttacking: state.isAttacking,
      isMoving: isMoving,
      isFlipped: state.isFlipped,
      currentAction: state.currentAction,
      health: state.health,
    );
  }

  /// 設置翻轉狀態
  void setFlipped(bool isFlipped) {
    state = PlayerState(
      isAttacking: state.isAttacking,
      isMoving: state.isMoving,
      isFlipped: isFlipped,
      currentAction: state.currentAction,
      health: state.health,
    );
  }

  /// 更新血量
  void updateHealth(int health) {
    state = PlayerState(
      isAttacking: state.isAttacking,
      isMoving: state.isMoving,
      isFlipped: state.isFlipped,
      currentAction: state.currentAction,
      health: health.clamp(0, PlayerState.defaultHealth),
    );
  }

  /// 受到傷害
  void takeDamage(int damage) {
    updateHealth(state.health - damage);
  }

  /// 治療
  void heal(int amount) {
    updateHealth(state.health + amount);
  }

  /// 重置玩家狀態
  void reset() {
    state = PlayerState();
  }

  /// 是否玩家死亡
  bool get isDead => state.health <= 0;

  /// 是否玩家健康
  bool get isHealthy => state.health == PlayerState.defaultHealth;
}

/// 玩家狀態提供者
final playerStateProvider = StateNotifierProvider<PlayerStateNotifier, PlayerState>((ref) {
  return PlayerStateNotifier();
});

/// 玩家是否正在攻擊的提供者（用於快速存取）
final playerIsAttackingProvider = Provider<bool>((ref) {
  return ref.watch(playerStateProvider).isAttacking;
});

/// 玩家是否正在移動的提供者
final playerIsMovingProvider = Provider<bool>((ref) {
  return ref.watch(playerStateProvider).isMoving;
});

/// 玩家當前動作的提供者
final playerCurrentActionProvider = Provider<AdventurerAction>((ref) {
  return ref.watch(playerStateProvider).currentAction;
});

/// 玩家血量的提供者
final playerHealthProvider = Provider<int>((ref) {
  return ref.watch(playerStateProvider).health;
});

/// 玩家是否死亡的提供者
final playerIsDeadProvider = Provider<bool>((ref) {
  return ref.watch(playerStateProvider.notifier).isDead;
}); 