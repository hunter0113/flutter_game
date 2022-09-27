import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum MonsterAction {
  Normal,
  Walk,
  Attack,
}

class Monster extends SpriteAnimationGroupComponent<MonsterAction> with CollisionCallbacks{
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
    add(RectangleHitbox()..debugMode = true);

    hitBox = RectangleHitbox();
    add(hitBox);
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

}
