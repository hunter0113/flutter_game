import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../extension/Liveable.dart';
import '../game/start_game.dart';
import '../manager/gamaManager.dart';

enum PlayerAction {
  NORMAL,
  RUN,
  ATTACK_ONE,
  ATTACK_TWO,
  ATTACK_THREE,
}

class Player extends SpriteAnimationGroupComponent<PlayerAction>
    with CollisionCallbacks, Liveable {
  late ShapeHitbox hitBox;

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
  }

  @override
  void update(double dt) {
    super.update(dt);
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
}
