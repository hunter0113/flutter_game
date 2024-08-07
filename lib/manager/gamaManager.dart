import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';

// 遊戲的狀態和動畫管理
class GameAnimationManager {
  final double screenWidth;
  final double screenHeight;

  // 角色動畫
  late final SpriteAnimation normalAnimation;
  late final SpriteAnimation bowAttackAni;
  late final SpriteAnimation swordAttackAni_One;
  late final SpriteAnimation swordAttackAni_Two;
  late final SpriteAnimation swordAttackAni_Three;
  late final SpriteAnimation runAnimation;

  // 怪物動畫
  late final SpriteAnimation monsterWalk;
  late final SpriteAnimation monsterNormal;
  late final SpriteAnimation monsterAttack;
  late final SpriteAnimation monsterDeath;

  bool adventurerFlipped = false;
  bool isAttack = false;
  bool nextAttackStep = false;

  bool isLeftCollisionBlock = false;
  bool isRightCollisionBlock = false;

  // 背景與x座標軸上的速度
  final Map<String, double> bgLayerInfo = {
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

  GameAnimationManager()
      : screenWidth = MediaQueryData.fromView(window).size.width,
        screenHeight = MediaQueryData.fromView(window).size.height;
}
