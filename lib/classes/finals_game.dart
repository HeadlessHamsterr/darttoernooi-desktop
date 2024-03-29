import 'package:darttoernooi/classes/player.dart';
import 'package:darttoernooi/classes/finals_game_types.dart';
import 'package:flutter/material.dart';

class FinalsGame with ChangeNotifier {
  final String gameID;
  Player player1 = Player(name: "", playerID: "");
  Player player2 = Player(name: "", playerID: "");
  final FinalsGameType gameType;
  final Function(FinalsGame, bool) changeGameState;
  final Function onGameDone;
  bool finished = false;
  int player1Score = -1;
  int player2Score = -1;
  Player winner = Player(name: "", playerID: "");

  FinalsGame(
      {required this.gameID,
      required this.player1,
      required this.player2,
      required this.gameType,
      required this.changeGameState,
      required this.onGameDone});

  void updateScore(Player player, int score, {bool sendWSMessage = true}) {
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
      if (player1Score > player2Score) {
        winner = player1;
      } else {
        winner = player2;
      }
      changeGameState(this, true);

      if (sendWSMessage) {
        onGameDone();
      }
    }
    notifyListeners();
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
    onGameDone();
    notifyListeners();
  }

  List<String> convertToList() {
    String gameTypeString = "";

    switch (gameType) {
      case FinalsGameType.finals:
        gameTypeString = 'finals';
        break;
      case FinalsGameType.half:
        gameTypeString = 'half';
        break;
      case FinalsGameType.quart:
        gameTypeString = 'quart';
        break;
      case FinalsGameType.winner:
        gameTypeString = 'winner';
        break;
    }

    return [
      gameID,
      player1.name,
      player2.name,
      finished.toString(),
      gameTypeString
    ];
  }
}

class FinalsGameNotifier with ChangeNotifier {
  List<List<FinalsGame>> _games = [];
  List<List<FinalsGame>> get finalsGames => _games;

  void update(List<List<FinalsGame>> newGames) {
    _games = List.from(newGames);
    notifyListeners();
  }
}
