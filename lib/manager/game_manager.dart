import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import '../states/game_state.dart';
import '../states/player_state.dart';
import '../states/monster_state.dart';
import '../interfaces/game_manager_interface.dart';

// 遊戲的狀態和動畫管理
class GameManager implements IGameManager {
  final double screenWidth;
  final double screenHeight;
  final GameState state;

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

  GameManager()
      : screenWidth = MediaQueryData.fromView(window).size.width,
        screenHeight = MediaQueryData.fromView(window).size.height,
        state = GameState();

  void updatePlayerState({
    bool? isAttacking,
    bool? isMoving,
    bool? isFlipped,
    AdventurerAction? currentAction,
    int? health,
  }) {
    state.player.isAttacking = isAttacking ?? state.player.isAttacking;
    state.player.isMoving = isMoving ?? state.player.isMoving;
    state.player.isFlipped = isFlipped ?? state.player.isFlipped;
    state.player.currentAction = currentAction ?? state.player.currentAction;
    state.player.health = health ?? state.player.health;
  }

  void updateMonsterState({
    MonsterAction? currentAction,
    double? health,
    bool? isAlive,
  }) {
    state.monster.currentAction = currentAction ?? state.monster.currentAction;
    state.monster.health = health ?? state.monster.health;
    state.monster.isAlive = isAlive ?? state.monster.isAlive;
  }

  void updateCollisionState({
    bool? isLeftBlocked,
    bool? isRightBlocked,
    bool? isTopBlocked,
    bool? isBottomBlocked,
  }) {
    state.collision.isLeftBlocked = isLeftBlocked ?? state.collision.isLeftBlocked;
    state.collision.isRightBlocked = isRightBlocked ?? state.collision.isRightBlocked;
    state.collision.isTopBlocked = isTopBlocked ?? state.collision.isTopBlocked;
    state.collision.isBottomBlocked = isBottomBlocked ?? state.collision.isBottomBlocked;
  }
}
