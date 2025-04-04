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
import '../manager/input_manager.dart';
import '../manager/asset_load_manager.dart';
import '../service/asset_service.dart';
import '../states/monster_state.dart';
import '../states/player_state.dart';

class StartGame extends FlameGame with HasDraggables, HasTappables, HasCollisionDetection, PanDetector {
  static late ParallaxComponent parallax;
  static late Adventurer adventurer;
  static late Monster monster;

  late GameManager gameManager;
  late AssetService _assetService;
  late AnimationManager _animationManager;
  late InputManager _inputManager;
  late AssetLoadManager _assetLoadManager;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    gameManager = GameManager();
    _assetService = AssetService(images);
    _animationManager = AnimationManager(_assetService);
    _inputManager = InputManager(
      gameManager: gameManager,
      assetService: _assetService,
    );
    _assetLoadManager = AssetLoadManager(
      gameManager: gameManager,
      assetService: _assetService,
      animationManager: _animationManager,
    );

    try {
      await _assetService.loadAllAssets();
      await _loadBackground();
      await _loadGameAssets();
      _setupCamera();
      _setupJoystickAndButton();
    } catch (e) {
      print('遊戲初始化失敗: $e');
    }
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

  Future<void> _loadGameAssets() async {
    adventurer = await _assetLoadManager.loadPlayer();
    add(adventurer);

    monster = await _assetLoadManager.loadMonster();
    add(monster);
  }

  @override
  void update(double dt) {
    super.update(dt);

    bool moveLeft = _inputManager.joystick.relativeDelta[0] < 0;
    bool moveRight = _inputManager.joystick.relativeDelta[0] > 0;

    double playerVectorX = (_inputManager.joystick.relativeDelta * (GameConstants.player.speed * 1.2) * dt)[0];
    double playerVectorY = (_inputManager.joystick.relativeDelta * (GameConstants.player.speed * 1.2) * dt)[1];

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

    if (!_inputManager.joystick.delta.isZero()) {
      joystickMove(playerVectorX, playerVectorY, moveLeft, moveRight);
      return;
    }

    adventurer.current = AdventurerAction.normal;
    parallax.parallax?.baseVelocity = Vector2.zero();
  }

  void _setupJoystickAndButton() {
    _inputManager.setupJoystickAndButton();
    add(_inputManager.joystick);
    add(_inputManager.attackButton..positionType = PositionType.viewport);
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
