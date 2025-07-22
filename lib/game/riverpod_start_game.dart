import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../role/monster.dart';
import '../role/adventurer.dart';
import '../managers/riverpod_game_manager.dart';
import '../manager/animation_manager.dart';
import '../manager/riverpod_input_manager.dart';
import '../manager/asset_load_manager.dart';
import '../managers/background_manager.dart';
import '../service/asset_service.dart';
import '../controllers/riverpod_game_loop_controller.dart';
import '../exceptions/game_exceptions.dart';
import '../providers/providers.dart';

/// 使用 Riverpod 狀態管理的遊戲類
/// 這是對原始 StartGame 的完全重構，使用 Riverpod 進行狀態管理
class RiverpodStartGame extends FlameGame with HasDraggables, HasTappables, HasCollisionDetection {
  // ProviderContainer 用於管理 Riverpod 狀態
  late final ProviderContainer _container;
  
  // 遊戲角色
  late Adventurer _adventurer;
  late Monster _monster;

  // 管理器和控制器（使用 Riverpod 版本）
  late RiverpodGameManager _gameManager;
  late AssetService _assetService;
  late AnimationManager _animationManager;
  late RiverpodInputManager _inputManager;
  late AssetLoadManager _assetLoadManager;
  late BackgroundManager _backgroundManager;
  late RiverpodGameLoopController _gameLoopController;

  // 公開存取器
  Adventurer get adventurer => _adventurer;
  Monster get monster => _monster;
  ProviderContainer get container => _container;
  RiverpodGameManager get gameManager => _gameManager;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    try {
      await _initializeRiverpod();
      await _initializeManagers();
      await _initializeGameLoopController();
      await _loadGameResources();
      await _setupGameComponents();
      await _setupStateListeners();
    } catch (e, stackTrace) {
      throw GameStateException(
        '遊戲初始化失敗',
        'loading',
        'loaded',
        stackTrace: stackTrace,
      );
    }
  }

  /// 初始化 Riverpod 容器
  Future<void> _initializeRiverpod() async {
    _container = ProviderContainer();
    
    // 初始化遊戲狀態
    _container.read(gameActionsProvider).restartGame();
  }

  /// 初始化所有管理器
  Future<void> _initializeManagers() async {
    _gameManager = RiverpodGameManager(container: _container);
    _assetService = AssetService(images);
    _animationManager = AnimationManager(_assetService);
    _inputManager = RiverpodInputManager(
      gameManager: _gameManager,
      assetService: _assetService,
    );
    _assetLoadManager = AssetLoadManager(
      gameManager: _gameManager, // 傳入 RiverpodGameManager
      assetService: _assetService,
      animationManager: _animationManager,
    );
    _backgroundManager = BackgroundManager();
  }

  /// 初始化遊戲循環控制器
  Future<void> _initializeGameLoopController() async {
    _gameLoopController = RiverpodGameLoopController(
      gameManager: _gameManager,
      inputManager: _inputManager,
      updateParallaxVelocity: (velocity) => _backgroundManager.updateVelocity(velocity),
      getGameSize: () => size,
      getChildrenOfType: <T extends Component>() => children.whereType<T>(),
    );
  }

  /// 載入遊戲資源
  Future<void> _loadGameResources() async {
    await _assetService.loadAllAssets();
  }

  /// 設置遊戲組件
  Future<void> _setupGameComponents() async {
    // 載入背景
    final backgroundComponent = await _backgroundManager.loadBackground(
      loadParallaxLayer,
    );
    add(backgroundComponent);

    // 載入遊戲角色
    _adventurer = await _assetLoadManager.loadPlayer();
    add(_adventurer);

    _monster = await _assetLoadManager.loadMonster();
    add(_monster);

    // 設置攝影機和輸入
    _setupCamera();
    _setupJoystickAndButton();
  }

  /// 設置狀態監聽器
  Future<void> _setupStateListeners() async {
    // 監聽玩家血量變化
    _gameManager.listenToPlayerHealth((previous, next) {
      print('玩家血量變化: $previous -> $next');
      if (next <= 0) {
        _handlePlayerDeath();
      }
    });

    // 監聽怪物死亡
    _gameManager.listenToMonsterDeath((previous, next) {
      if (next == true && previous == false) {
        print('怪物死亡！');
        _handleMonsterDeath();
      }
    });

    // 監聽遊戲結束
    _gameManager.listenToGameOver((previous, next) {
      if (next == true && previous == false) {
        print('遊戲結束！');
        _handleGameOver();
      }
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    try {
      // 檢查遊戲是否暫停
      final isPaused = _container.read(gameIsPausedProvider);
      if (isPaused) {
        return;
      }

      // 使用 Riverpod 遊戲循環控制器處理所有遊戲邏輯
      _gameLoopController.handleMonsterLogic(_monster);
      _gameLoopController.handleAttackSequence(_adventurer);
      _gameLoopController.handlePlayerMovement(dt, _adventurer);

      // 更新角色動畫狀態
      _syncCharacterStates();
    } catch (e, stackTrace) {
      print('遊戲更新錯誤: $e');
      print('堆疊追蹤: $stackTrace');
    }
  }

  /// 同步角色狀態與 Riverpod 狀態
  void _syncCharacterStates() {
    // 同步玩家狀態
    final playerState = _container.read(playerStateProvider);
    if (_adventurer.current != playerState.currentAction) {
      _adventurer.current = playerState.currentAction;
    }

    // 同步怪物狀態
    final monsterState = _container.read(monsterStateProvider);
    if (_monster.current != monsterState.currentAction) {
      _monster.current = monsterState.currentAction;
    }
  }

  void _setupJoystickAndButton() {
    // 設置搖桿
    _inputManager.setupJoystick();
    add(_inputManager.joystick);

    // 設置攻擊按鈕
    try {
      _inputManager.setupAttackButton(
        adventurer: _adventurer,
        stopBackgroundScrolling: () => _backgroundManager.stopScrolling(),
        onAttackStart: (attackType) => _gameLoopController.startPlayerAttack(attackType),
      );
      
      if (_inputManager.attackButton != null) {
        _inputManager.attackButton!.positionType = PositionType.viewport;
        add(_inputManager.attackButton!);
      }
    } catch (e) {
      print('設置攻擊按鈕時發生錯誤: $e');
    }
  }

  void _setupCamera() {
    camera.followComponent(_adventurer, relativeOffset: const Anchor(0.3, 0.8));
  }

  /// 處理玩家死亡
  void _handlePlayerDeath() {
    print('玩家死亡事件觸發');
    // 可以在這裡添加死亡動畫、音效等
    // 例如：showGameOverScreen();
  }

  /// 處理怪物死亡
  void _handleMonsterDeath() {
    print('怪物死亡事件觸發');
    // 可以在這裡添加勝利動畫、音效、生成新怪物等
    // 例如：spawnNewMonster();
  }

  /// 處理遊戲結束
  void _handleGameOver() {
    print('遊戲結束事件觸發');
    // 可以在這裡顯示遊戲結束畫面
    // 例如：showGameOverScreen();
  }

  /// 暫停遊戲
  void pauseGame() {
    _gameLoopController.togglePause();
  }

  /// 重新開始遊戲
  void restartGame() {
    _gameLoopController.restartGame();
    
    // 重新載入角色到初始位置
    _resetCharacterPositions();
  }

  /// 重置角色位置
  void _resetCharacterPositions() {
    // 重置玩家位置
    _adventurer.position = Vector2(100, 300); // 根據您的需要調整
    
    // 重置怪物位置
    _monster.position = Vector2(500, 300); // 根據您的需要調整
  }

  /// 處理特殊遊戲事件
  void handleGameEvent(String eventType, Map<String, dynamic> eventData) {
    _gameLoopController.handleSpecialEvent(eventType, eventData);
  }

  /// 獲取當前遊戲狀態
  Map<String, dynamic> getGameStatus() {
    return _gameLoopController.getGameStatus();
  }

  /// 調試方法：打印當前狀態
  void debugPrintStatus() {
    _gameLoopController.debugPrintStatus();
  }

  /// 添加分數
  void addScore(int points) {
    _gameManager.addScore(points);
  }

  /// 玩家受傷
  void playerTakeDamage(int damage) {
    _gameLoopController.handlePlayerDamage(damage);
  }

  /// 怪物受傷
  void monsterTakeDamage(double damage) {
    _gameManager.monsterTakeDamage(damage);
  }

  /// 設置碰撞狀態
  void setCollisionState({
    bool? left,
    bool? right, 
    bool? top,
    bool? bottom,
  }) {
    _gameLoopController.setCollisionState(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
    );
  }

  @override
  void onRemove() {
    // 清理 Riverpod 容器
    _container.dispose();
    super.onRemove();
  }
} 