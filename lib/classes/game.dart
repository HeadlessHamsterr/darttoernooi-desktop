import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/player.dart';

class Game {
  final String gameID;
  final Player player1;
  final Player player2;
  final Function(Game, bool) changeGameState;
  int player1Score = -1;
  int player2Score = -1;
  double player1Average = 0.0;
  double player2Average = 0.0;
  bool finished = false;

  Game(
      {required this.gameID,
      required this.player1,
      required this.player2,
      required this.changeGameState});

  void updateScore(Player player, int score, double average) {
    if (player.playerID == player1.playerID) {
      player1Score = score;
      player1Average = average;
      player1.legsWon += score;
      player2.legsLost += score;
    } else if (player.playerID == player2.playerID) {
      player2Score = score;
      player2Average = average;
      player1.legsLost += score;
      player2.legsWon += score;
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
      player1.legsWon -= player1Score;
      player2.legsLost -= player1Score;
      player1Score = -1;
      player1Average = 0.0;
    } else if (player.playerID == player2.playerID) {
      player2.legsWon -= player2Score;
      player1.legsLost -= player2Score;
      player2Score = -1;
      player2Average = 0.0;
    } else {
      throw "Attempted to reset the score for a player that doesn't exist in this game";
    }

    if (finished) {
      print("$gameID not done anymore!");
    }
    finished = false;
    changeGameState(this, false);
  }
}

class GameNotifier with ChangeNotifier {
  List<Game> _games = [];
  List<Game> get games => _games;

  void update(List<Game> newGames) {
    _games = List.from(newGames);
    notifyListeners();
  }
}
