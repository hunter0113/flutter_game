import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/parallax.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/role/monster.dart';
import 'package:flutter_game/role/adventurer.dart';
import '../button/attackButton.dart';
import '../components/bullet.dart';
import '../manager/gamaManager.dart';

class StartGame extends FlameGame with HasDraggables, HasTappables, HasCollisionDetection, PanDetector {
  var backGroundBaseVelocity = 10.0;
  var playerSpeed = 120.0;
  int ZERO = 0;

  late final JoystickComponent joystick;
  late final AttackComponent attackButton;
  static late ParallaxComponent parallax;
  static late Adventurer adventurer;
  static late Monster monster;
  static late SpriteSheet allSpriteSheet,
      monster_normal_Sheet,
      monster_walk_Sheet,
      monster_attack_Sheet,
      monster_death_Sheet;

  late GameAnimationManager gameManager;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    gameManager = GameAnimationManager();

    await _loadBackground();
    await _loadPlayer();
    await _loadMonster();
    _setupCamera();
    _setupJoystickAndButton();
  }

  @override
  void update(double dt) {
    super.update(dt);

    bool moveLeft = joystick.relativeDelta[0] < ZERO;
    bool moveRight = joystick.relativeDelta[0] > ZERO;

    double playerVectorX = (joystick.relativeDelta * (playerSpeed * 1.2) * dt)[0];
    double playerVectorY = (joystick.relativeDelta * (playerSpeed * 1.2) * dt)[1];

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

    // 透過joystick 讓角色進行x軸上的位移
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
    final knobPaint = BasicPalette.white.withAlpha(200).paint();
    final backgroundPaint = BasicPalette.white.withAlpha(100).paint();
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 24, paint: knobPaint),
      background: CircleComponent(radius: 50, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 30, bottom: 40),
    );
    add(joystick);

    const String attackSrc = 'attack.png';
    await images.load(attackSrc);
    var attackImage = images.fromCache(attackSrc);
    attackButton = AttackComponent(gameManager, Sprite(attackImage),
        Vector2(gameManager.screenWidth * 0.9, gameManager.screenHeight * 0.8));
    add(attackButton..positionType = PositionType.viewport);
  }

  Future<void> _loadBackground() async {
    // 設置背景層
    final layers = gameManager.bgLayerInfo.entries.map(
          (entry) => loadParallaxLayer(
        ParallaxImageData(entry.key),
        velocityMultiplier: Vector2(entry.value, 0),
      ),
    );

    parallax = ParallaxComponent(
      parallax: Parallax(
        await Future.wait(layers),
        baseVelocity: Vector2(backGroundBaseVelocity, 0),
      ),
    );

    parallax.parallax?.baseVelocity = Vector2.zero();
    add(parallax);
  }

  Future<void> _loadPlayer() async {
    // 設置玩家角色動畫
    const String src = 'player.png';
    await images.load(src);
    var image = images.fromCache(src);
    allSpriteSheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 7,
      rows: 18,
    );

    List<Sprite> normalSprites = allSpriteSheet.getRowSprites(
        row: ZERO, start: ZERO, count: 4);
    gameManager.normalAnimation = SpriteAnimation.spriteList(
      normalSprites,
      stepTime: 0.2,
      loop: true,
    );

    List<Sprite> attackSprites_One = allSpriteSheet.getRowSprites(
        row: 6, start: ZERO, count: 6);
    gameManager.swordAttackAni_One = SpriteAnimation.spriteList(
      attackSprites_One,
      stepTime: 0.08,
      loop: false,
    );

    List<Sprite> attackSprites_Two = allSpriteSheet.getRowSprites(
        row: 7, start: ZERO, count: 4);
    gameManager.swordAttackAni_Two = SpriteAnimation.spriteList(
      attackSprites_Two,
      stepTime: 0.08,
      loop: false,
    );

    List<Sprite> attackSprites_Three = allSpriteSheet.getRowSprites(
        row: 7, start: 4, count: 3);
    attackSprites_Three.addAll(
        allSpriteSheet.getRowSprites(row: 8, start: ZERO, count: 3));
    gameManager.swordAttackAni_Three = SpriteAnimation.spriteList(
      attackSprites_Three,
      stepTime: 0.08,
      loop: false,
    );

    const String bowSrc = 'bow_attack.png';
    await images.load(bowSrc);
    var bowImage = images.fromCache(bowSrc);
    SpriteSheet bowSheet = SpriteSheet.fromColumnsAndRows(
      image: bowImage,
      columns: 4,
      rows: 4,
    );

    List<Sprite> bowSprites = bowSheet.getRowSprites(
        row: ZERO, start: ZERO, count: 4);
    bowSprites.addAll(bowSheet.getRowSprites(row: 1, start: ZERO, count: 4));
    bowSprites.addAll(bowSheet.getRowSprites(row: 2, start: ZERO, count: 1));
    gameManager.bowAttackAni = SpriteAnimation.spriteList(
      bowSprites,
      stepTime: 0.1,
      loop: false,
    );

    const String runSrc = 'run.png';
    await images.load(runSrc);
    var runImage = images.fromCache(runSrc);
    SpriteSheet runSheet = SpriteSheet.fromColumnsAndRows(
      image: runImage,
      columns: 6,
      rows: 1,
    );

    List<Sprite> runSprites = runSheet.getRowSprites(
        row: ZERO, start: ZERO, count: 6);
    gameManager.runAnimation = SpriteAnimation.spriteList(
      runSprites,
      stepTime: 0.1,
      loop: true,
    );

    adventurer = Adventurer(
      gameManager: gameManager,
      animations: {
        AdventurerAction.NORMAL: gameManager.normalAnimation,
        AdventurerAction.RUN: gameManager.runAnimation,
        AdventurerAction.BOW_ATTACK: gameManager.bowAttackAni,
        AdventurerAction.SWORD_ATTACK_ONE: gameManager.swordAttackAni_One,
        AdventurerAction.SWORD_ATTACK_TWO: gameManager.swordAttackAni_Two,
        AdventurerAction.SWORD_ATTACK_THREE: gameManager.swordAttackAni_Three,
      },
      current: AdventurerAction.NORMAL,
      position: Vector2(
          gameManager.screenWidth * 0.3, gameManager.screenHeight * 0.8),
      size: Vector2(50, 37) * 2,
    );

    add(adventurer);
  }

  Future<void> _loadMonster() async {
    // 設置怪物角色動畫
    const String monster_normal_Src = 'monster_normal.png';
    await images.load(monster_normal_Src);
    var monster_normal_Image = images.fromCache(monster_normal_Src);
    monster_normal_Sheet = SpriteSheet.fromColumnsAndRows(
      image: monster_normal_Image,
      columns: 10,
      rows: 1,
    );

    List<Sprite> monster_normal_Sprites = monster_normal_Sheet.getRowSprites(
        row: ZERO, start: ZERO, count: 10);
    gameManager.monsterNormal = SpriteAnimation.spriteList(
      monster_normal_Sprites,
      stepTime: 0.1,
      loop: true,
    );

    const String monster_walk_Src = 'monster_walk.png';
    await images.load(monster_walk_Src);
    var monster_walk_Image = images.fromCache(monster_walk_Src);
    monster_walk_Sheet = SpriteSheet.fromColumnsAndRows(
      image: monster_walk_Image,
      columns: 9,
      rows: 1,
    );

    List<Sprite> monster_walk_Sprites = monster_walk_Sheet.getRowSprites(
        row: ZERO, start: ZERO, count: 9);
    gameManager.monsterWalk = SpriteAnimation.spriteList(
      monster_walk_Sprites,
      stepTime: 0.1,
      loop: true,
    );

    const String monster_attack_Src = 'monster_attack.png';
    await images.load(monster_attack_Src);
    var monster_attack_Image = images.fromCache(monster_attack_Src);
    monster_attack_Sheet = SpriteSheet.fromColumnsAndRows(
      image: monster_attack_Image,
      columns: 12,
      rows: 1,
    );

    List<Sprite> monster_attack_Sprites = monster_attack_Sheet.getRowSprites(
        row: ZERO, start: ZERO, count: 12);
    gameManager.monsterAttack = SpriteAnimation.spriteList(
      monster_attack_Sprites,
      stepTime: 0.1,
      loop: true,
    );

    const String monster_death_Src = 'monster_death.png';
    await images.load(monster_death_Src);
    var monster_death_Image = images.fromCache(monster_death_Src);
    monster_death_Sheet = SpriteSheet.fromColumnsAndRows(
      image: monster_death_Image,
      columns: 14,
      rows: 1,
    );

    List<Sprite> monster_death_Sprites = monster_death_Sheet.getRowSprites(
        row: ZERO, start: ZERO, count: 12);
    gameManager.monsterDeath = SpriteAnimation.spriteList(
      monster_death_Sprites,
      stepTime: 0.1,
      loop: false,
    );

    monster = Monster(
      animations: {
        MonsterAction.NORMAL: gameManager.monsterNormal,
        MonsterAction.WALK: gameManager.monsterWalk,
        MonsterAction.ATTACK: gameManager.monsterAttack,
        MonsterAction.DEATH: gameManager.monsterDeath,
      },
      current: MonsterAction.NORMAL,
      position: Vector2(
          gameManager.screenWidth * 0.8, gameManager.screenHeight * 0.8),
      size: Vector2(48, 37) * 2,
    );

    add(monster);
  }

  void _setupCamera() {
    // 設置攝像機跟隨
    camera.followComponent(adventurer, relativeOffset: const Anchor(0.3, 0.8));
  }

  void monsterUpdate() {
    final Iterable<Bullet> bullets = children.whereType<Bullet>();
    for (Bullet bullet in bullets) {
      if (bullet.isRemoving) {
        continue;
      }

      if (!monster.containsPoint(bullet.absoluteCenter)) {
        break;
      }
      bullet.removeFromParent();
      monster.loss(200);
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

    if (moveLeft && adventurer.x > 0 && !gameManager.isLeftCollisionBlock) {
      adventurer.position.add(Vector2(playerVectorX, 0));
    }

    if (moveRight &&
        adventurer.x < size[0] &&
        !gameManager.isRightCollisionBlock) {
      adventurer.position.add(Vector2(playerVectorX, 0));
    }

    // 角色左右翻轉
    if (moveRight && gameManager.adventurerFlipped) {
      gameManager.adventurerFlipped = false;
      adventurer.flipHorizontallyAroundCenter();
    }

    if (moveLeft && !gameManager.adventurerFlipped) {
      gameManager.adventurerFlipped = true;
      adventurer.flipHorizontallyAroundCenter();
    }

    // 背景左右翻轉
    if (moveRight && !gameManager.isRightCollisionBlock) {
      parallax.parallax?.baseVelocity = Vector2(backGroundBaseVelocity, 0);
    } else if (moveLeft && !gameManager.isLeftCollisionBlock) {
      parallax.parallax?.baseVelocity = Vector2(-backGroundBaseVelocity, 0);
    } else {
      parallax.parallax?.baseVelocity = Vector2.zero();
    }
  }
}

// Extension SpriteSheet
extension SpriteSheetExt on SpriteSheet {
  /// 獲得指定索引區間 [Sprite] 列表
  /// [row] : 第幾行
  /// [start] : 第幾個開始
  /// [count] : 有幾個
  List<Sprite> getRowSprites({
    required int row,
    int start = 0,
    required count,
  }) {
    return List.generate(count, (i) => getSprite(row, start + i)).toList();
  }
}
