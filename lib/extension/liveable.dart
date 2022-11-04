import 'package:flame/components.dart';
import 'package:flutter/material.dart';


mixin Liveable on PositionComponent {
  final Paint _outlinePaint = Paint();
  final Paint _fillPaint = Paint();
  late double lifePoint; // 生命上限
  late double _currentLife; // 當前生命值

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

    this.lifePoint = lifePoint;
    _currentLife = lifePoint;
  }

  // 當前血量百分比
  double get _progress => _currentLife / lifePoint;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final double offsetY = 10; // 血量距離構件頂部偏移量
    final double widthRadio = 1.2; // 血條寬度
    final double lifeBarHeight = 4; // 血條高度

    Rect rect = Rect.fromCenter(
        center: Offset(size.x / 2, lifeBarHeight / 2 - offsetY),
        width: size.x / 2 * widthRadio,
        height: lifeBarHeight);

    Rect lifeRect = Rect.fromPoints(
        rect.topLeft + Offset(rect.width * (1 - _progress), 0),
        rect.bottomRight);

    canvas.drawRect(lifeRect, _fillPaint);
    canvas.drawRect(rect, _outlinePaint);
  }

  void loss(double point) {
    _currentLife -= point;
    if (_currentLife <= 0) {
      _currentLife = 0;
      onDied();
    }
  }

  void onDied() {

  }

}