import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/input.dart';

class attackComponent extends SpriteComponent with Tappable {
  attackComponent(Sprite sprite ,Vector2 position)
      : super(
          position: position,
          size: Vector2(50, 50),
          anchor: Anchor.bottomRight,
          sprite: sprite,
        );

  @override
  bool onTapDown(TapDownInfo event) {

    // player.attackTest = true;
    // player.current = PlayerAction.Attack;
    return true;
  }
}
