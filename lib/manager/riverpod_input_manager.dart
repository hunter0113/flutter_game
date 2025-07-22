import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';

import '../button/riverpod_attack_button.dart';
import '../constants/game_constants.dart';
import '../managers/riverpod_game_manager.dart';
import '../service/asset_service.dart';
import '../role/adventurer.dart';
import '../states/player_state.dart';

/// 使用 Riverpod 的輸入管理器
class RiverpodInputManager {
  final RiverpodGameManager gameManager;
  final AssetService assetService;
  
  late final JoystickComponent joystick;
  RiverpodAttackButton? _attackButton;

  RiverpodInputManager({
    required this.gameManager,
    required this.assetService,
  });

  /// 取得攻擊按鈕（如果已初始化）
  RiverpodAttackButton? get attackButton => _attackButton;

  /// 設置搖桿
  void setupJoystick() {
    final knobPaint = BasicPalette.white.withAlpha((GameConstants.ui.joystickAlpha * 255).toInt()).paint();
    final backgroundPaint = BasicPalette.white.withAlpha((GameConstants.ui.joystickBackgroundAlpha * 255).toInt()).paint();
    
    joystick = JoystickComponent(
      knob: CircleComponent(radius: GameConstants.ui.joystickKnobRadius, paint: knobPaint),
      background: CircleComponent(radius: GameConstants.ui.joystickBackgroundRadius, paint: backgroundPaint),
      margin: GameConstants.ui.joystickMargin,
    );
  }

  /// 設置攻擊按鈕
  void setupAttackButton({
    required Adventurer adventurer,
    required void Function() stopBackgroundScrolling,
    void Function(AdventurerAction)? onAttackStart,
  }) {
    try {
      final attackImage = assetService.getImage('ui', 'attack');
      final buttonPosition = Vector2(gameManager.screenWidth * 0.9, gameManager.screenHeight * 0.8);
      
      _attackButton = RiverpodAttackButton(
        gameManager: gameManager,
        adventurer: adventurer,
        stopBackgroundScrolling: stopBackgroundScrolling,
        onAttackStart: onAttackStart,
        sprite: Sprite(attackImage),
        position: buttonPosition,
      );
    } catch (e) {
      print('Riverpod 攻擊按鈕設置失敗: $e');
      rethrow;
    }
  }

  /// 檢查玩家輸入並返回移動方向
  Vector2 getMovementInput() {
    return joystick.relativeDelta;
  }

  /// 檢查是否有移動輸入
  bool hasMovementInput() {
    return !joystick.relativeDelta.isZero();
  }

  /// 獲取移動方向（標準化）
  Vector2 getMovementDirection() {
    final delta = joystick.relativeDelta;
    return delta.isZero() ? Vector2.zero() : delta.normalized();
  }

  /// 檢查是否向左移動
  bool isMovingLeft() {
    return joystick.relativeDelta.x < 0;
  }

  /// 檢查是否向右移動
  bool isMovingRight() {
    return joystick.relativeDelta.x > 0;
  }

  /// 檢查是否向上移動
  bool isMovingUp() {
    return joystick.relativeDelta.y < 0;
  }

  /// 檢查是否向下移動
  bool isMovingDown() {
    return joystick.relativeDelta.y > 0;
  }

  /// 獲取移動強度（0.0 到 1.0）
  double getMovementIntensity() {
    return joystick.relativeDelta.length.clamp(0.0, 1.0);
  }

  /// 設置搖桿位置
  void setJoystickPosition(Vector2 position) {
    joystick.position = position;
  }

  /// 設置攻擊按鈕位置
  void setAttackButtonPosition(Vector2 position) {
    _attackButton?.position = position;
  }

  /// 啟用/禁用搖桿
  void setJoystickEnabled(bool enabled) {
    joystick.positionType = enabled ? PositionType.viewport : PositionType.widget;
  }

  /// 啟用/禁用攻擊按鈕
  void setAttackButtonEnabled(bool enabled) {
    _attackButton?.removeFromParent();
    if (enabled && _attackButton != null) {
      // 需要在遊戲中重新添加
    }
  }

  /// 重置所有輸入狀態
  void resetInputs() {
    // Note: delta is final, so we can't reset it directly
    // The joystick will reset itself when there's no input
  }

  /// 處理觸摸輸入（用於自定義輸入處理）
  bool handleTouchInput(Vector2 touchPosition) {
    // 檢查是否觸摸到攻擊按鈕區域
    if (_attackButton != null && _attackButton!.containsLocalPoint(touchPosition)) {
      // 觸發攻擊
      return true;
    }
    return false;
  }

  /// 獲取輸入狀態摘要
  Map<String, dynamic> getInputStatus() {
    return {
      'hasMovement': hasMovementInput(),
      'movementDirection': getMovementDirection(),
      'movementIntensity': getMovementIntensity(),
      'isMovingLeft': isMovingLeft(),
      'isMovingRight': isMovingRight(),
      'isMovingUp': isMovingUp(),
      'isMovingDown': isMovingDown(),
      'joystickDelta': joystick.relativeDelta,
      'attackButtonPosition': _attackButton?.position,
    };
  }

  /// 調試方法：打印輸入狀態
  void debugPrintInputStatus() {
    final status = getInputStatus();
    print('=== 輸入狀態 ===');
    print('有移動輸入: ${status['hasMovement']}');
    print('移動方向: ${status['movementDirection']}');
    print('移動強度: ${status['movementIntensity']}');
    print('搖桿偏移: ${status['joystickDelta']}');
    print('===============');
  }
} 