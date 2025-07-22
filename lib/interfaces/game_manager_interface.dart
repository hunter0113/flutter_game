/// 遊戲管理器接口
/// 定義了 Adventurer 和其他組件需要的基本管理器功能
abstract class IGameManager {
  /// 屏幕寬度
  double get screenWidth;
  
  /// 屏幕高度
  double get screenHeight;
  
  /// 是否正在攻擊
  bool get isAttack;
  
  /// 設置攻擊狀態
  set isAttack(bool value);
  
  /// 下一攻擊步驟
  bool get nextAttackStep;
  
  /// 設置下一攻擊步驟
  set nextAttackStep(bool value);
  
  /// 冒險者是否翻轉
  bool get adventurerFlipped;
  
  /// 設置冒險者翻轉狀態
  set adventurerFlipped(bool value);
  
  /// 左側碰撞阻擋
  bool get isLeftCollisionBlock;
  
  /// 右側碰撞阻擋
  bool get isRightCollisionBlock;
  
  /// 更新碰撞狀態
  void updateCollisionState({
    bool? isLeftBlocked,
    bool? isRightBlocked,
    bool? isTopBlocked,
    bool? isBottomBlocked,
  });
} 