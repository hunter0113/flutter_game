import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../states/player_state.dart';
import '../states/monster_state.dart';

/// Riverpod 使用範例
/// 這個文件展示了如何在 Flutter Widget 中使用 Riverpod 狀態管理
class RiverpodUsageExample extends ConsumerWidget {
  const RiverpodUsageExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod 狀態管理範例'),
      ),
      body: Column(
        children: [
          // 玩家狀態區域
          _PlayerStatusWidget(),
          const Divider(),
          
          // 怪物狀態區域
          _MonsterStatusWidget(),
          const Divider(),
          
          // 遊戲狀態區域
          _GameStatusWidget(),
          const Divider(),
          
          // 碰撞狀態區域
          _CollisionStatusWidget(),
          const Divider(),
          
          // 遊戲操作區域
          _GameActionsWidget(),
        ],
      ),
    );
  }
}

/// 玩家狀態顯示組件
class _PlayerStatusWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 監聽玩家狀態
    final playerState = ref.watch(playerStateProvider);
    final playerHealth = ref.watch(playerHealthProvider);
    final playerIsDead = ref.watch(playerIsDeadProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('玩家狀態', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('血量: $playerHealth / ${PlayerState.defaultHealth}'),
            Text('動作: ${playerState.currentAction.name}'),
            Text('攻擊中: ${playerState.isAttacking ? "是" : "否"}'),
            Text('移動中: ${playerState.isMoving ? "是" : "否"}'),
            Text('翻轉: ${playerState.isFlipped ? "是" : "否"}'),
            Text('狀態: ${playerIsDead ? "死亡" : "存活"}', 
                 style: TextStyle(color: playerIsDead ? Colors.red : Colors.green)),
            
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    ref.read(playerStateProvider.notifier).takeDamage(10);
                  },
                  child: const Text('受傷 -10'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    ref.read(playerStateProvider.notifier).heal(20);
                  },
                  child: const Text('治療 +20'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    ref.read(playerStateProvider.notifier).setAttacking(!playerState.isAttacking);
                  },
                  child: Text(playerState.isAttacking ? '停止攻擊' : '開始攻擊'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 怪物狀態顯示組件
class _MonsterStatusWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monsterState = ref.watch(monsterStateProvider);
    final monsterHealth = ref.watch(monsterHealthProvider);
    final monsterIsDead = ref.watch(monsterIsDeadProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('怪物狀態', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('血量: ${monsterHealth.toStringAsFixed(1)} / ${MonsterState.defaultHealth}'),
            Text('動作: ${monsterState.currentAction.name}'),
            Text('存活: ${monsterState.isAlive ? "是" : "否"}'),
            Text('狀態: ${monsterIsDead ? "死亡" : "存活"}', 
                 style: TextStyle(color: monsterIsDead ? Colors.red : Colors.green)),
            
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    ref.read(monsterStateProvider.notifier).takeDamage(15.0);
                  },
                  child: const Text('攻擊怪物 -15'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    ref.read(monsterStateProvider.notifier).startAttack();
                  },
                  child: const Text('怪物攻擊'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    ref.read(monsterStateProvider.notifier).startWalk();
                  },
                  child: const Text('怪物行走'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 遊戲狀態顯示組件
class _GameStatusWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameStatus = ref.watch(gameStatusSummaryProvider);
    final score = ref.watch(gameScoreProvider);
    final level = ref.watch(gameLevelProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('遊戲狀態', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('分數: $score'),
            Text('關卡: $level'),
            Text('狀態: ${gameStatus['status']}'),
            Text('是否結束: ${gameStatus['isOver'] ? "是" : "否"}'),
            Text('是否勝利: ${gameStatus['isWon'] ? "是" : "否"}'),
            Text('是否暫停: ${gameStatus['isPaused'] ? "是" : "否"}'),
          ],
        ),
      ),
    );
  }
}

/// 碰撞狀態顯示組件
class _CollisionStatusWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collisionState = ref.watch(collisionStateProvider);
    final hasAnyCollision = ref.watch(hasAnyCollisionProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('碰撞狀態', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('左側阻擋: ${collisionState.isLeftBlocked ? "是" : "否"}'),
            Text('右側阻擋: ${collisionState.isRightBlocked ? "是" : "否"}'),
            Text('上方阻擋: ${collisionState.isTopBlocked ? "是" : "否"}'),
            Text('下方阻擋: ${collisionState.isBottomBlocked ? "是" : "否"}'),
            Text('有碰撞: ${hasAnyCollision ? "是" : "否"}'),
            
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ref.read(collisionStateProvider.notifier).setLeftBlocked(!collisionState.isLeftBlocked);
                  },
                  child: const Text('切換左側'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(collisionStateProvider.notifier).setRightBlocked(!collisionState.isRightBlocked);
                  },
                  child: const Text('切換右側'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(collisionStateProvider.notifier).reset();
                  },
                  child: const Text('重置碰撞'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 遊戲操作組件
class _GameActionsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameActions = ref.watch(gameActionsProvider);
    final isPaused = ref.watch(gameIsPausedProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('遊戲操作', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    gameActions.restartGame();
                  },
                  child: const Text('重新開始'),
                ),
                ElevatedButton(
                  onPressed: () {
                    gameActions.togglePause();
                  },
                  child: Text(isPaused ? '恢復遊戲' : '暫停遊戲'),
                ),
                ElevatedButton(
                  onPressed: () {
                    gameActions.addScore(50);
                  },
                  child: const Text('增加分數 +50'),
                ),
                ElevatedButton(
                  onPressed: () {
                    gameActions.nextLevel();
                  },
                  child: const Text('下一關'),
                ),
                ElevatedButton(
                  onPressed: () {
                    gameActions.playerAttackMonster(25.0);
                  },
                  child: const Text('玩家攻擊'),
                ),
                ElevatedButton(
                  onPressed: () {
                    gameActions.monsterAttackPlayer(15);
                  },
                  child: const Text('怪物攻擊'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 