import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';

import '../button/attack_button.dart';
import '../constants/game_constants.dart';
import '../manager/game_manager.dart';
import '../service/asset_service.dart';

class InputManager {
  final GameManager gameManager;
  final AssetService assetService;
  
  late final JoystickComponent joystick;
  late final AttackButton attackButton;

  InputManager({
    required this.gameManager,
    required this.assetService,
  });

  void setupJoystickAndButton() {
    final knobPaint = BasicPalette.white.withAlpha((GameConstants.ui.joystickAlpha * 255).toInt()).paint();
    final backgroundPaint = BasicPalette.white.withAlpha((GameConstants.ui.joystickBackgroundAlpha * 255).toInt()).paint();
    
    joystick = JoystickComponent(
      knob: CircleComponent(radius: GameConstants.ui.joystickKnobRadius, paint: knobPaint),
      background: CircleComponent(radius: GameConstants.ui.joystickBackgroundRadius, paint: backgroundPaint),
      margin: GameConstants.ui.joystickMargin,
    );

    final attackImage = assetService.getImage('ui', 'attack');
    attackButton = AttackButton(
      gameManager,
      Sprite(attackImage),
      Vector2(gameManager.screenWidth * 0.9, gameManager.screenHeight * 0.8),
    );
  }
} 