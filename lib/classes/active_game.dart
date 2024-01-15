import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/app_message_decoder.dart';

class ActiveGame with ChangeNotifier {
  final String player1;
  final String player2;
  final String startingPlayer;
  final String gameID;
  final int clientID;

  int player1Score = 0;
  int player1LegsWon = 0;
  int player1DartsThrown = 0;

  int player2Score = 0;
  int player2LegsWon = 0;
  int player2DartsThrown = 0;

  bool player1Turn = false;

  ActiveGame(
      {required this.player1,
      required this.player2,
      required this.player1Score,
      required this.player2Score,
      required this.player1Turn,
      required this.startingPlayer,
      required this.gameID,
      required this.clientID});

  void updatePlayerSettings(AppMessage appMessage) {
    player1Score = appMessage.player1Score;
    player1LegsWon = appMessage.player1LegsWon;
    player1DartsThrown = appMessage.player1DartsThrown;

    player2Score = appMessage.player2Score;
    player2LegsWon = appMessage.player2LegsWon;
    player2DartsThrown = appMessage.player2DartsThrown;

    player1Turn = appMessage.player1Turn;
    notifyListeners();
  }

  void legPlayed(String winner) {
    switch (winner) {
      case "player1":
        player1LegsWon++;
        break;
      case "player2":
        player2LegsWon++;
        break;
    }
  }
}

class ActiveGameList with ChangeNotifier {
  List<ActiveGame> _activeGames = [];
  List<ActiveGame> get activeGames => _activeGames;

  void addGame(ActiveGame newGame) {
    _activeGames.add(newGame);
    notifyListeners();
  }

  void removeGame(String gameID) {
    int gameIndex =
        _activeGames.indexWhere((ActiveGame game) => game.gameID == gameID);
    if (gameIndex > -1) {
      _activeGames.removeAt(gameIndex);
      notifyListeners();
    }
  }
}
