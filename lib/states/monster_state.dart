enum MonsterAction {
  normal,
  walk,
  attack,
  death,
}

class MonsterState {
  MonsterAction currentAction;
  double health;
  bool isAlive;

  static const double defaultHealth = 100.0;
  static const MonsterAction defaultAction = MonsterAction.normal;

  MonsterState({
    this.currentAction = MonsterAction.normal,
    this.health = defaultHealth,
    this.isAlive = true,
  });

  void reset() {
    currentAction = defaultAction;
    health = defaultHealth;
    isAlive = true;
  }
} 