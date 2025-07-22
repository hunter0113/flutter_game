import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';

import '../button/attack_button.dart';
import '../constants/game_constants.dart';
import '../manager/game_manager.dart';
import '../service/asset_service.dart';
import '../role/adventurer.dart';

class InputManager {
  final GameManager gameManager;
  final AssetService assetService;
  
  late final JoystickComponent joystick;
  AttackButton? _attackButton;

  InputManager({
    required this.gameManager,
    required this.assetService,
  });

  /// 取得攻擊按鈕（如果已初始化）
  AttackButton? get attackButton => _attackButton;

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
  }) {
    try {
      final attackImage = assetService.getImage('ui', 'attack');
      final buttonPosition = Vector2(gameManager.screenWidth * 0.9, gameManager.screenHeight * 0.8);
      
      _attackButton = AttackButton(
        gameManager: gameManager,
        adventurer: adventurer,
        stopBackgroundScrolling: stopBackgroundScrolling,
        sprite: Sprite(attackImage),
        position: buttonPosition,
      );
    } catch (e) {
      print('攻擊按鈕設置失敗: $e');
      rethrow;
    }
  }

  /// 設置搖桿和按鈕（向後兼容方法）
  @Deprecated('使用 setupJoystick() 和 setupAttackButton() 分別設置')
  void setupJoystickAndButton() {
    setupJoystick();
    // 攻擊按鈕需要額外參數，不能在這裡設置
  }
} 