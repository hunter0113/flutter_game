# Riverpod 狀態管理架構

## 概述

本專案已成功整合 Riverpod 狀態管理，提供了完整的遊戲狀態管理解決方案。

## 架構結構

```
lib/providers/
├── providers.dart          # 統一導出文件
├── player_providers.dart   # 玩家狀態管理
├── monster_providers.dart  # 怪物狀態管理
├── collision_providers.dart # 碰撞狀態管理
├── game_providers.dart     # 遊戲狀態管理
└── README.md              # 本文檔
```

## 主要提供者

### 1. 玩家狀態管理

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

// 在 ConsumerWidget 中使用
class PlayerWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final playerHealth = ref.watch(playerHealthProvider);
    
    // 修改狀態
    ref.read(playerStateProvider.notifier).takeDamage(10);
    ref.read(playerStateProvider.notifier).updateAction(AdventurerAction.run);
    
    return Text('血量: $playerHealth');
  }
}
```

### 2. 怪物狀態管理

```dart
// 監聽怪物狀態
final monsterHealth = ref.watch(monsterHealthProvider);
final monsterIsDead = ref.watch(monsterIsDeadProvider);

// 操作怪物狀態
ref.read(monsterStateProvider.notifier).takeDamage(25.0);
ref.read(monsterStateProvider.notifier).startAttack();
```

### 3. 遊戲狀態管理

```dart
// 監聽遊戲狀態
final gameStatus = ref.watch(gameStatusSummaryProvider);
final score = ref.watch(gameScoreProvider);

// 使用遊戲操作
final gameActions = ref.read(gameActionsProvider);
gameActions.restartGame();
gameActions.addScore(100);
gameActions.playerAttackMonster(30.0);
```

### 4. 碰撞狀態管理

```dart
// 監聽碰撞狀態
final hasCollision = ref.watch(hasAnyCollisionProvider);
final isLeftBlocked = ref.watch(isLeftBlockedProvider);

// 設置碰撞狀態
ref.read(collisionStateProvider.notifier).setLeftBlocked(true);
ref.read(collisionStateProvider.notifier).reset();
```

## 可用的提供者列表

### 玩家相關
- `playerStateProvider` - 完整玩家狀態
- `playerHealthProvider` - 玩家血量
- `playerIsAttackingProvider` - 是否正在攻擊
- `playerIsMovingProvider` - 是否正在移動
- `playerCurrentActionProvider` - 當前動作
- `playerIsDeadProvider` - 是否死亡

### 怪物相關
- `monsterStateProvider` - 完整怪物狀態
- `monsterHealthProvider` - 怪物血量
- `monsterIsAliveProvider` - 是否存活
- `monsterIsDeadProvider` - 是否死亡
- `monsterCurrentActionProvider` - 當前動作
- `monsterIsAttackingProvider` - 是否正在攻擊

### 遊戲狀態相關
- `gameStateProvider` - 基本遊戲狀態
- `combinedGameStateProvider` - 組合的遊戲狀態
- `gameIsPausedProvider` - 是否暫停
- `gameScoreProvider` - 遊戲分數
- `gameLevelProvider` - 遊戲關卡
- `gameIsOverProvider` - 是否結束
- `gameIsWonProvider` - 是否勝利
- `gameStatusSummaryProvider` - 遊戲狀態摘要
- `gameActionsProvider` - 遊戲操作方法

### 碰撞相關
- `collisionStateProvider` - 完整碰撞狀態
- `isLeftBlockedProvider` - 左側是否阻擋
- `isRightBlockedProvider` - 右側是否阻擋
- `isTopBlockedProvider` - 上方是否阻擋
- `isBottomBlockedProvider` - 下方是否阻擋
- `hasAnyCollisionProvider` - 是否有任何碰撞
- `isHorizontalBlockedProvider` - 水平方向是否阻擋
- `isVerticalBlockedProvider` - 垂直方向是否阻擋
- `isCompletelyBlockedProvider` - 是否完全被包圍

## 使用範例

完整的使用範例請查看 `lib/examples/riverpod_usage_example.dart`

## 在遊戲中整合

### 1. 修改 main.dart

您的 main.dart 已經配置好 Riverpod：

```dart
void main() async {
  // ... 初始化代碼 ...
  
  runApp(
    ProviderScope(
      child: MyGameApp(),
    ),
  );
}
```

### 2. 在 Flame 遊戲中使用

在您的遊戲組件中，您可以通過以下方式獲取 Riverpod 狀態：

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyGameComponent extends Component {
  late ProviderContainer container;

  @override
  Future<void> onLoad() async {
    // 從遊戲中獲取 ProviderContainer
    container = findGame()!.ref; // 需要您的遊戲類實現 ref
    
    // 監聽狀態變化
    container.listen(playerHealthProvider, (previous, next) {
      // 當玩家血量變化時執行邏輯
    });
  }

  void playerTakeDamage() {
    container.read(playerStateProvider.notifier).takeDamage(10);
  }
}
```

### 3. 最佳實踐

1. **使用組合的提供者**：優先使用 `combinedGameStateProvider` 來獲取完整的遊戲狀態
2. **粒度化監聽**：只監聽您真正需要的特定狀態，避免不必要的重建
3. **使用 GameActions**：使用 `gameActionsProvider` 來執行複雜的遊戲邏輯
4. **狀態重置**：使用 `gameActions.restartGame()` 來重置所有狀態

## 優勢

1. **集中化狀態管理**：所有遊戲狀態都在一個地方管理
2. **響應式更新**：狀態變化會自動觸發 UI 更新
3. **型別安全**：編譯時型別檢查
4. **易於測試**：每個提供者都可以獨立測試
5. **性能優化**：只有真正依賴狀態的組件才會重建
6. **易於擴展**：可以輕鬆添加新的狀態和提供者

## 下一步

1. 將現有的遊戲邏輯遷移到使用 Riverpod 提供者
2. 添加更多遊戲特定的狀態（如道具、技能等）
3. 實現狀態持久化（保存/載入遊戲）
4. 添加網路狀態管理（如果需要多人遊戲） 