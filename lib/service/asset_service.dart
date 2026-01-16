import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/sprite.dart';

class AssetService {
  final Images images;
  
  // 集中管理所有資源路徑
  static const Map<String, Map<String, String>> _Assets = {
    'player': {
      'normal': 'player.png',
      'run': 'run.png',
      'attack': 'attack.png',
      'bow': 'bow_attack.png',
    },
    'monster': {
      'normal': 'monster_normal.png',
      'walk': 'monster_walk.png',
      'attack': 'monster_attack.png',
      'death': 'monster_death.png',
    },
    'ui': {
      'attack': 'attack.png',
    },
  };

  // 影片資源路徑
  static const Map<String, String> _VideoAssets = {
    'attack': 'assets/攻擊.mp4',
    'move': 'assets/移動.mp4',
    'debug': 'assets/調試模式.mp4',
  };

  AssetService(this.images);

  // 加載所有遊戲資源
  Future<void> loadAllAssets() async {
    try {
      await Future.wait([
        _loadPlayerAssets(),
        _loadMonsterAssets(),
        _loadUIAssets(),
      ]);
    } catch (e) {
      print('資源加載失敗: $e');
      rethrow;
    }
  }

  // 加載玩家資源
  Future<void> _loadPlayerAssets() async {
    await Future.wait([
      images.load(_Assets['player']!['normal']!),
      images.load(_Assets['player']!['run']!),
      images.load(_Assets['player']!['attack']!),
      images.load(_Assets['player']!['bow']!),
    ]);
  }

  // 加載怪物資源
  Future<void> _loadMonsterAssets() async {
    await Future.wait([
      images.load(_Assets['monster']!['normal']!),
      images.load(_Assets['monster']!['walk']!),
      images.load(_Assets['monster']!['attack']!),
      images.load(_Assets['monster']!['death']!),
    ]);
  }

  // 加載UI資源
  Future<void> _loadUIAssets() async {
    await images.load(_Assets['ui']!['attack']!);
  }

  // 創建精靈表
  SpriteSheet createSpriteSheet({
    required String category,
    required String type,
    required int columns,
    required int rows,
  }) {
    final assetKey = _Assets[category]![type]!;
    return SpriteSheet.fromColumnsAndRows(
      image: images.fromCache(assetKey),
      columns: columns,
      rows: rows,
    );
  }

  // 取得已加載的圖片
  Image getImage(String category, String type) {
    final assetKey = _Assets[category]![type]!;
    return images.fromCache(assetKey);
  }

  // 取得影片資源路徑
  static String getVideoPath(String type) {
    return _VideoAssets[type] ?? '';
  }

  // 取得所有影片資源路徑
  static Map<String, String> get allVideoAssets => _VideoAssets;
} 