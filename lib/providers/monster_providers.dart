import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../states/monster_state.dart';

/// 怪物狀態管理器
class MonsterStateNotifier extends StateNotifier<MonsterState> {
  MonsterStateNotifier() : super(MonsterState());

  /// 更新怪物動作
  void updateAction(MonsterAction action) {
    state = MonsterState(
      currentAction: action,
      health: state.health,
      isAlive: state.isAlive,
    );
  }

  /// 更新血量
  void updateHealth(double health) {
    final newHealth = health.clamp(0.0, MonsterState.defaultHealth);
    state = MonsterState(
      currentAction: state.currentAction,
      health: newHealth,
      isAlive: newHealth > 0,
    );
  }

  /// 設置存活狀態
  void setAlive(bool isAlive) {
    state = MonsterState(
      currentAction: state.currentAction,
      health: state.health,
      isAlive: isAlive,
    );
  }

  /// 受到傷害
  void takeDamage(double damage) {
    final newHealth = state.health - damage;
    updateHealth(newHealth);
    if (newHealth <= 0) {
      updateAction(MonsterAction.death);
    }
  }

  /// 治療
  void heal(double amount) {
    updateHealth(state.health + amount);
  }

  /// 重置怪物狀態
  void reset() {
    state = MonsterState();
  }

  /// 是否怪物死亡
  bool get isDead => !state.isAlive || state.health <= 0;

  /// 開始攻擊
  void startAttack() {
    updateAction(MonsterAction.attack);
  }

  /// 開始行走
  void startWalk() {
    updateAction(MonsterAction.walk);
  }

  /// 回到普通狀態
  void toNormal() {
    updateAction(MonsterAction.normal);
  }
}

/// 怪物狀態提供者
final monsterStateProvider = StateNotifierProvider<MonsterStateNotifier, MonsterState>((ref) {
  return MonsterStateNotifier();
});

/// 怪物是否存活的提供者
final monsterIsAliveProvider = Provider<bool>((ref) {
  return ref.watch(monsterStateProvider).isAlive;
});

/// 怪物血量的提供者
final monsterHealthProvider = Provider<double>((ref) {
  return ref.watch(monsterStateProvider).health;
});

/// 怪物是否死亡的提供者
final monsterIsDeadProvider = Provider<bool>((ref) {
  return ref.watch(monsterStateProvider.notifier).isDead;
});

/// 怪物當前動作的提供者
final monsterCurrentActionProvider = Provider<MonsterAction>((ref) {
  return ref.watch(monsterStateProvider).currentAction;
});

/// 怪物是否正在攻擊的提供者
final monsterIsAttackingProvider = Provider<bool>((ref) {
  return ref.watch(monsterStateProvider).currentAction == MonsterAction.attack;
}); 