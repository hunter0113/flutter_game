import 'package:flame/components.dart';

import '../constants/game_constants.dart';
import '../manager/animation_manager.dart';
import '../interfaces/game_manager_interface.dart';
import '../role/adventurer.dart';
import '../role/monster.dart';
import '../service/asset_service.dart';
import '../states/monster_state.dart';
import '../states/player_state.dart';

class AssetLoadManager {
  final IGameManager gameManager;
  final AssetService assetService;
  final AnimationManager animationManager;

  AssetLoadManager({
    required this.gameManager,
    required this.assetService,
    required this.animationManager,
  });

  Future<Adventurer> loadPlayer() async {
    await animationManager.loadPlayerAnimations();

    return Adventurer(
      gameManager: gameManager,
      animations: {
        AdventurerAction.normal: animationManager.normalAnimation,
        AdventurerAction.run: animationManager.runAnimation,
        AdventurerAction.bowAttack: animationManager.bowAttackAnimation,
        AdventurerAction.swordAttack: animationManager.swordAttackAnimationOne,
        AdventurerAction.swordAttackTwo: animationManager.swordAttackAnimationTwo,
        AdventurerAction.swordAttackThree: animationManager.swordAttackAnimationThree,
      },
      current: AdventurerAction.normal,
      position: Vector2(
          gameManager.screenWidth * GameConstants.settings.screenOffsetX,
          gameManager.screenHeight * GameConstants.settings.screenOffsetY),
      size: GameConstants.player.size * 2,
    );
  }

  Future<Monster> loadMonster() async {
    await animationManager.loadMonsterAnimations();

    return Monster(
      animations: {
        MonsterAction.normal: animationManager.monsterNormal,
        MonsterAction.walk: animationManager.monsterWalk,
        MonsterAction.attack: animationManager.monsterAttack,
        MonsterAction.death: animationManager.monsterDeath,
      },
      current: MonsterAction.normal,
      position: Vector2(
          gameManager.screenWidth * 0.8,
          gameManager.screenHeight * GameConstants.settings.screenOffsetY),
      size: GameConstants.monster.size * 2,
    );
  }
} 