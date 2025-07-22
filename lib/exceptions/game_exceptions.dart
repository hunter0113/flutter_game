/// 遊戲異常基類
abstract class GameException implements Exception {
  final String message;
  final DateTime timestamp;
  final StackTrace? stackTrace;

  GameException(
    this.message, {
    this.stackTrace,
  }) : timestamp = DateTime.now();

  @override
  String toString() => '$runtimeType: $message (發生時間: $timestamp)';
}

/// 資源載入異常
class AssetLoadException extends GameException {
  final String assetPath;
  final Object? originalError;

  AssetLoadException(
    String message,
    this.assetPath, {
    this.originalError,
    StackTrace? stackTrace,
  }) : super(message, stackTrace: stackTrace);

  @override
  String toString() => '$runtimeType: $message (資源路徑: $assetPath)';
}

/// 遊戲狀態異常
class GameStateException extends GameException {
  final String currentState;
  final String expectedState;

  GameStateException(
    String message,
    this.currentState,
    this.expectedState, {
    StackTrace? stackTrace,
  }) : super(message, stackTrace: stackTrace);

  @override
  String toString() => 
      '$runtimeType: $message (當前狀態: $currentState, 期望狀態: $expectedState)';
}

/// 動畫異常
class AnimationException extends GameException {
  final String animationName;
  final String? componentName;

  AnimationException(
    String message,
    this.animationName, {
    this.componentName,
    StackTrace? stackTrace,
  }) : super(message, stackTrace: stackTrace);

  @override
  String toString() {
    final component = componentName != null ? ' (組件: $componentName)' : '';
    return '$runtimeType: $message (動畫: $animationName)$component';
  }
}

/// 碰撞檢測異常
class CollisionException extends GameException {
  final String entity1;
  final String entity2;

  CollisionException(
    String message,
    this.entity1,
    this.entity2, {
    StackTrace? stackTrace,
  }) : super(message, stackTrace: stackTrace);

  @override
  String toString() => 
      '$runtimeType: $message (實體1: $entity1, 實體2: $entity2)';
}

/// 輸入驗證異常
class InputValidationException extends GameException {
  final String fieldName;
  final Object? invalidValue;

  InputValidationException(
    String message,
    this.fieldName, {
    this.invalidValue,
    StackTrace? stackTrace,
  }) : super(message, stackTrace: stackTrace);

  @override
  String toString() {
    final value = invalidValue != null ? ' (無效值: $invalidValue)' : '';
    return '$runtimeType: $message (欄位: $fieldName)$value';
  }
}

/// 背景載入異常（從背景管理器移動到這裡）
class BackgroundLoadException extends AssetLoadException {
  BackgroundLoadException(
    String message, {
    String assetPath = 'background',
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(message, assetPath, originalError: originalError, stackTrace: stackTrace);
} 