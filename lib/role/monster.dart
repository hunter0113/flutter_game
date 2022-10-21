import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum MonsterAction {
  NORMAL,
  WALK,
  ATTACK,
  DEATH
}

class Monster extends SpriteAnimationGroupComponent<MonsterAction>
    with CollisionCallbacks {
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
    // TODO
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    // TODO
  }
}
