import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';

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

class StartGameParallax extends FlameGame {
  @override
  Future<void> onLoad() async {
    super.onLoad();

    /**
     * BackGround
     */
    final layers = bgLayerInfo.entries.map(
      (entry) => loadParallaxLayer(
        ParallaxImageData(entry.key),
        // 速度乘數
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
  }
}
