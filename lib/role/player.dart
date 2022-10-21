import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../manager/gamaManager.dart';

enum PlayerAction {
  NORMAL,
  RUN,
  ATTACK_ONE,
  ATTACK_TWO,
  ATTACK_THREE,
}

class Player extends SpriteAnimationGroupComponent<PlayerAction>
    with CollisionCallbacks {
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

    print("onCollisionStart start");
    if(other.position.x > GameManager.player.x){
      print("isRight true");
      GameManager.isRightCollisionBlock = true;
      return;
    }

    print("isLeft true");
    GameManager.isLeftCollisionBlock = true;
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);

    print("onCollisionEnd start");
    if(other.position.x > GameManager.player.x){
      GameManager.isRightCollisionBlock = false;
      return;
    }
    GameManager.isLeftCollisionBlock = false;
  }
}
