import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/start_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 設定全屏以及橫向顯示
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  
  runApp(GameWidget(game: StartGame()));
}


