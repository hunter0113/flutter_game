import 'package:flame/components.dart';

class Arrow extends SpriteComponent {
  double _speed = 250;
  final double maxRange;
  final Vector2 direction; // 方向

  Arrow({
    required Sprite sprite,
    required this.maxRange,
    required this.direction,
  }) : super(sprite: sprite);

  double _length = 0;

  @override
  void update(double dt) {
    super.update(dt);
    Vector2 ds = direction.normalized() * _speed * dt; // 根據方向更新位置
    _length += ds.length;
    position.add(ds);
    if (_length > maxRange) {
      _length = 0;
      removeFromParent();
    }
  }
}
