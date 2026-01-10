import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';

import '../role/monster.dart';
import '../role/adventurer.dart';
import '../manager/game_manager.dart';
import '../manager/animation_manager.dart';
import '../manager/input_manager.dart';
import '../manager/asset_load_manager.dart';
import '../manager/background_manager.dart';
import '../service/asset_service.dart';
import '../states/monster_state.dart';
import '../controllers/game_loop_controller.dart';
import '../exceptions/game_exceptions.dart';
import '../button/debug_collision_button.dart';

class StartGame extends FlameGame with HasDraggables, HasTappables, HasCollisionDetection {
  // 移除靜態變量，使用實例變量
  late Adventurer _adventurer;
  late Monster _monster;

  // 管理器和控制器
  late GameManager _gameManager;
  late AssetService _assetService;
  late AnimationManager _animationManager;
  late InputManager _inputManager;
  late AssetLoadManager _assetLoadManager;
  late BackgroundManager _backgroundManager;
  late GameLoopController _gameLoopController;

  // 公開存取器（為了向後兼容）
  Adventurer get adventurer => _adventurer;
  Monster get monster => _monster;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    try {
      await _initializeManagers();
      await _initializeGameLoopController();
      await _loadGameResources();
      await _setupGameComponents();
    } catch (e, stackTrace) {
      // 使用新的異常處理系統
      throw GameStateException(
        '遊戲初始化失敗',
        'loading',
        'loaded',
        stackTrace: stackTrace,
      );
    }
  }

  /// 初始化所有管理器
  Future<void> _initializeManagers() async {
    _gameManager = GameManager();
    _assetService = AssetService(images);
    _animationManager = AnimationManager(_assetService);
    _inputManager = InputManager(
      gameManager: _gameManager,
      assetService: _assetService,
    );
    _assetLoadManager = AssetLoadManager(
      gameManager: _gameManager,
      assetService: _assetService,
      animationManager: _animationManager,
    );
    _backgroundManager = BackgroundManager();
  }

  /// 初始化遊戲循環控制器
  Future<void> _initializeGameLoopController() async {
    _gameLoopController = GameLoopController(
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



  @override
  void update(double dt) {
    super.update(dt);

    try {
      // 使用遊戲循環控制器處理所有遊戲邏輯
      _gameLoopController.handleMonsterLogic(_monster, dt: dt);
      _gameLoopController.handleAttackSequence(_adventurer);
      _gameLoopController.handlePlayerMovement(dt, _adventurer);
    } catch (e, stackTrace) {
      // 記錄錯誤但不讓遊戲崩潰
      print('遊戲更新錯誤: $e');
      print('堆疊追蹤: $stackTrace');
    }
  }

  void _setupJoystickAndButton() {
    // 設置搖桿
    _inputManager.setupJoystick();
    add(_inputManager.joystick);

    // 設置攻擊按鈕（需要額外的依賴）
    try {
      _inputManager.setupAttackButton(
        adventurer: _adventurer,
        stopBackgroundScrolling: () => _backgroundManager.stopScrolling(),
      );
      
      if (_inputManager.attackButton != null) {
        _inputManager.attackButton!.positionType = PositionType.viewport;
        add(_inputManager.attackButton!);
      }
    } catch (e) {
      print('設置攻擊按鈕時發生錯誤: $e');
    }

    // 設置調試碰撞範圍按鈕（放在左上角）
    try {
      final debugButton = DebugCollisionButton(
        adventurer: _adventurer,
        monster: _monster,
        position: Vector2(0, 0), // 左上角
      );
      debugButton.positionType = PositionType.viewport;
      add(debugButton);
    } catch (e) {
      print('設置調試碰撞按鈕時發生錯誤: $e');
    }
  }

  void _setupCamera() {
    camera.followComponent(_adventurer, relativeOffset: const Anchor(0.3, 0.8));
  }
}
