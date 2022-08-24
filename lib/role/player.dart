import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum PlayerAction {
  Normal,
  Run,
  Attack_One,
  Attack_Two,
  Attack_Three,
}

class Player extends SpriteAnimationGroupComponent<PlayerAction> {
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
    add(RectangleHitbox()..debugMode = true);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}
