import 'player_state.dart';
import 'monster_state.dart';
import 'collision_state.dart';

class GameState {
  final PlayerState player;
  final MonsterState monster;
  final CollisionState collision;

  GameState({
    PlayerState? player,
    MonsterState? monster,
    CollisionState? collision,
  })  : player = player ?? PlayerState(),
        monster = monster ?? MonsterState(),
        collision = collision ?? CollisionState();

  void reset() {
    player.reset();
    monster.reset();
    collision.reset();
  }
} 