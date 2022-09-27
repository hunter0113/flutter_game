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

class StartGame extends FlameGame with HasDraggables, HasTappables, HasCollisionDetection, PanDetector {
  @override
  Future<void> onLoad() async {
    super.onLoad();

    /**
     * BackGround
     */
    final layers = GameManager.bgLayerInfo.entries.map(
      (entry) => loadParallaxLayer(
        ParallaxImageData(entry.key),
        velocityMultiplier: Vector2(entry.value, 0.0),
      ),
    );

    GameManager.parallax = ParallaxComponent(
      parallax: Parallax(
        await Future.wait(layers),
        baseVelocity: Vector2(5, 0),
      ),
    );

    GameManager.parallax.parallax?.baseVelocity = Vector2.zero();
    add(GameManager.parallax);

    /**
     * Hero
     */
    const String src = 'hero.png';
    await images.load(src);
    var image = images.fromCache(src);
    GameManager.allSpriteSheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 7,
      rows: 18,
    );

    // 待機狀態
    List<Sprite> normalSprites =
        GameManager.allSpriteSheet.getRowSprites(row: 0, start: 0, count: 4);
    GameManager.normalAnimation = SpriteAnimation.spriteList(
      normalSprites,
      stepTime: 0.2,
      loop: true,
    );

    // 攻擊
    List<Sprite> attackSprites_One =
        GameManager.allSpriteSheet.getRowSprites(row: 6, start: 0, count: 6);
    GameManager.attackAniStage_One = SpriteAnimation.spriteList(
      attackSprites_One,
      stepTime: 0.1,
      loop: false,
    );

    List<Sprite> attackSprites_Two =
        GameManager.allSpriteSheet.getRowSprites(row: 7, start: 0, count: 4);
    GameManager.attackAniStage_Two = SpriteAnimation.spriteList(
      attackSprites_Two,
      stepTime: 0.1,
      loop: false,
    );

    List<Sprite> attackSprites_Three =
        GameManager.allSpriteSheet.getRowSprites(row: 7, start: 4, count: 3);
    attackSprites_Three.addAll(GameManager.allSpriteSheet.getRowSprites(row: 8, start: 0, count: 3));
    GameManager.attackAniStage_Three = SpriteAnimation.spriteList(
      attackSprites_Three,
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
        runSheet.getRowSprites(row: 0, start: 0, count: 6);
    GameManager.runAnimation = SpriteAnimation.spriteList(
      runSprites,
      stepTime: 0.1,
      loop: true,
    );

    /**
     * Player
     */
    GameManager.player = Player(
      animations: {
        PlayerAction.Normal: GameManager.normalAnimation,
        PlayerAction.Run: GameManager.runAnimation,
        PlayerAction.Attack_One: GameManager.attackAniStage_One,
        PlayerAction.Attack_Two: GameManager.attackAniStage_Two,
        PlayerAction.Attack_Three: GameManager.attackAniStage_Three,
      },
      current: PlayerAction.Normal,
      position: Vector2(
          GameManager.screenWidth * 0.3, GameManager.screenHeight * 0.8),
      size: Vector2(50, 37) * 2,
    );

    add(GameManager.player);


    /**
     * Monster
     */
    const String monster_normal_Src = 'monster_normal.png';
    await images.load(monster_normal_Src);
    var monster_normal_Image = images.fromCache(monster_normal_Src);
    GameManager.monster_normal_Sheet = SpriteSheet.fromColumnsAndRows(
      image: monster_normal_Image,
      columns: 10,
      rows: 1,
    );

    // 待機狀態
    List<Sprite> monster_normal_Sprites =
    GameManager.monster_normal_Sheet.getRowSprites(row: 0, start: 0, count: 10);
    GameManager.monsterNormal = SpriteAnimation.spriteList(
      monster_normal_Sprites,
      stepTime: 0.1,
      loop: true,
    );

    const String monster_walk_Src = 'monster_walk.png';
    await images.load(monster_walk_Src);
    var monster_walk_Image = images.fromCache(monster_walk_Src);
    GameManager.monster_walk_Sheet = SpriteSheet.fromColumnsAndRows(
      image: monster_walk_Image,
      columns: 9,
      rows: 1,
    );

    // 走路
    List<Sprite> monster_walk_Sprites =
    GameManager.monster_walk_Sheet.getRowSprites(row: 0, start: 0, count: 9);
    GameManager.monsterWalk = SpriteAnimation.spriteList(
      monster_walk_Sprites,
      stepTime: 0.1,
      loop: true,
    );


    const String monster_attack_Src = 'monster_attack.png';
    await images.load(monster_attack_Src);
    var monster_attack_Image = images.fromCache(monster_attack_Src);
    GameManager.monster_attack_Sheet = SpriteSheet.fromColumnsAndRows(
      image: monster_attack_Image,
      columns: 12,
      rows: 1,
    );

    // 攻擊
    List<Sprite> monster_attack_Sprites =
    GameManager.monster_attack_Sheet.getRowSprites(row: 0, start: 0, count: 12);
    GameManager.monsterAttack = SpriteAnimation.spriteList(
      monster_attack_Sprites,
      stepTime: 0.1,
      loop: true,
    );


    /**
     * Monster
     */
    GameManager.monster = Monster(
      animations: {
        MonsterAction.Normal: GameManager.monsterNormal,
        MonsterAction.Walk: GameManager.monsterWalk,
        MonsterAction.Attack: GameManager.monsterAttack,
      },
      current: MonsterAction.Attack,
      position: Vector2(
          GameManager.screenWidth * 0.8, GameManager.screenHeight * 0.8),
      size: Vector2(50, 37) * 2,
    );

    add(GameManager.monster);


    // 焦點
    camera.followComponent(GameManager.player,
        relativeOffset: const Anchor(0.3, 0.8));

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

    Player player = GameManager.player;

    bool moveLeft = GameManager.joystick.relativeDelta[0] < 0;
    bool moveRight = GameManager.joystick.relativeDelta[0] > 0;

    double playerVectorX = (GameManager.joystick.relativeDelta * 300 * dt)[0];
    double playerVectorY = (GameManager.joystick.relativeDelta * 300 * dt)[1];

    if ((player.current == PlayerAction.Attack_One ||
            player.current == PlayerAction.Attack_Two ||
            player.current == PlayerAction.Attack_Three) &&
        player.animation!.done()) {
      player.animation!.reset();

      if(GameManager.nextAttackStep){
        switch (GameManager.player.current) {
          case PlayerAction.Attack_One:
            GameManager.player.current = PlayerAction.Attack_Two;
            break;

          case PlayerAction.Attack_Two:
            GameManager.player.current = PlayerAction.Attack_Three;
            break;

          case PlayerAction.Attack_Three:
            GameManager.player.current = PlayerAction.Attack_One;
            break;

          default:
            GameManager.player.current = PlayerAction.Attack_One;
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
      player.current = PlayerAction.Run;

      if ((moveLeft && player.x > 0) || (moveRight && player.x < size[0])) {
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
      if (moveRight) {
        GameManager.parallax.parallax?.baseVelocity = Vector2(10, 0);
        return;
      }
      GameManager.parallax.parallax?.baseVelocity = Vector2(-10, 0);
      return;
    }

    if (!GameManager.isAttack) {
      // 不動
      player.current = PlayerAction.Normal;
      GameManager.parallax.parallax?.baseVelocity = Vector2.zero();
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
