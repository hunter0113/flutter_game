class CollisionState {
  bool isLeftBlocked;
  bool isRightBlocked;
  bool isTopBlocked;
  bool isBottomBlocked;

  CollisionState({
    this.isLeftBlocked = false,
    this.isRightBlocked = false,
    this.isTopBlocked = false,
    this.isBottomBlocked = false,
  });

  void reset() {
    isLeftBlocked = false;
    isRightBlocked = false;
    isTopBlocked = false;
    isBottomBlocked = false;
  }
} 