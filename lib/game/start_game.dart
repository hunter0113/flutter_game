import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/parallax.dart';

import 'package:flutter_game/role/monster.dart';
import 'package:flutter_game/role/adventurer.dart';
import '../button/attack_button.dart';
import '../components/arrow.dart';
import '../manager/game_manager.dart';
import '../constants/game_constants.dart';
import '../manager/animation_manager.dart';
import '../service/asset_service.dart';

class StartGame extends FlameGame with HasDraggables, HasTappables, HasCollisionDetection, PanDetector {
  late final JoystickComponent joystick;
  late final AttackButton attackButton;
  static late ParallaxComponent parallax;
  static late Adventurer adventurer;
  static late Monster monster;

  late GameManager gameManager;
  late AssetService _assetService;
  late AnimationManager _animationManager;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    gameManager = GameManager();
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

    double playerVectorX = (joystick.relativeDelta * (GameConstants.player.speed * 1.2) * dt)[0];
    double playerVectorY = (joystick.relativeDelta * (GameConstants.player.speed  * 1.2) * dt)[1];

    if (monster.current == MonsterAction.death && monster.animation!.done()) {
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
    adventurer.current = AdventurerAction.normal;
    parallax.parallax?.baseVelocity = Vector2.zero();
  }

  void _setupJoystickAndButton() async {
    final knobPaint = BasicPalette.white.withAlpha((GameConstants.ui.joystickAlpha * 255).toInt()).paint();
    final backgroundPaint = BasicPalette.white.withAlpha((GameConstants.ui.joystickBackgroundAlpha * 255).toInt()).paint();
    joystick = JoystickComponent(
      knob: CircleComponent(radius: GameConstants.ui.joystickKnobRadius, paint: knobPaint),
      background: CircleComponent(radius: GameConstants.ui.joystickBackgroundRadius, paint: backgroundPaint),
      margin: GameConstants.ui.joystickMargin,
    );
    add(joystick);

    final attackImage = _assetService.getImage('ui', 'attack');
    attackButton = AttackButton(
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
        baseVelocity: Vector2(GameConstants.settings.backgroundBaseVelocity, 0),
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
        AdventurerAction.normal: _animationManager.normalAnimation,
        AdventurerAction.run: _animationManager.runAnimation,
        AdventurerAction.bowAttack: _animationManager.bowAttackAnimation,
        AdventurerAction.swordAttack: _animationManager.swordAttackAnimationOne,
        AdventurerAction.swordAttackTwo: _animationManager.swordAttackAnimationTwo,
        AdventurerAction.swordAttackThree: _animationManager.swordAttackAnimationThree,
      },
      current: AdventurerAction.normal,
      position: Vector2(
          gameManager.screenWidth * GameConstants.settings.screenOffsetX,
          gameManager.screenHeight * GameConstants.settings.screenOffsetY),
      size: GameConstants.player.size * 2,
    );

    add(adventurer);
  }

  Future<void> _loadMonster() async {
    await _animationManager.loadMonsterAnimations();

    monster = Monster(
      animations: {
        MonsterAction.normal: _animationManager.monsterNormal,
        MonsterAction.walk: _animationManager.monsterWalk,
        MonsterAction.attack: _animationManager.monsterAttack,
        MonsterAction.death: _animationManager.monsterDeath,
      },
      current: MonsterAction.normal,
      position: Vector2(
          gameManager.screenWidth * 0.8, 
          gameManager.screenHeight * GameConstants.settings.screenOffsetY),
      size: GameConstants.monster.size * 2,
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
      monster.loss(GameConstants.monster.arrowDamage);
    }
  }

  void swordAttack() {
    adventurer.animation!.reset();

    if (gameManager.nextAttackStep) {
      switch (adventurer.current) {
        case AdventurerAction.swordAttack:
          adventurer.current = AdventurerAction.swordAttackTwo;
          break;
        case AdventurerAction.swordAttackTwo:
          adventurer.current = AdventurerAction.swordAttackThree;
          break;
        case AdventurerAction.swordAttackThree:
          adventurer.current = AdventurerAction.swordAttack;
          break;
        default:
          adventurer.current = AdventurerAction.swordAttack;
          break;
      }
      gameManager.nextAttackStep = false;
      return;
    }

    gameManager.isAttack = false;
  }

  void joystickMove(double playerVectorX, double playerVectorY, bool moveLeft, bool moveRight) {
    adventurer.current = AdventurerAction.run;

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
      parallax.parallax?.baseVelocity = Vector2(GameConstants.settings.backgroundBaseVelocity, 0);
    } else if (moveLeft && !gameManager.isLeftCollisionBlock) {
      parallax.parallax?.baseVelocity = Vector2(-GameConstants.settings.backgroundBaseVelocity, 0);
    } else {
      parallax.parallax?.baseVelocity = Vector2.zero();
    }
  }
}
