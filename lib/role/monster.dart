import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/components/life_component.dart';
import 'package:flutter_game/constants/game_constants.dart';
import 'package:flutter_game/states/monster_state.dart';

class Monster extends SpriteAnimationGroupComponent<MonsterAction>
    with CollisionCallbacks, Liveable {
  late ShapeHitbox hitBox;
  
  // 移動相關變量
  Vector2 _initialPosition = Vector2.zero();
  double _moveDirection = 1.0; // 1.0 向右，-1.0 向左
  bool _isMoving = false;

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
        ) {
    _initialPosition = position;
  }
  
  /// 獲取初始位置
  Vector2 get initialPosition => _initialPosition;
  
  /// 獲取移動方向
  double get moveDirection => _moveDirection;
  
  /// 設置移動方向
  void setMoveDirection(double direction) {
    _moveDirection = direction;
  }
  
  /// 是否正在移動
  bool get isMoving => _isMoving;
  
  /// 設置移動狀態
  void setMoving(bool moving) {
    _isMoving = moving;
  }

  @override
  Future<void> onLoad() async {
    // debugMode - 預設為 false，可通過按鈕切換顯示
    add(CircleHitbox()..debugMode = false);
    add(CircleHitbox()..debugMode = false);

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
