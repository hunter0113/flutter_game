import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../component/bullet.dart';
import '../extension/liveable.dart';
import '../game/start_game.dart';
import '../manager/gamaManager.dart';

enum PlayerAction {
  NORMAL,
  RUN,
  BOW_ATTACK,
  SWORD_ATTACK_ONE,
  SWORD_ATTACK_TWO,
  SWORD_ATTACK_THREE,
}

class Player extends SpriteAnimationGroupComponent<PlayerAction>
    with CollisionCallbacks, Liveable, HasGameRef {
  late ShapeHitbox hitBox;
  late Sprite bulletSprite;

  Player({
    required Map<PlayerAction, SpriteAnimation>? animations,
    required Vector2 size,
    required Vector2 position,
    required PlayerAction current,
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
    // add(CircleHitbox()..debugMode = true);
    add(CircleHitbox());

    initBloodBar(lifeColor: Colors.blue, lifePoint: 1000);

    bulletSprite = await gameRef.loadSprite('weapon_arrow.png');

  }

  @override
  void update(double dt) {
    super.update(dt);

    if(current == PlayerAction.BOW_ATTACK && animation!.done()){
      _onLastFrame();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other.position.x > StartGame.player.x) {
      GameManager.isRightCollisionBlock = true;
      return;
    }

    GameManager.isLeftCollisionBlock = true;
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);

    print("onCollisionEnd start");
    if (other.position.x > StartGame.player.x) {
      GameManager.isRightCollisionBlock = false;
      return;
    }
    GameManager.isLeftCollisionBlock = false;
  }



  void _onLastFrame() async{

    print("_onLastFrame");
    animation!.currentIndex = 0;
    animation!.update(0);

    // 添加子彈
    Bullet bullet = Bullet(sprite: bulletSprite, maxRange: 200);
    bullet.size = Vector2(32, 32);
    bullet.anchor = Anchor.center;
    bullet.priority = 1;
    priority = 2;
    bullet.position = position-Vector2(0,-3);
    gameRef.add(bullet);
  }

}
