import 'dart:async' as async;
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';


late ParallaxComponent parallax;

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


class StartGameParallax_Two extends FlameGame {
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
    add(parallax);


    /**
     * Hero
     */
    add(SpriteAnimationComponent(
        animation: await loadSpriteAnimation(
          'run.png',
          SpriteAnimationData.sequenced(
            texturePosition: Vector2(0, 0),
            amount: 6,
            textureSize: Vector2(50, 37),
            stepTime: 0.1,
            loop: true,
          ),
        ))
      ..position = Vector2(200, 310)
      ..size = Vector2(50, 37) * 2);


    /**
     * SnowFlake
     */
    Random random = Random();
    async.Timer.periodic(const Duration(seconds: 1), (timer) {
      add(ParticleSystemComponent(
          priority: 0,
          // 批量生成粒子
          particle: Particle.generate(
            // 粒子生成粒子的數量
              count: 400,
              lifespan: random.nextInt(20).toDouble().clamp(10, 15),
              // 根據索引生成 Particle 的函數
              generator: (i) {
                return TranslatedParticle(
                    offset: Vector2(random.nextInt(size.x.toInt()).toDouble(),
                        -random.nextInt(size.y.toInt()).toDouble()),
                    child: AcceleratedParticle(
                      speed: Vector2(0, random.nextInt(80).toDouble()),
                      child: CircleParticle(
                          radius: random.nextDouble() * 10.clamp(1, 1),
                          paint: Paint()
                            ..color = Colors.white54.withAlpha(
                                (255 * random.nextDouble()).toInt())),
                    ));
              }))
        ..position = Vector2.zero());
    });
  }
}
