import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameConstants {
  // 遊戲基本設定
  static const double BACKGROUND_BASE_VELOCITY = 10.0;
  static const double PLAYER_SPEED = 120.0;

  // 螢幕位置相關
  static const double SCREEN_OFFSET_X = 0.3;
  static const double SCREEN_OFFSET_Y = 0.8;

  // 角色大小設定
  static Vector2 get PLAYER_SIZE => Vector2(50, 37);
  static Vector2 get MONSTER_SIZE => Vector2(48, 37);

  // 動畫相關設定
  static const double NORMAL_ANIMATION_STEP_TIME = 0.2;
  static const double ATTACK_ANIMATION_STEP_TIME = 0.08;
  static const double RUN_ANIMATION_STEP_TIME = 0.1;

  // UI 相關設定
  static const double JOYSTICK_KNOB_RADIUS = 24.0;
  static const double JOYSTICK_BACKGROUND_RADIUS = 50.0;
  static const EdgeInsets JOYSTICK_MARGIN = EdgeInsets.only(left: 30, bottom: 40);
  static const int JOYSTICK_ALPHA = 200;
  static const int JOYSTICK_BACKGROUND_ALPHA = 100;

  // 怪物相關設定
  static const double MONSTER_ARROW_DAMAGE = 200.0;

  // 精靈表設定
  static const Map<String, SpriteSheetData> SPRITE_SHEETS = {
    'player_normal': SpriteSheetData(columns: 7, rows: 18),
    'player_bow': SpriteSheetData(columns: 4, rows: 4),
    'player_run': SpriteSheetData(columns: 6, rows: 1),
    'monster_normal': SpriteSheetData(columns: 10, rows: 1),
    'monster_walk': SpriteSheetData(columns: 9, rows: 1),
    'monster_attack': SpriteSheetData(columns: 12, rows: 1),
    'monster_death': SpriteSheetData(columns: 14, rows: 1),
  };
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