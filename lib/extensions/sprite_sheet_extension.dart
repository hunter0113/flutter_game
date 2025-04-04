import 'package:flame/sprite.dart';

extension SpriteSheetExt on SpriteSheet {
  List<Sprite> getRowSprites({
    required int row,
    int start = 0,
    required count,
  }) {
    return List.generate(count, (i) => getSprite(row, start + i)).toList();
  }
} 