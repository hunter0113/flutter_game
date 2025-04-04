import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/components/life_component.dart';
import 'package:flutter_game/constants/game_constants.dart';
import 'package:flutter_game/states/monster_state.dart';

class Monster extends SpriteAnimationGroupComponent<MonsterAction>
    with CollisionCallbacks, Liveable {
  late ShapeHitbox hitBox;

  Monster({
    required Map<MonsterAction, SpriteAnimation>? animations,
    required Vector2 size,
    required Vector2 position,
    required MonsterAction current,
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

    initBloodBar(
      lifeColor: GameConstants.monster.healthBarColor,
      lifePoint: GameConstants.monster.initialHealth.toDouble(),
      outlineColor: Colors.black,
    );
  }

  @override
  void loss(double damage) {
    super.loss(damage);
    if (life <= 0) {
      current = MonsterAction.death;
    }
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
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
  }

  @override
  void onDied() {
    current = MonsterAction.death;
  }
}
