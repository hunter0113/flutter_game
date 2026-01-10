import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameConstants {
  // 遊戲基本設定
  static const GameSettings settings = GameSettings();
  
  // 玩家相關設定
  static final PlayerSettings player = PlayerSettings();
  
  // 怪物相關設定
  static final MonsterSettings monster = MonsterSettings();
  
  // UI 相關設定
  static const UISettings ui = UISettings();
  
  // 動畫相關設定
  static const AnimationSettings animation = AnimationSettings();
  
  // 精靈表設定
  static const Map<String, SpriteSheetData> spriteSheets = {
    'player_normal': SpriteSheetData(columns: 7, rows: 18),
    'player_bow': SpriteSheetData(columns: 4, rows: 4),
    'player_run': SpriteSheetData(columns: 6, rows: 1),
    'monster_normal': SpriteSheetData(columns: 10, rows: 1),
    'monster_walk': SpriteSheetData(columns: 9, rows: 1),
    'monster_attack': SpriteSheetData(columns: 12, rows: 1),
    'monster_death': SpriteSheetData(columns: 14, rows: 1),
  };
}

// 遊戲基本設定
class GameSettings {
  final double backgroundBaseVelocity = 10.0;
  final double screenOffsetX = 0.3;
  final double screenOffsetY = 0.8;

  const GameSettings();
}

// 玩家相關設定
class PlayerSettings {
  final double speed = 120.0;
  final Vector2 size = Vector2(50, 37);
  final double initialHealth = 1000.0;
  final Color healthBarColor = Colors.blue;

  PlayerSettings();
}

// 怪物相關設定
class MonsterSettings {
  final double arrowDamage = 200.0;
  final Vector2 size = Vector2(48, 37);
  final double initialHealth = 1000.0;
  final Color healthBarColor = Colors.red;
  final double moveSpeed = 30.0; // 怪物移動速
  final double moveRange = 100.0; // 怪物左右移動範圍

  MonsterSettings();
}

// UI 相關設定
class UISettings {
  final double joystickKnobRadius = 24.0;
  final double joystickBackgroundRadius = 50.0;
  final EdgeInsets joystickMargin = const EdgeInsets.only(left: 30, bottom: 40);
  final double joystickAlpha = 0.5;
  final double joystickBackgroundAlpha = 0.3;
  final double attackButtonSize = 50.0;

  const UISettings();
}

// 動畫相關設定
class AnimationSettings {
  final double normalStepTime = 0.2;
  final double attackStepTime = 0.08;
  final double runStepTime = 0.1;
  final double monsterWalkStepTime = 0.1;
  final double monsterAttackStepTime = 0.08;
  final double monsterDeathStepTime = 0.2;

  const AnimationSettings();
}

// 精靈表數據
class SpriteSheetData {
  final int columns;
  final int rows;

  const SpriteSheetData({
    required this.columns,
    required this.rows,
  });
} 