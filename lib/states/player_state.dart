import 'package:flame/components.dart';

enum AdventurerAction {
  normal,
  run,
  bowAttack,
  swordAttack,
  swordAttackTwo,
  swordAttackThree,
}

class PlayerState {
  bool isAttacking;
  bool isMoving;
  bool isFlipped;
  AdventurerAction currentAction;
  int health;

  static const int defaultHealth = 100;
  static const AdventurerAction defaultAction = AdventurerAction.normal;

  PlayerState({
    this.isAttacking = false,
    this.isMoving = false,
    this.isFlipped = false,
    this.currentAction = AdventurerAction.normal,
    this.health = defaultHealth,
  });

  void reset() {
    isAttacking = false;
    isMoving = false;
    isFlipped = false;
    currentAction = defaultAction;
    health = defaultHealth;
  }
} 