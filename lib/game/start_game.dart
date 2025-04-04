import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/parallax.dart';

import 'package:flutter_game/role/monster.dart';
import 'package:flutter_game/role/adventurer.dart';
import '../button/attackButton.dart';
import '../components/arrow.dart';
import '../manager/gamaManager.dart';
import '../constants/game_constants.dart';
import '../manager/animation_manager.dart';
import '../service/asset_service.dart';

class StartGame extends FlameGame with HasDraggables, HasTappables, HasCollisionDetection, PanDetector {
  late final JoystickComponent joystick;
  late final AttackComponent attackButton;
  static late ParallaxComponent parallax;
  static late Adventurer adventurer;
  static late Monster monster;

  late GameAnimationManager gameManager;
  late AssetService _assetService;
  late AnimationManager _animationManager;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    gameManager = GameAnimationManager();
    _assetService = AssetService(images);
    _animationManager = AnimationManager(_assetService);

    try {
      await _assetService.loadAllAssets();
      await _loadBackground();
      await _loadPlayer();
      await _loadMonster();
      _setupCamera();
      _setupJoystickAndButton();
    } catch (e) {
      print('遊戲初始化失敗: $e');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    bool moveLeft = joystick.relativeDelta[0] < 0;
    bool moveRight = joystick.relativeDelta[0] > 0;

    double playerVectorX = (joystick.relativeDelta * (GameConstants.PLAYER_SPEED * 1.2) * dt)[0];
    double playerVectorY = (joystick.relativeDelta * (GameConstants.PLAYER_SPEED * 1.2) * dt)[1];

    if (monster.current == MonsterAction.DEATH && monster.animation!.done()) {
      monster.removeFromParent();
    }

    if (monster.life > 0) {
      monsterUpdate();
    }

    if ((gameManager.isAttack) && adventurer.animation!.done()) {
      swordAttack();
      return;
    }

    if (gameManager.isAttack) {
      return;
    }

    if (!joystick.delta.isZero()) {
      joystickMove(playerVectorX, playerVectorY, moveLeft, moveRight);
      return;
    }

    if (gameManager.isAttack) {
      return;
    }
    adventurer.current = AdventurerAction.NORMAL;
    parallax.parallax?.baseVelocity = Vector2.zero();
  }

  void _setupJoystickAndButton() async {
    final knobPaint = BasicPalette.white.withAlpha(GameConstants.JOYSTICK_ALPHA).paint();
    final backgroundPaint = BasicPalette.white.withAlpha(GameConstants.JOYSTICK_BACKGROUND_ALPHA).paint();
    joystick = JoystickComponent(
      knob: CircleComponent(radius: GameConstants.JOYSTICK_KNOB_RADIUS, paint: knobPaint),
      background: CircleComponent(radius: GameConstants.JOYSTICK_BACKGROUND_RADIUS, paint: backgroundPaint),
      margin: GameConstants.JOYSTICK_MARGIN,
    );
    add(joystick);

    final attackImage = _assetService.getImage('ui', 'attack');
    attackButton = AttackComponent(
      gameManager,
      Sprite(attackImage),
      Vector2(gameManager.screenWidth * 0.9, gameManager.screenHeight * 0.8),
    );
    add(attackButton..positionType = PositionType.viewport);
  }

  Future<void> _loadBackground() async {
    final layers = gameManager.bgLayerInfo.entries.map(
          (entry) => loadParallaxLayer(
        ParallaxImageData(entry.key),
        velocityMultiplier: Vector2(entry.value, 0),
      ),
    );

    parallax = ParallaxComponent(
      parallax: Parallax(
        await Future.wait(layers),
        baseVelocity: Vector2(GameConstants.BACKGROUND_BASE_VELOCITY, 0),
      ),
    );

    parallax.parallax?.baseVelocity = Vector2.zero();
    add(parallax);
  }

  Future<void> _loadPlayer() async {
    await _animationManager.loadPlayerAnimations();

    adventurer = Adventurer(
      gameManager: gameManager,
      animations: {
        AdventurerAction.NORMAL: _animationManager.normalAnimation,
        AdventurerAction.RUN: _animationManager.runAnimation,
        AdventurerAction.BOW_ATTACK: _animationManager.bowAttackAni,
        AdventurerAction.SWORD_ATTACK_ONE: _animationManager.swordAttackAni_One,
        AdventurerAction.SWORD_ATTACK_TWO: _animationManager.swordAttackAni_Two,
        AdventurerAction.SWORD_ATTACK_THREE: _animationManager.swordAttackAni_Three,
      },
      current: AdventurerAction.NORMAL,
      position: Vector2(
          gameManager.screenWidth * GameConstants.SCREEN_OFFSET_X, 
          gameManager.screenHeight * GameConstants.SCREEN_OFFSET_Y),
      size: GameConstants.PLAYER_SIZE * 2,
    );

    add(adventurer);
  }

  Future<void> _loadMonster() async {
    await _animationManager.loadMonsterAnimations();

    monster = Monster(
      animations: {
        MonsterAction.NORMAL: _animationManager.monsterNormal,
        MonsterAction.WALK: _animationManager.monsterWalk,
        MonsterAction.ATTACK: _animationManager.monsterAttack,
        MonsterAction.DEATH: _animationManager.monsterDeath,
      },
      current: MonsterAction.NORMAL,
      position: Vector2(
          gameManager.screenWidth * 0.8, 
          gameManager.screenHeight * GameConstants.SCREEN_OFFSET_Y),
      size: GameConstants.MONSTER_SIZE * 2,
    );

    add(monster);
  }

  void _setupCamera() {
    camera.followComponent(adventurer, relativeOffset: const Anchor(0.3, 0.8));
  }

  void monsterUpdate() {
    final Iterable<Arrow> arrows = children.whereType<Arrow>();
    for (Arrow arrow in arrows) {
      if (arrow.isRemoving) {
        continue;
      }

      if (!monster.containsPoint(arrow.absoluteCenter)) {
        break;
      }
      arrow.removeFromParent();
      monster.loss(GameConstants.MONSTER_ARROW_DAMAGE);
    }
  }

  void swordAttack() {
    adventurer.animation!.reset();

    if (gameManager.nextAttackStep) {
      switch (adventurer.current) {
        case AdventurerAction.SWORD_ATTACK_ONE:
          adventurer.current = AdventurerAction.SWORD_ATTACK_TWO;
          break;
        case AdventurerAction.SWORD_ATTACK_TWO:
          adventurer.current = AdventurerAction.SWORD_ATTACK_THREE;
          break;
        case AdventurerAction.SWORD_ATTACK_THREE:
          adventurer.current = AdventurerAction.SWORD_ATTACK_ONE;
          break;
        default:
          adventurer.current = AdventurerAction.SWORD_ATTACK_ONE;
          break;
      }
      gameManager.nextAttackStep = false;
      return;
    }

    gameManager.isAttack = false;
  }

  void joystickMove(double playerVectorX, double playerVectorY, bool moveLeft, bool moveRight) {
    adventurer.current = AdventurerAction.RUN;

    if (moveRight) {
      adventurer.isFlipped = false;
    } else if (moveLeft) {
      adventurer.isFlipped = true;
    }

    if (moveLeft && adventurer.x > 0 && !gameManager.isLeftCollisionBlock) {
      adventurer.position.add(Vector2(playerVectorX, 0));
    }

    if (moveRight &&
        adventurer.x < size[0] &&
        !gameManager.isRightCollisionBlock) {
      adventurer.position.add(Vector2(playerVectorX, 0));
    }

    if (moveRight && gameManager.adventurerFlipped) {
      gameManager.adventurerFlipped = false;
      adventurer.flipHorizontallyAroundCenter();
    }

    if (moveLeft && !gameManager.adventurerFlipped) {
      gameManager.adventurerFlipped = true;
      adventurer.flipHorizontallyAroundCenter();
    }

    if (moveRight && !gameManager.isRightCollisionBlock) {
      parallax.parallax?.baseVelocity = Vector2(GameConstants.BACKGROUND_BASE_VELOCITY, 0);
    } else if (moveLeft && !gameManager.isLeftCollisionBlock) {
      parallax.parallax?.baseVelocity = Vector2(-GameConstants.BACKGROUND_BASE_VELOCITY, 0);
    } else {
      parallax.parallax?.baseVelocity = Vector2.zero();
    }
  }
}
