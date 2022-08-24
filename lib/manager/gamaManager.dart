import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_game/role/player.dart';
import '../button/attackButton.dart';

class GameManager {
  static final double screenWidth =
      MediaQueryData.fromWindow(window).size.width;
  static final double screenHeight =
      MediaQueryData.fromWindow(window).size.height;

  static late final JoystickComponent joystick;
  static late final AttackComponent attackButton;

  static late Player player;
  static late ParallaxComponent parallax;
  static late final SpriteAnimation normalAnimation,
      attackAniStage_One,
      attackAniStage_Two,
      attackAniStage_Three,
      runAnimation;
  static bool playerFlipped = false;
  static bool isAttack = false;
  static bool nextAttackStep = false;

  static late SpriteSheet allSpriteSheet;

  // 背景與x座標軸上的速度
  static final bgLayerInfo = {
    'background_11.png': 0.5,
    'background_10.png': 0.75,
    'background_9.png': 1.0,
    'background_8.png': 1.25,
    'background_7.png': 1.5,
    'background_6.png': 1.75,
    'background_5.png': 2.0,
    'background_4.png': 2.25,
    'background_3.png': 2.5,
    'background_2.png': 2.75,
    'background_1.png': 3.0,
    'background_0.png': 3.25,
  };
}
