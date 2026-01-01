# 系統架構模式

## 雙軌架構概述

專案採用雙軌並行架構，同時支援傳統狀態管理和 Riverpod 響應式狀態管理：

### 🏛️ 傳統架構（向後兼容）
```
StartGame (主遊戲類)
├── 管理器層 (Managers)
│   ├── GameManager - 直接遊戲狀態管理
│   ├── AnimationManager - 動畫管理
│   ├── InputManager - 傳統輸入處理
│   ├── AssetLoadManager - 資源載入管理
│   └── BackgroundManager - 背景管理
├── 角色層 (Roles)
│   ├── Adventurer - 冒險者角色
│   └── Monster - 怪物角色
├── 組件層 (Components)
│   ├── LifeComponent - 生命值組件
│   ├── DamageText - 傷害文字
│   └── Arrow - 箭矢組件
├── 狀態層 (States)
│   ├── PlayerState - 玩家狀態
│   ├── MonsterState - 怪物狀態
│   ├── GameState - 遊戲狀態
│   └── CollisionState - 碰撞狀態
└── 服務層 (Services)
    └── AssetService - 資源服務
```

### 🔄 Riverpod 架構（新開發方向）
```
RiverpodStartGame (響應式遊戲類)
├── 提供者層 (Providers)
│   ├── PlayerProviders - 玩家狀態提供者
│   ├── MonsterProviders - 怪物狀態提供者
│   ├── GameProviders - 遊戲狀態提供者
│   └── CollisionProviders - 碰撞狀態提供者
├── 管理器層 (Riverpod Managers)
│   ├── RiverpodGameManager - 響應式遊戲管理
│   ├── RiverpodInputManager - 響應式輸入管理
│   ├── RiverpodGameLoopController - 響應式遊戲循環
│   └── 共享管理器 (AnimationManager, AssetLoadManager, BackgroundManager)
├── 組件層 (Riverpod Components)
│   └── RiverpodAttackButton - 響應式攻擊按鈕
├── 接口層 (Interfaces)
│   └── IGameManager - 管理器統一接口
└── 服務層 (Services)
    └── AssetService - 資源服務
```

## 🗂️ 目錄結構

```
lib/
├── button/
│   ├── attack_button.dart               # 傳統攻擊按鈕
│   └── riverpod_attack_button.dart      # Riverpod 攻擊按鈕
├── components/
│   ├── arrow.dart                       # 箭矢組件
│   ├── damage_text.dart                 # 傷害文字
│   └── life_component.dart              # 生命值組件
├── constants/
│   └── game_constants.dart              # 遊戲常量
├── controllers/
│   ├── game_loop_controller.dart        # 傳統遊戲循環控制器
│   └── riverpod_game_loop_controller.dart # Riverpod 遊戲循環控制器
├── exceptions/
│   └── game_exceptions.dart             # 遊戲異常處理
├── extensions/
│   └── (擴展方法)
├── game/
│   ├── start_game.dart                  # 傳統遊戲主類
│   └── riverpod_start_game.dart         # Riverpod 遊戲主類
├── interfaces/
│   └── game_manager_interface.dart      # 遊戲管理器接口
├── manager/
│   ├── animation_manager.dart           # 動畫管理器
│   ├── asset_load_manager.dart          # 資源載入管理器
│   ├── background_manager.dart          # 背景管理器
│   ├── game_manager.dart                # 傳統遊戲管理器
│   ├── input_manager.dart               # 傳統輸入管理器
│   ├── riverpod_game_manager.dart       # Riverpod 遊戲管理器
│   └── riverpod_input_manager.dart      # Riverpod 輸入管理器
├── providers/
│   ├── collision_providers.dart         # 碰撞狀態提供者
│   ├── game_providers.dart              # 遊戲狀態提供者
│   ├── monster_providers.dart           # 怪物狀態提供者
│   ├── player_providers.dart            # 玩家狀態提供者
│   ├── providers.dart                   # 統一導出
│   └── README.md                        # Riverpod 使用文檔
├── role/
│   ├── adventurer.dart                  # 冒險者角色
│   └── monster.dart                     # 怪物角色
├── service/
│   └── asset_service.dart               # 資源服務
├── states/
│   ├── collision_state.dart             # 碰撞狀態
│   ├── game_state.dart                  # 遊戲狀態
│   ├── monster_state.dart               # 怪物狀態
│   └── player_state.dart                # 玩家狀態
├── main.dart                            # 傳統版本入口
├── main_riverpod.dart                   # Riverpod 版本入口
├── MIGRATION_COMPLETE.md                # 遷移完成報告
└── README.md                            # 專案說明
```

## 🎯 設計模式

### 傳統架構模式
- **Manager Pattern**: 管理器模式統一管理不同功能
- **Component Pattern**: 組件化設計提高復用性
- **State Pattern**: 狀態模式管理遊戲狀態
- **Service Pattern**: 服務層封裝通用功能

### Riverpod 架構模式
- **Provider Pattern**: 響應式狀態提供者
- **Consumer Pattern**: 狀態消費者模式
- **Notifier Pattern**: 狀態變更通知
- **Dependency Injection**: 依賴注入模式
- **Interface Segregation**: 接口隔離原則

## 🔄 核心組件關係

### 傳統架構數據流
```
Input → InputManager → GameManager → 角色/組件 → 狀態更新 → 視覺反饋
```

### Riverpod 架構數據流
```
Input → RiverpodInputManager → Providers → Notifiers → 自動 UI 更新
                                 ↓
                            監聽器觸發 → 遊戲邏輯響應
```

## 🌉 架構橋接

### 接口統一
- `IGameManager` 接口允許組件同時支援兩種管理器
- `Adventurer` 類通過接口適配不同的管理器實現

### 共享組件
- `AnimationManager`, `AssetLoadManager`, `BackgroundManager` 在兩種架構中共享
- 狀態類 (`PlayerState`, `MonsterState` 等) 被兩種架構復用

## 🎮 使用選擇

### 使用傳統架構 (main.dart)
```bash
flutter run
```
- 性能優先
- 簡單直接
- 調試容易

### 使用 Riverpod 架構 (main_riverpod.dart)
```bash
flutter run lib/main_riverpod.dart
```
- 響應式狀態管理
- 自動 UI 更新
- 更好的狀態監聽能力
- 未來擴展性更好

## 🎯 開發建議

1. **新功能開發**: 優先使用 Riverpod 架構
2. **維護現有功能**: 可以繼續使用傳統架構
3. **性能敏感部分**: 使用傳統架構
4. **UI 狀態管理**: 使用 Riverpod 架構 