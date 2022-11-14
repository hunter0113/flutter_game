import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'damageText.dart';

mixin Liveable on PositionComponent {
  final Paint _outlinePaint = Paint();
  final Paint _fillPaint = Paint();
  late double _lifePoint; // 生命上限
  late double currentLife; // 當前生命值

  final double _offsetY = 10; // 血量距離構件頂部偏移量
  final double _widthRadio = 1.2; // 血條寬度
  final double _lifeBarHeight = 4; // 血條高度

  final TextStyle _defaultTextStyle =
      const TextStyle(fontSize: 10, color: Colors.white);
  late final TextComponent _text;

  final DamageText _damageText = DamageText();

  void initBloodBar({
    required double lifePoint,
    Color lifeColor = Colors.red,
    Color outlineColor = Colors.white,
  }) {
    _outlinePaint
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    _fillPaint.color = lifeColor;

    _lifePoint = lifePoint;
    currentLife = lifePoint;

    // 添加生命值文字
    _text = TextComponent(textRenderer: TextPaint(style: _defaultTextStyle));
    _updateLifeText();
    double y = -(_offsetY + _text.height + 2);
    double x = (size.x / 2) * (_widthRadio / 2);
    _text.position = Vector2(x, y); // tag1
    add(_text);

    // 添加爆擊文字
    add(_damageText);
  }

  // 當前血量百分比
  double get _progress => currentLife / _lifePoint;

  // 取得當前血量
  double get life => currentLife;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    Rect rect = Rect.fromCenter(
        center: Offset(size.x / 2, _lifeBarHeight / 2 - _offsetY),
        width: size.x / 2 * _widthRadio,
        height: _lifeBarHeight);

    Rect lifeRect = Rect.fromPoints(
        rect.topLeft + Offset(rect.width * (1 - _progress), 0),
        rect.bottomRight);

    canvas.drawRect(lifeRect, _fillPaint);
    canvas.drawRect(rect, _outlinePaint);

  }

  void loss(double point) {
    currentLife -= point;
    if (currentLife <= 0) {
      currentLife = 0;
      onDied();
      return;
    }
    _damageText.addDamage(-point.toInt());
    _updateLifeText();
  }

  void onDied() {}

  void _updateLifeText() {
    _text.text = 'Hp ${currentLife.toInt()}';
  }
}
