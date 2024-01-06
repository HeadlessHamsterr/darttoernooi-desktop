import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/player.dart';

class PlayerNotifier with ChangeNotifier {
  List<Player> _players = [];
  List<Player> get players => _players;

  void update(List<Player> newPlayers) {
    _players = List.from(newPlayers);
    notifyListeners();
  }
}
