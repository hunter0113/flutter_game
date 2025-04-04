import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../components/arrow.dart';
import '../components/life_component.dart';
import '../manager/game_manager.dart';
import '../constants/game_constants.dart';
import '../states/player_state.dart';

class Adventurer extends SpriteAnimationGroupComponent<AdventurerAction>
    with CollisionCallbacks, Liveable, HasGameRef {
  final GameManager gameManager;
  late ShapeHitbox hitBox;
  late Sprite arrowSprite;
  bool isFlipped = false; // 用來判斷角色朝向

  Adventurer({
    required this.gameManager,
    required Map<AdventurerAction, SpriteAnimation>? animations,
    required Vector2 size,
    required Vector2 position,
    required AdventurerAction current,
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

    // 血條
    initBloodBar(
      lifeColor: GameConstants.player.healthBarColor,
      lifePoint: GameConstants.player.initialHealth,
    );

    // 弓箭
    arrowSprite = await gameRef.loadSprite('weapon_arrow.png');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if(current == AdventurerAction.bowAttack && animation!.done()){
      _onLastFrame();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other.position.x > position.x) {
      gameManager.updateCollisionState(isRightBlocked: true);
      return;
    }

    gameManager.updateCollisionState(isLeftBlocked: true);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);

    if (other.position.x > position.x) {
      gameManager.updateCollisionState(isRightBlocked: false);
      return;
    }
    gameManager.updateCollisionState(isLeftBlocked: false);
  }

  void _onLastFrame() async {
    animation!.currentIndex = 0;
    animation!.update(0);

    // 添加弓箭
    Vector2 arrowDirection;
    Vector2 arrowPosition;

    if (isFlipped) {
      arrowDirection = Vector2(-1, 0); // 弓箭向左
      arrowPosition = position - Vector2(30, 0); // 朝左
    } else {
      arrowDirection = Vector2(1, 0); // 弓箭向右
      arrowPosition = position - Vector2(-30, 0); // 朝右
    }

    Arrow arrow = Arrow(
      sprite: arrowSprite,
      direction: arrowDirection,
      maxRange: 300.0,
    );

    arrow.position = arrowPosition;
    arrow.size = Vector2(32, 32);
    arrow.anchor = Anchor.center;
    arrow.priority = 1;

    if (isFlipped) {
      arrow.flipHorizontally();
    }

    gameRef.add(arrow);
  }
}
