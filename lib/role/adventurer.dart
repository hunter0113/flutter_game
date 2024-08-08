import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../components/arrow.dart';
import '../components/lifeComponent.dart';
import '../game/start_game.dart';
import '../manager/gamaManager.dart';

enum AdventurerAction {
  NORMAL,
  RUN,
  BOW_ATTACK,
  SWORD_ATTACK_ONE,
  SWORD_ATTACK_TWO,
  SWORD_ATTACK_THREE,
}

class Adventurer extends SpriteAnimationGroupComponent<AdventurerAction>
    with CollisionCallbacks, Liveable, HasGameRef {
  final GameAnimationManager gameManager;
  late ShapeHitbox hitBox;
  late Sprite arrowSprite;
  bool isFlipped = false; // 用來判斷角色朝向

  Adventurer({
    required this.gameManager,
    required Map<AdventurerAction, SpriteAnimation>? animations,
    required Vector2 size,
    required Vector2 position,
    required AdventurerAction current,
  }) : super(
          animations: animations,
          size: size,
          position: position,
          anchor: Anchor.center,
          current: current,
        );

  @override
  Future<void> onLoad() async {
    // debugMode
    add(CircleHitbox()..debugMode = true);
    add(CircleHitbox());

    // 血條
    initBloodBar(lifeColor: Colors.blue, lifePoint: 1000);

    // 弓箭
    arrowSprite = await gameRef.loadSprite('weapon_arrow.png');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if(current == AdventurerAction.BOW_ATTACK && animation!.done()){
      _onLastFrame();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other.position.x > StartGame.adventurer.x) {
      gameManager.isRightCollisionBlock = true;
      return;
    }

    gameManager.isLeftCollisionBlock = true;
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);

    if (other.position.x > StartGame.adventurer.x) {
      gameManager.isRightCollisionBlock = false;
      return;
    }
    gameManager.isLeftCollisionBlock = false;
  }


  void _onLastFrame() async {
    animation!.currentIndex = 0;
    animation!.update(0);

    // 添加弓箭
    Vector2 arrowDirection;
    Vector2 arrowPosition;

    if (isFlipped) {
      arrowDirection = Vector2(-1, 0); // 弓箭向左
      arrowPosition = position - Vector2(30, 0); // 朝左
    } else {
      arrowDirection = Vector2(1, 0); // 弓箭向右
      arrowPosition = position - Vector2(-30, 0); // 朝右
    }

    Arrow arrow = Arrow(
      sprite: arrowSprite,
      maxRange: 300,
      direction: arrowDirection,
    );

    if (isFlipped) {
      arrow.flipHorizontally();
    }

    arrow.size = Vector2(32, 32);
    arrow.anchor = Anchor.center;
    arrow.priority = 1;
    arrow.position = arrowPosition;
    priority = 2;

    gameRef.add(arrow);
  }


}
