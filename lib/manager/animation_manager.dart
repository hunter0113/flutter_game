import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter_game/extensions/sprite_sheet_extension.dart';
import '../constants/game_constants.dart';
import '../service/asset_service.dart';

class AnimationManager {
  late SpriteAnimation normalAnimation;
  late SpriteAnimation runAnimation;
  late SpriteAnimation bowAttackAnimation;
  late SpriteAnimation swordAttackAnimationOne;
  late SpriteAnimation swordAttackAnimationTwo;
  late SpriteAnimation swordAttackAnimationThree;
  late SpriteAnimation monsterNormal;
  late SpriteAnimation monsterWalk;
  late SpriteAnimation monsterAttack;
  late SpriteAnimation monsterDeath;

  final AssetService _assetService;

  AnimationManager(this._assetService);

  Future<void> loadPlayerAnimations() async {
    final spriteSheetData = GameConstants.spriteSheets['player_normal']!;
    final allSpriteSheet = _assetService.createSpriteSheet(
      category: 'player',
      type: 'normal',
      columns: spriteSheetData.columns,
      rows: spriteSheetData.rows,
    );

    // 普通動畫
    final normalSprites = allSpriteSheet.getRowSprites(row: 0, start: 0, count: 4);
    normalAnimation = SpriteAnimation.spriteList(
      normalSprites,
      stepTime: GameConstants.animation.normalStepTime,
      loop: true,
    );

    // 攻擊動畫
    final attackSpritesOne = allSpriteSheet.getRowSprites(row: 6, start: 0, count: 6);
    swordAttackAnimationOne = SpriteAnimation.spriteList(
      attackSpritesOne,
      stepTime: GameConstants.animation.attackStepTime,
      loop: false,
    );

    final attackSpritesTwo = allSpriteSheet.getRowSprites(row: 7, start: 0, count: 4);
    swordAttackAnimationTwo = SpriteAnimation.spriteList(
      attackSpritesTwo,
      stepTime: GameConstants.animation.attackStepTime,
      loop: false,
    );

    final attackSpritesThree = allSpriteSheet.getRowSprites(row: 7, start: 4, count: 3)
      ..addAll(allSpriteSheet.getRowSprites(row: 8, start: 0, count: 3));
    swordAttackAnimationThree = SpriteAnimation.spriteList(
      attackSpritesThree,
      stepTime: GameConstants.animation.attackStepTime,
      loop: false,
    );

    // 弓箭動畫
    final bowSheetData = GameConstants.spriteSheets['player_bow']!;
    final bowSheet = _assetService.createSpriteSheet(
      category: 'player',
      type: 'bow',
      columns: bowSheetData.columns,
      rows: bowSheetData.rows,
    );

    final bowSprites = bowSheet.getRowSprites(row: 0, start: 0, count: 4)
      ..addAll(bowSheet.getRowSprites(row: 1, start: 0, count: 4))
      ..addAll(bowSheet.getRowSprites(row: 2, start: 0, count: 1));
    bowAttackAnimation = SpriteAnimation.spriteList(
      bowSprites,
      stepTime: GameConstants.animation.attackStepTime,
      loop: false,
    );

    // 跑步動畫
    final runSheetData = GameConstants.spriteSheets['player_run']!;
    final runSheet = _assetService.createSpriteSheet(
      category: 'player',
      type: 'run',
      columns: runSheetData.columns,
      rows: runSheetData.rows,
    );

    final runSprites = runSheet.getRowSprites(row: 0, start: 0, count: 6);
    runAnimation = SpriteAnimation.spriteList(
      runSprites,
      stepTime: GameConstants.animation.runStepTime,
      loop: true,
    );
  }

  Future<void> loadMonsterAnimations() async {
    // 普通動畫
    final normalSheetData = GameConstants.spriteSheets['monster_normal']!;
    final monsterNormalSheet = _assetService.createSpriteSheet(
      category: 'monster',
      type: 'normal',
      columns: normalSheetData.columns,
      rows: normalSheetData.rows,
    );

    final monsterNormalSprites = monsterNormalSheet.getRowSprites(row: 0, start: 0, count: 10);
    monsterNormal = SpriteAnimation.spriteList(
      monsterNormalSprites,
      stepTime: GameConstants.animation.normalStepTime,
      loop: true,
    );

    // 走路動畫
    final walkSheetData = GameConstants.spriteSheets['monster_walk']!;
    final monsterWalkSheet = _assetService.createSpriteSheet(
      category: 'monster',
      type: 'walk',
      columns: walkSheetData.columns,
      rows: walkSheetData.rows,
    );

    final monsterWalkSprites = monsterWalkSheet.getRowSprites(row: 0, start: 0, count: 9);
    monsterWalk = SpriteAnimation.spriteList(
      monsterWalkSprites,
      stepTime: GameConstants.animation.monsterWalkStepTime,
      loop: true,
    );

    // 攻擊動畫
    final attackSheetData = GameConstants.spriteSheets['monster_attack']!;
    final monsterAttackSheet = _assetService.createSpriteSheet(
      category: 'monster',
      type: 'attack',
      columns: attackSheetData.columns,
      rows: attackSheetData.rows,
    );

    final monsterAttackSprites = monsterAttackSheet.getRowSprites(row: 0, start: 0, count: 12);
    monsterAttack = SpriteAnimation.spriteList(
      monsterAttackSprites,
      stepTime: GameConstants.animation.monsterAttackStepTime,
      loop: true,
    );

    // 死亡動畫
    final deathSheetData = GameConstants.spriteSheets['monster_death']!;
    final monsterDeathSheet = _assetService.createSpriteSheet(
      category: 'monster',
      type: 'death',
      columns: deathSheetData.columns,
      rows: deathSheetData.rows,
    );

    final monsterDeathSprites = monsterDeathSheet.getRowSprites(row: 0, start: 0, count: 12);
    monsterDeath = SpriteAnimation.spriteList(
      monsterDeathSprites,
      stepTime: GameConstants.animation.monsterDeathStepTime,
      loop: false,
    );
  }
} 