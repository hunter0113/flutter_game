import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

// 傷害文字
class DamageText extends PositionComponent {
  int textCounter = 0;

  final TextStyle _damageTextStyle = const TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontFamily: 'Menlo',
      shadows: [
        Shadow(color: Colors.red, offset: Offset(1, 1), blurRadius: 1),
      ]);

  final TextStyle _critDamageTextStyle = const TextStyle(
      fontSize: 16,
      color: Colors.yellowAccent,
      fontFamily: 'Menlo',
      shadows: [
        Shadow(color: Colors.yellow, offset: Offset(1, 1), blurRadius: 1),
      ]);

  void addDamage(int damage, {bool isCrit = false}) {
    Vector2 offset = Vector2( -30 + textCounter * 5, textCounter * 14);
    textCounter++;

    if (!isCrit) {
      _addWhiteDamage(damage, offset);
    } else {
      _addCritDamage(damage, offset);
    }
  }

  Future<void> _addWhiteDamage(int damage, Vector2 position) async {
    TextComponent damageText =
        TextComponent(textRenderer: TextPaint(style: _damageTextStyle));
    damageText.text = damage.toString();
    damageText.position = position;
    add(damageText);
    await Future.delayed(const Duration(seconds: 1));
    damageText.removeFromParent();
    textCounter--;
  }

  Future<void> _addCritDamage(int damage, Vector2 position) async {
    TextComponent damageText =
        TextComponent(textRenderer: TextPaint(style: _critDamageTextStyle));
    damageText.text = damage.toString();
    damageText.position = position;

    TextStyle style = _critDamageTextStyle.copyWith(fontSize: 10);
    TextComponent infoText =
        TextComponent(textRenderer: TextPaint(style: style));
    infoText.text = '爆擊';
    infoText.position = position +
        Vector2(damageText.width - infoText.width / 2, -infoText.height / 2);
    add(infoText);
    add(damageText);
    await Future.delayed(const Duration(seconds: 1));
    infoText.removeFromParent();
    damageText.removeFromParent();
    textCounter--;
  }
}
