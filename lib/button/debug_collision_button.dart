import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../role/adventurer.dart';
import '../role/monster.dart';
import '../components/arrow.dart';

/// 調試碰撞範圍切換按鈕
class DebugCollisionButton extends RectangleComponent with Tappable, HasGameRef {
  final Adventurer adventurer;
  final Monster monster;
  bool _showCollision = false;

  DebugCollisionButton({
    required this.adventurer,
    required this.monster,
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2(100, 50), // 寬大於高的長方形
    anchor: Anchor.topLeft,
    paint: Paint()..color = Colors.orange.withOpacity(0.7),
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // 添加文字標籤
    final text = TextComponent(
      text: '顯示碰撞範圍',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    text.anchor = Anchor.center;
    text.position = Vector2(size.x / 2, size.y / 2);
    add(text);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // 持續更新所有箭矢的碰撞範圍顯示狀態
    if (_showCollision) {
      final arrows = gameRef.children.whereType<Arrow>();
      for (final arrow in arrows) {
        _toggleHitboxDebug(arrow, _showCollision);
      }
    }
  }

  @override
  bool onTapDown(TapDownInfo event) {
    _toggleCollisionDisplay();
    return true;
  }

  /// 切換碰撞範圍顯示
  void _toggleCollisionDisplay() {
    _showCollision = !_showCollision;
    
    // 切換玩家碰撞範圍顯示
    _toggleHitboxDebug(adventurer, _showCollision);
    
    // 切換怪物碰撞範圍顯示
    _toggleHitboxDebug(monster, _showCollision);
    
    // 切換所有箭矢的碰撞範圍顯示
    final arrows = gameRef.children.whereType<Arrow>();
    for (final arrow in arrows) {
      _toggleHitboxDebug(arrow, _showCollision);
    }
    
    // 更新按鈕顏色以顯示狀態
    paint.color = _showCollision 
        ? Colors.green.withOpacity(0.7) 
        : Colors.orange.withOpacity(0.7);
  }

  /// 切換指定組件的 hitbox debug 模式
  void _toggleHitboxDebug(Component component, bool show) {
    // 遞歸查找所有 CircleHitbox 子組件（包括嵌套的）
    _setHitboxDebugRecursive(component, show);
  }

  /// 遞歸設置所有 hitbox 的 debug 模式
  void _setHitboxDebugRecursive(Component component, bool show) {
    // 如果當前組件是任何類型的 Hitbox，設置其 debugMode
    if (component is CircleHitbox || component is RectangleHitbox) {
      component.debugMode = show;
    }
    
    // 遞歸處理所有子組件
    for (final child in component.children) {
      _setHitboxDebugRecursive(child, show);
    }
  }
}

