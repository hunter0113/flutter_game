import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/game/start_game_parallax.dart';
import 'game/start_game_all.dart';
import 'game/start_game_parallax_two.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 設定全屏以及橫向顯示
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  runApp(GameWidget(game: StartGame()));
  // runApp(GameWidget(game: StartGameParallax()));
  // runApp(GameWidget(game: StartGameParallax_Two()));
}


