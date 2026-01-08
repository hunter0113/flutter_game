import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

class Arrow extends SpriteComponent with CollisionCallbacks {
  double _speed = 250;
  final double maxRange;
  final Vector2 direction;

  Arrow({
    required Sprite sprite,
    required this.maxRange,
    required this.direction,
  }) : super(sprite: sprite);

  double _length = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // 添加碰撞範圍，預設不顯示
    add(RectangleHitbox()..debugMode = false);
  }

  @override
  void update(double dt) {
    super.update(dt);
    Vector2 ds = direction.normalized() * _speed * dt;
    _length += ds.length;
    position.add(ds);
    if (_length > maxRange) {
      _length = 0;
      removeFromParent();
    }
  }

  void flipHorizontally() {
    scale.x *= -1;
  }
}
