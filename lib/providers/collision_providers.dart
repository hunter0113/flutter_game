import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../states/collision_state.dart';

/// 碰撞狀態管理器
class CollisionStateNotifier extends StateNotifier<CollisionState> {
  CollisionStateNotifier() : super(CollisionState());

  /// 設置左側碰撞狀態
  void setLeftBlocked(bool isBlocked) {
    state = CollisionState(
      isLeftBlocked: isBlocked,
      isRightBlocked: state.isRightBlocked,
      isTopBlocked: state.isTopBlocked,
      isBottomBlocked: state.isBottomBlocked,
    );
  }

  /// 設置右側碰撞狀態
  void setRightBlocked(bool isBlocked) {
    state = CollisionState(
      isLeftBlocked: state.isLeftBlocked,
      isRightBlocked: isBlocked,
      isTopBlocked: state.isTopBlocked,
      isBottomBlocked: state.isBottomBlocked,
    );
  }

  /// 設置上方碰撞狀態
  void setTopBlocked(bool isBlocked) {
    state = CollisionState(
      isLeftBlocked: state.isLeftBlocked,
      isRightBlocked: state.isRightBlocked,
      isTopBlocked: isBlocked,
      isBottomBlocked: state.isBottomBlocked,
    );
  }

  /// 設置下方碰撞狀態
  void setBottomBlocked(bool isBlocked) {
    state = CollisionState(
      isLeftBlocked: state.isLeftBlocked,
      isRightBlocked: state.isRightBlocked,
      isTopBlocked: state.isTopBlocked,
      isBottomBlocked: isBlocked,
    );
  }

  /// 設置水平方向碰撞狀態
  void setHorizontalBlocked(bool leftBlocked, bool rightBlocked) {
    state = CollisionState(
      isLeftBlocked: leftBlocked,
      isRightBlocked: rightBlocked,
      isTopBlocked: state.isTopBlocked,
      isBottomBlocked: state.isBottomBlocked,
    );
  }

  /// 設置垂直方向碰撞狀態
  void setVerticalBlocked(bool topBlocked, bool bottomBlocked) {
    state = CollisionState(
      isLeftBlocked: state.isLeftBlocked,
      isRightBlocked: state.isRightBlocked,
      isTopBlocked: topBlocked,
      isBottomBlocked: bottomBlocked,
    );
  }

  /// 設置所有方向的碰撞狀態
  void setAllBlocked(bool isBlocked) {
    state = CollisionState(
      isLeftBlocked: isBlocked,
      isRightBlocked: isBlocked,
      isTopBlocked: isBlocked,
      isBottomBlocked: isBlocked,
    );
  }

  /// 重置碰撞狀態
  void reset() {
    state = CollisionState();
  }

  /// 是否有任何方向被阻擋
  bool get hasAnyCollision => 
      state.isLeftBlocked || 
      state.isRightBlocked || 
      state.isTopBlocked || 
      state.isBottomBlocked;

  /// 是否水平方向被阻擋
  bool get isHorizontalBlocked => state.isLeftBlocked || state.isRightBlocked;

  /// 是否垂直方向被阻擋
  bool get isVerticalBlocked => state.isTopBlocked || state.isBottomBlocked;

  /// 是否完全被包圍
  bool get isCompletelyBlocked => 
      state.isLeftBlocked && 
      state.isRightBlocked && 
      state.isTopBlocked && 
      state.isBottomBlocked;
}

/// 碰撞狀態提供者
final collisionStateProvider = StateNotifierProvider<CollisionStateNotifier, CollisionState>((ref) {
  return CollisionStateNotifier();
});

/// 左側是否被阻擋的提供者
final isLeftBlockedProvider = Provider<bool>((ref) {
  return ref.watch(collisionStateProvider).isLeftBlocked;
});

/// 右側是否被阻擋的提供者
final isRightBlockedProvider = Provider<bool>((ref) {
  return ref.watch(collisionStateProvider).isRightBlocked;
});

/// 上方是否被阻擋的提供者
final isTopBlockedProvider = Provider<bool>((ref) {
  return ref.watch(collisionStateProvider).isTopBlocked;
});

/// 下方是否被阻擋的提供者
final isBottomBlockedProvider = Provider<bool>((ref) {
  return ref.watch(collisionStateProvider).isBottomBlocked;
});

/// 是否有任何碰撞的提供者
final hasAnyCollisionProvider = Provider<bool>((ref) {
  return ref.watch(collisionStateProvider.notifier).hasAnyCollision;
});

/// 水平方向是否被阻擋的提供者
final isHorizontalBlockedProvider = Provider<bool>((ref) {
  return ref.watch(collisionStateProvider.notifier).isHorizontalBlocked;
});

/// 垂直方向是否被阻擋的提供者
final isVerticalBlockedProvider = Provider<bool>((ref) {
  return ref.watch(collisionStateProvider.notifier).isVerticalBlocked;
});

/// 是否完全被包圍的提供者
final isCompletelyBlockedProvider = Provider<bool>((ref) {
  return ref.watch(collisionStateProvider.notifier).isCompletelyBlocked;
}); 