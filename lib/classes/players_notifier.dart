import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/player.dart';

class PlayersNotifier with ChangeNotifier {
  List<Player> _players = [];
  List<Player> get players => _players;

  void update(List<Player> newPlayers) {
    _players = List.from(newPlayers);
    notifyListeners();
  }

  List<List<String>> convertToList() {
    List<List<String>> stringPlayers = [];

    for (Player player in _players) {
      player.calculatePointsDifference();

      List<String> stringPlayer = [
        player.name,
        player.legsWon.toString(),
        player.pointsDifference.toString()
      ];

      stringPlayers.add(stringPlayer);
    }

    return stringPlayers;
  }
}
