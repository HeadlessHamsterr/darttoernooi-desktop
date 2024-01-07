import 'package:darttoernooi/classes/game.dart';
import 'package:darttoernooi/classes/player.dart';

class Finals {
  final int amountOfPoules;
  GameNotifier games = GameNotifier();

  Finals({required this.amountOfPoules});

  void generateFinalsGames() {
    if (amountOfPoules == 1) {}
  }
}
