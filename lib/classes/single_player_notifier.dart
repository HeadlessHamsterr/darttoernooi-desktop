import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/player.dart';

class PlayerNotifer with ChangeNotifier {
  Player _player = Player(playerID: "", name: "");
  Player get player => _player;

  void update(Player newPlayer) {
    _player = newPlayer;
    notifyListeners();
  }
}
