import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game/riverpod_start_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 設定全屏以及橫向顯示
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  // 使用 ProviderScope 包裝整個應用以支援 Riverpod
  runApp(
    ProviderScope(
      child: RiverpodGameApp(),
    ),
  );
}

class RiverpodGameApp extends ConsumerWidget {
  const RiverpodGameApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GameWidget(game: RiverpodStartGame());
  }
} 