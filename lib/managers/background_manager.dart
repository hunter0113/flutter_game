import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import '../constants/game_constants.dart';
import '../exceptions/game_exceptions.dart';

/// 負責背景管理的專門類
class BackgroundManager {
  ParallaxComponent? _parallax;
  final Map<String, double> _layerInfo;

  BackgroundManager({Map<String, double>? layerInfo})
      : _layerInfo = layerInfo ?? _getDefaultLayerInfo();

  /// 取得預設背景層資訊
  static Map<String, double> _getDefaultLayerInfo() {
    return {
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
  }

  /// 載入背景
  Future<ParallaxComponent> loadBackground(
    Future<ParallaxLayer> Function(ParallaxImageData, {Vector2? velocityMultiplier}) loadParallaxLayer,
  ) async {
    try {
      final layers = _layerInfo.entries.map(
        (entry) => loadParallaxLayer(
          ParallaxImageData(entry.key),
          velocityMultiplier: Vector2(entry.value, 0),
        ),
      );

      _parallax = ParallaxComponent(
        parallax: Parallax(
          await Future.wait(layers),
          baseVelocity: Vector2(GameConstants.settings.backgroundBaseVelocity, 0),
        ),
      );

      // 初始設定為靜止
      _parallax!.parallax?.baseVelocity = Vector2.zero();
      
      return _parallax!;
    } catch (e) {
      throw BackgroundLoadException('背景載入失敗: $e');
    }
  }

  /// 更新背景滾動速度
  void updateVelocity(Vector2 velocity) {
    _parallax?.parallax?.baseVelocity = velocity;
  }

  /// 停止背景滾動
  void stopScrolling() {
    updateVelocity(Vector2.zero());
  }

  /// 取得當前背景組件
  ParallaxComponent? get parallax => _parallax;

  /// 檢查背景是否已載入
  bool get isLoaded => _parallax != null;

  /// 重設背景狀態
  void reset() {
    stopScrolling();
  }

  /// 銷毀背景資源
  void dispose() {
    _parallax?.removeFromParent();
    _parallax = null;
  }
} 