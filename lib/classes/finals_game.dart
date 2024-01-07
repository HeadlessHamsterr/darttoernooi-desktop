import 'package:darttoernooi/classes/player.dart';
import 'package:darttoernooi/classes/finals_game_types.dart';
import 'package:flutter/material.dart';

class FinalsGame {
  final String gameID;
  final Player player1;
  final Player player2;
  final FinalsGameType gameType;
  final Function(FinalsGame, bool) changeGameState;
  bool finished = false;
  int player1Score = -1;
  int player2Score = -1;

  FinalsGame(
      {required this.gameID,
      required this.player1,
      required this.player2,
      required this.gameType,
      required this.changeGameState});

  void updateScore(Player player, int score) {
    if (player.playerID == player1.playerID) {
      player1Score = score;
    } else if (player.playerID == player2.playerID) {
      player2Score = score;
    } else {
      throw "Attempted to update the score for a player that doesn't exist in this game";
    }

    if (player1Score > -1 && player2Score > -1) {
      print("$gameID done!");
      finished = true;
      changeGameState(this, true);
    }
  }

  void resetScore(Player player) {
    if (player.playerID == player1.playerID) {
      player1Score = -1;
    } else if (player.playerID == player2.playerID) {
      player2Score = -1;
    } else {
      throw "Attempted to reset the score for a player that doesn't exist in this game";
    }

    if (finished) {
      print("$gameID is no longer finished");
    }

    finished = false;
    changeGameState(this, false);
  }
}

class FinalsGameNotifier with ChangeNotifier {
  List<FinalsGame> _games = [];
  List<FinalsGame> get finalsGames => _games;

  void update(List<FinalsGame> newGames) {
    _games = List.from(newGames);
    notifyListeners();
  }
}
