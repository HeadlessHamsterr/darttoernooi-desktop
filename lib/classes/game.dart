import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/player.dart';

class Game with ChangeNotifier {
  final String gameID;
  final Player player1;
  final Player player2;
  final Function(Game, bool, {bool sendWSMessage}) changeGameState;
  int player1Score = -1;
  int player2Score = -1;
  double player1Average = 0.0;
  double player2Average = 0.0;
  bool finished = false;
  bool active = false;

  Game(
      {required this.gameID,
      required this.player1,
      required this.player2,
      required this.changeGameState});

  void updateScore(Player player, int score, double average,
      {bool sendWSMessage = true}) {
    print("Finishing game $gameID with ${player.name}: $average");
    if (player.playerID == player1.playerID) {
      player1Score = score;
      player1Average = average;
      player1.legsWon += score;
      player2.legsLost += score;

      player1.gameIDsPlayed.add(gameID);
      player1.calculateGamesPlayed();

      player1.averages.add(player1Average);
      player1.calculateTournamentAverage();
    } else if (player.playerID == player2.playerID) {
      player2Score = score;
      player2Average = average;
      player1.legsLost += score;
      player2.legsWon += score;

      player2.gameIDsPlayed.add(gameID);
      player2.calculateGamesPlayed();

      player2.averages.add(player2Average);
      player2.calculateTournamentAverage();
    } else {
      throw "Attempted to update the score for a player that doesn't exist in this game";
    }

    if (player1Score > -1 && player2Score > -1) {
      print("$gameID done!");
      finished = true;
      changeGameState(this, true, sendWSMessage: sendWSMessage);
    }
    notifyListeners();
  }

  void resetScore(Player player) {
    if (player.playerID == player1.playerID) {
      player1.legsWon -= player1Score;
      player2.legsLost -= player1Score;

      int averageIndex = player1.averages
          .indexWhere((double average) => average == player1Average);
      if (averageIndex > -1) {
        player1.averages.removeAt(averageIndex);
      }

      int gamePlayedIndex =
          player1.gameIDsPlayed.indexWhere((String gameID) => gameID == gameID);
      if (gamePlayedIndex > -1) {
        player1.gameIDsPlayed.removeAt(gamePlayedIndex);
      }

      player1Score = -1;
      player1Average = 0.0;
    } else if (player.playerID == player2.playerID) {
      player2.legsWon -= player2Score;
      player1.legsLost -= player2Score;

      int averageIndex = player2.averages
          .indexWhere((double average) => average == player2Average);
      if (averageIndex > -1) {
        player2.averages.removeAt(averageIndex);
      }

      int gamePlayedIndex =
          player2.gameIDsPlayed.indexWhere((String gameID) => gameID == gameID);
      if (gamePlayedIndex > -1) {
        player2.gameIDsPlayed.removeAt(gamePlayedIndex);
      }

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

  void sendNotification() {
    notifyListeners();
  }

  List<List> convertToList() {
    List<List> gamesList = [];

    for (Game game in _games) {
      List tempGame = [
        game.player1.name,
        game.player2.name,
        game.active || game.finished
      ];
      gamesList.add(tempGame);
    }

    return gamesList;
  }
}
