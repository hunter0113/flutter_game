import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/parallax.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/manager/gamaManager.dart';
import 'package:flutter_game/role/monster.dart';
import 'package:flutter_game/role/player.dart';
import '../button/attackButton.dart';
import '../component/bullet.dart';

class StartGame extends FlameGame
    with HasDraggables, HasTappables, HasCollisionDetection, PanDetector {
  var backGroundBaseVelocity = 3.0;
  var playerSpeed = 150.0;
  int ZERO = 0;

  static late ParallaxComponent parallax;
  static late Player player;
  static late Monster monster;
  static late SpriteSheet allSpriteSheet,
      monster_normal_Sheet,
      monster_walk_Sheet,
      monster_attack_Sheet,
      monster_death_Sheet;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    /**
     * BackGround
     */
    final layers = GameManager.bgLayerInfo.entries.map(
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

    /**
     * Player
     */
    const String src = 'player.png';
    await images.load(src);
    var image = images.fromCache(src);
    allSpriteSheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 7,
      rows: 18,
    );

    // 待機狀態
    List<Sprite> normalSprites =
        allSpriteSheet.getRowSprites(row: ZERO, start: ZERO, count: 4);
    GameManager.normalAnimation = SpriteAnimation.spriteList(
      normalSprites,
      stepTime: 0.2,
      loop: true,
    );

    // 劍攻擊
    List<Sprite> attackSprites_One =
        allSpriteSheet.getRowSprites(row: 6, start: ZERO, count: 6);
    GameManager.swordAttackAni_One = SpriteAnimation.spriteList(
      attackSprites_One,
      stepTime: 0.08,
      loop: false,
    );

    List<Sprite> attackSprites_Two =
        allSpriteSheet.getRowSprites(row: 7, start: ZERO, count: 4);
    GameManager.swordAttackAni_Two = SpriteAnimation.spriteList(
      attackSprites_Two,
      stepTime: 0.08,
      loop: false,
    );

    List<Sprite> attackSprites_Three =
        allSpriteSheet.getRowSprites(row: 7, start: 4, count: 3);
    attackSprites_Three
        .addAll(allSpriteSheet.getRowSprites(row: 8, start: ZERO, count: 3));
    GameManager.swordAttackAni_Three = SpriteAnimation.spriteList(
      attackSprites_Three,
      stepTime: 0.08,
      loop: false,
    );

    // 弓攻擊
    const String bowSrc = 'bow_attack.png';
    await images.load(bowSrc);
    var bowImage = images.fromCache(bowSrc);
    SpriteSheet bowSheet = SpriteSheet.fromColumnsAndRows(
      image: bowImage,
      columns: 4,
      rows: 4,
    );

    List<Sprite> bowSprites =
        bowSheet.getRowSprites(row: ZERO, start: ZERO, count: 4);
    bowSprites.addAll(bowSheet.getRowSprites(row: 1, start: ZERO, count: 4));
    bowSprites.addAll(bowSheet.getRowSprites(row: 2, start: ZERO, count: 1));
    GameManager.bowAttackAni = SpriteAnimation.spriteList(
      bowSprites,
      stepTime: 0.1,
      loop: false,
    );

    // 跑步
    const String runSrc = 'run.png';
    await images.load(runSrc);
    var runImage = images.fromCache(runSrc);
    SpriteSheet runSheet = SpriteSheet.fromColumnsAndRows(
      image: runImage,
      columns: 6,
      rows: 1,
    );

    List<Sprite> runSprites =
        runSheet.getRowSprites(row: ZERO, start: ZERO, count: 6);
    GameManager.runAnimation = SpriteAnimation.spriteList(
      runSprites,
      stepTime: 0.1,
      loop: true,
    );

    /**
     * Player
     */
    player = Player(
      animations: {
        PlayerAction.NORMAL: GameManager.normalAnimation,
        PlayerAction.RUN: GameManager.runAnimation,
        PlayerAction.BOW_ATTACK: GameManager.bowAttackAni,
        PlayerAction.SWORD_ATTACK_ONE: GameManager.swordAttackAni_One,
        PlayerAction.SWORD_ATTACK_TWO: GameManager.swordAttackAni_Two,
        PlayerAction.SWORD_ATTACK_THREE: GameManager.swordAttackAni_Three,
      },
      current: PlayerAction.NORMAL,
      position: Vector2(
          GameManager.screenWidth * 0.3, GameManager.screenHeight * 0.8),
      size: Vector2(50, 37) * 2,
    );

    add(player);

    /**
     * Monster
     */
    const String monster_normal_Src = 'monster_normal.png';
    await images.load(monster_normal_Src);
    var monster_normal_Image = images.fromCache(monster_normal_Src);
    monster_normal_Sheet = SpriteSheet.fromColumnsAndRows(
      image: monster_normal_Image,
      columns: 10,
      rows: 1,
    );

    // 待機狀態
    List<Sprite> monster_normal_Sprites =
        monster_normal_Sheet.getRowSprites(row: ZERO, start: ZERO, count: 10);
    GameManager.monsterNormal = SpriteAnimation.spriteList(
      monster_normal_Sprites,
      stepTime: 0.1,
      loop: true,
    );

    // 走路
    const String monster_walk_Src = 'monster_walk.png';
    await images.load(monster_walk_Src);
    var monster_walk_Image = images.fromCache(monster_walk_Src);
    monster_walk_Sheet = SpriteSheet.fromColumnsAndRows(
      image: monster_walk_Image,
      columns: 9,
      rows: 1,
    );

    List<Sprite> monster_walk_Sprites =
        monster_walk_Sheet.getRowSprites(row: ZERO, start: ZERO, count: 9);
    GameManager.monsterWalk = SpriteAnimation.spriteList(
      monster_walk_Sprites,
      stepTime: 0.1,
      loop: true,
    );

    // 攻擊
    const String monster_attack_Src = 'monster_attack.png';
    await images.load(monster_attack_Src);
    var monster_attack_Image = images.fromCache(monster_attack_Src);
    monster_attack_Sheet = SpriteSheet.fromColumnsAndRows(
      image: monster_attack_Image,
      columns: 12,
      rows: 1,
    );

    List<Sprite> monster_attack_Sprites =
        monster_attack_Sheet.getRowSprites(row: ZERO, start: ZERO, count: 12);
    GameManager.monsterAttack = SpriteAnimation.spriteList(
      monster_attack_Sprites,
      stepTime: 0.1,
      loop: true,
    );

    // 死去
    const String monster_death_Src = 'monster_death.png';
    await images.load(monster_death_Src);
    var monster_death_Image = images.fromCache(monster_death_Src);
    monster_death_Sheet = SpriteSheet.fromColumnsAndRows(
      image: monster_death_Image,
      columns: 14,
      rows: 1,
    );

    List<Sprite> monster_death_Sprites =
        monster_death_Sheet.getRowSprites(row: ZERO, start: ZERO, count: 12);
    GameManager.monsterDeath = SpriteAnimation.spriteList(
      monster_death_Sprites,
      stepTime: 0.1,
      loop: false,
    );

    /**
     * Monster
     */
    monster = Monster(
      animations: {
        MonsterAction.NORMAL: GameManager.monsterNormal,
        MonsterAction.WALK: GameManager.monsterWalk,
        MonsterAction.ATTACK: GameManager.monsterAttack,
        MonsterAction.DEATH: GameManager.monsterDeath,
      },
      current: MonsterAction.NORMAL,
      position: Vector2(
          GameManager.screenWidth * 0.8, GameManager.screenHeight * 0.8),
      size: Vector2(48, 37) * 2,
    );

    add(monster);

    // 焦點
    camera.followComponent(player, relativeOffset: const Anchor(0.3, 0.8));

    /**
     * JoyStick
     */
    final knobPaint = BasicPalette.white.withAlpha(200).paint();
    final backgroundPaint = BasicPalette.white.withAlpha(100).paint();
    GameManager.joystick = JoystickComponent(
      knob: CircleComponent(radius: 24, paint: knobPaint),
      background: CircleComponent(radius: 50, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 30, bottom: 40),
    );
    add(GameManager.joystick);

    const String attackSrc = 'attack.png';
    await images.load(attackSrc);
    var attackImage = images.fromCache(attackSrc);
    GameManager.attackButton = AttackComponent(Sprite(attackImage),
        Vector2(GameManager.screenWidth * 0.9, GameManager.screenHeight * 0.8));
    add(GameManager.attackButton..positionType = PositionType.viewport);
  }

  @override
  void update(double dt) {
    super.update(dt);

    bool moveLeft = GameManager.joystick.relativeDelta[0] < ZERO;
    bool moveRight = GameManager.joystick.relativeDelta[0] > ZERO;

    double playerVectorX =
        (GameManager.joystick.relativeDelta * playerSpeed * dt)[0];
    double playerVectorY =
        (GameManager.joystick.relativeDelta * playerSpeed * dt)[1];

    if (monster.current == MonsterAction.DEATH && monster.animation!.done()) {
      monster.removeFromParent();
    }

    if (monster.life > 0) {
      final Iterable<Bullet> bullets = children.whereType<Bullet>();
      for (Bullet bullet in bullets) {
        if (bullet.isRemoving) {
          continue;
        }
        if (monster.containsPoint(bullet.absoluteCenter)) {
          bullet.removeFromParent();
          monster.loss(100);
          break;
        }
      }
      if (GameManager.isAttack &&
          (GameManager.isRightCollisionBlock ||
              GameManager.isLeftCollisionBlock) &&
          !GameManager.causeDamage) {
        GameManager.causeDamage = true;
        monster.loss(100);
      }
    }

    if ((GameManager.isAttack) && player.animation!.done()) {
      player.animation!.reset();
      GameManager.causeDamage = false;

      if (GameManager.nextAttackStep) {
        switch (player.current) {
          case PlayerAction.SWORD_ATTACK_ONE:
            player.current = PlayerAction.SWORD_ATTACK_TWO;
            break;

          case PlayerAction.SWORD_ATTACK_TWO:
            player.current = PlayerAction.SWORD_ATTACK_THREE;
            break;

          case PlayerAction.SWORD_ATTACK_THREE:
            player.current = PlayerAction.SWORD_ATTACK_ONE;
            break;

          default:
            player.current = PlayerAction.SWORD_ATTACK_ONE;
            break;
        }
        GameManager.nextAttackStep = false;
        return;
      }

      GameManager.isAttack = false;
      return;
    }

    if (GameManager.isAttack) {
      return;
    }

    // 透過joystick 讓角色進行x軸上的位移
    if (!GameManager.joystick.delta.isZero()) {
      player.current = PlayerAction.RUN;

      if (moveLeft && player.x > 0 && !GameManager.isLeftCollisionBlock) {
        player.position.add(Vector2(playerVectorX, 0));
      }

      if (moveRight &&
          player.x < size[0] &&
          !GameManager.isRightCollisionBlock) {
        player.position.add(Vector2(playerVectorX, 0));
      }

      // 角色左右翻轉
      if (moveRight && GameManager.playerFlipped) {
        GameManager.playerFlipped = false;
        player.flipHorizontallyAroundCenter();
      }

      if (moveLeft && !GameManager.playerFlipped) {
        GameManager.playerFlipped = true;
        player.flipHorizontallyAroundCenter();
      }

      // 背景左右翻轉
      if (moveRight && !GameManager.isRightCollisionBlock) {
        parallax.parallax?.baseVelocity = Vector2(backGroundBaseVelocity, 0);
      } else if (moveLeft && !GameManager.isLeftCollisionBlock) {
        parallax.parallax?.baseVelocity = Vector2(-backGroundBaseVelocity, 0);
      } else {
        parallax.parallax?.baseVelocity = Vector2.zero();
      }
      return;
    }

    if (!GameManager.isAttack) {
      player.current = PlayerAction.NORMAL;
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
