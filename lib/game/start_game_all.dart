import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/parallax.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/role/player.dart';


class StartGame extends FlameGame with HasDraggables, HasTappables {
  final double screenWidth = MediaQueryData.fromWindow(window).size.width;
  final double screenHeight = MediaQueryData.fromWindow(window).size.height;

  late final JoystickComponent joystick;
  late Player player;
  late ParallaxComponent parallax;
  late final SpriteAnimation normalAnimation, attackAnimation, runAnimation;
  bool playerFlipped = false;

  // 背景與x座標軸上的速度
  final bgLayerInfo = {
    'background_11.png': 0.5,
    'background_10.png': 0.75,
    'background_9.png': 1.0,
    'background_8.png': 1.25,
    'background_7.png': 1.5,
    'background_6.png': 1.75,
    'background_5.png': 2.0,
    'background_4.png': 2.25,
    'background_3.png': 2.5,
    'background_2.png': 2.75,
    'background_1.png': 3.0,
    'background_0.png': 3.25,
  };

  @override
  Future<void> onLoad() async {
    super.onLoad();

    /**
     * BackGround
     */
    final layers = bgLayerInfo.entries.map(
      (entry) => loadParallaxLayer(
        ParallaxImageData(entry.key),
        velocityMultiplier: Vector2(entry.value, 0.0),
      ),
    );

    parallax = ParallaxComponent(
      parallax: Parallax(
        await Future.wait(layers),
        baseVelocity: Vector2(5, 0),
      ),
    );
    parallax.parallax?.baseVelocity = Vector2.zero();
    add(parallax);

    // All Image
    const String src = 'hero.png';
    await images.load(src);
    var image = images.fromCache(src);
    SpriteSheet sheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 7,
      rows: 18,
    );

    // 待機狀態
    List<Sprite> normalSprites =
        sheet.getRowSprites(row: 0, start: 0, count: 4);
    normalAnimation = SpriteAnimation.spriteList(
      normalSprites,
      stepTime: 0.2,
      loop: false,
    );

    // 攻擊
    List<Sprite> attackSprites =
        sheet.getRowSprites(row: 6, start: 2, count: 4);
    attackAnimation = SpriteAnimation.spriteList(
      attackSprites,
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
    runAnimation = SpriteAnimation.spriteList(
      runSprites,
      stepTime: 0.1,
      loop: true,
    );

    /**
     * Player
     */
    player = Player(
      animations: {
        PlayerAction.Normal: normalAnimation,
        PlayerAction.Run: runAnimation,
        PlayerAction.Attack: attackAnimation,
      },
      current: PlayerAction.Normal,
      position: Vector2(200, 340),
      size: Vector2(50, 37) * 2,
    );

    add(player);

    // 焦點
    camera.followComponent(player, relativeOffset: const Anchor(0.2, 0.8));

    /**
     * JoyStick
     */
    final knobPaint = BasicPalette.white.withAlpha(200).paint();
    final backgroundPaint = BasicPalette.white.withAlpha(100).paint();
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 24, paint: knobPaint),
      background: CircleComponent(radius: 50, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 30, bottom: 40),
    );
    add(joystick);


    // const String attackSrc = 'attack.png';
    // await images.load(attackSrc);
    // var attackImage = images.fromCache(attackSrc);
    // add(attackComponent(Sprite(attackImage), Vector2(screenHeight, screenWidth)));
  }

  @override
  void update(double dt) {
    super.update(dt);

    bool moveLeft = joystick.relativeDelta[0] < 0;
    bool moveRight = joystick.relativeDelta[0] > 0;

    double playerVectorX = (joystick.relativeDelta * 300 * dt)[0];
    double playerVectorY = (joystick.relativeDelta * 300 * dt)[1];

    if (player.current == PlayerAction.Attack && player.animation!.done()){
      player.animation!.reset();
      player.attackTest = false;
    }

    if (player.current == PlayerAction.Normal && player.animation!.done()){
      player.animation!.reset();
    }

    // 透過joystick 讓角色進行x軸上的位移
    if (!joystick.delta.isZero()) {
      player.current = PlayerAction.Run;

      if ((moveLeft && player.x > 0) || (moveRight && player.x < size[0])) {
        player.position.add(Vector2(playerVectorX, 0));
      }

      // 角色左右翻轉
      if (moveRight && playerFlipped) {
        playerFlipped = false;
        player.flipHorizontallyAroundCenter();
      }

      if (moveLeft && !playerFlipped) {
        playerFlipped = true;
        player.flipHorizontallyAroundCenter();
      }

      // 背景左右翻轉
      if (moveRight) {
        parallax.parallax?.baseVelocity = Vector2(10, 0);
        return;
      }
      parallax.parallax?.baseVelocity = Vector2(-10, 0);
      return;
    }

    if(!player.attackTest){
      // 不動
      player.current = PlayerAction.Normal;
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
