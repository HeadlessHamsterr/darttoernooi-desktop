import 'dart:async';

import 'package:calc/calc.dart';
import 'package:darttoernooi/classes/game.dart';
import 'package:darttoernooi/defs.dart';
import 'package:darttoernooi/classes/player.dart';
import 'package:darttoernooi/classes/players_notifier.dart';
import 'package:darttoernooi/classes/single_player_notifier.dart';

class Poule {
  final String pouleNum;
  final Function(Poule) onPouleDone;
  final Function(String) onGameDone;
  PlayersNotifier players = PlayersNotifier();
  PlayersNotifier rankings = PlayersNotifier();
  GameNotifier games = GameNotifier();
  List<Player> tiedPlayers = [];
  List<List<int>> gameFormat = [];
  bool allGamesDone = false;
  bool allowedToSortByAverage = true;
  PlayerNotifer winner = PlayerNotifer();
  PlayerNotifer secondPlace = PlayerNotifer();
  late int numGames;

  Poule(
      {required this.pouleNum,
      required this.onPouleDone,
      required this.onGameDone});

  void updatePlayers(List<Player> newPlayers) {
    players.update(newPlayers);
    reloadRankings();
  }

  void addPlayer(Player player) {
    List<Player> lastPlayers = List.from(players.players);
    lastPlayers.add(player);
    players.update(lastPlayers);
    reloadRankings();
  }

  void calcNumGames() {
    if (players.players.length == 2) {
      numGames = 1;
    } else {
      numGames = (factorial(players.players.length) /
              (2 * factorial(players.players.length - 2)))
          .floor();
    }
  }

  Future<void> reloadRankings() {
    return Future(() {
      List<Player> tempPlayers = List.from(players.players);

      allowedToSortByAverage = true;
      for (Player player in tempPlayers) {
        if (!player.allGamesHaveAverages) {
          allowedToSortByAverage = false;
          break;
        }
      }

      tempPlayers.sort((player1, player2) {
        if (player1.legsWon != player2.legsWon) {
          return player1.legsWon.compareTo(player2.legsWon) *
              -1; //Result is inverted, because the default sorting method is smallest first, we want biggest first.
        } else if (player1.pointsDifference != player2.pointsDifference) {
          return player1.pointsDifference.compareTo(player2.pointsDifference) *
              -1;
        } else if (player1.tournamentAverage != player2.tournamentAverage &&
            player1.tournamentAverage != 0 &&
            player2.tournamentAverage != 0 &&
            allowedToSortByAverage) {
          return player1.tournamentAverage.compareTo(player2.pointsDifference) *
              -1;
        } else {
          return 0; //All metrics are equal, for now keep ranking the same. Later might implement a random sort.
        }
      });

      rankings.update(tempPlayers);
    });
  }

  void onGameStateChange(Game game, bool finished,
      {bool sendWSMessage = true}) async {
    int player1Index = players.players.indexWhere(
        (Player player) => player.playerID == game.player1.playerID);

    int player2Index = players.players.indexWhere(
        (Player player) => player.playerID == game.player2.playerID);

    players.players[player1Index].calculatePointsDifference();
    players.players[player2Index].calculatePointsDifference();

    await reloadRankings();

    if (finished && !allGamesDone) {
      print("Checking if all games in Poule $pouleNum are finished");
      int gameCounter = 0;
      for (Game game in games.games) {
        if (!game.finished) {
          print("Not all games for Poule $pouleNum are done");
          break;
        }
        gameCounter++;
      }
      if (gameCounter == games.games.length) {
        print("All games for Poule $pouleNum are done!");
        allGamesDone = true;
        winner.update(rankings.players[0]);
        secondPlace.update(rankings.players[1]);
        onPouleDone(this);
      }
    } else if (!finished && allGamesDone) {
      allGamesDone = false;
      print("Not all games for Poule $pouleNum are done");
      winner.update(Player(playerID: "", name: ""));
      secondPlace.update(Player(playerID: "", name: ""));
      onPouleDone(this);
    }

    if (sendWSMessage) {
      onGameDone(pouleNum);
    }
  }

  void generateGames() {
    gameFormat = getGameFormat(players.players.length);

    List<Game> tempGames = [];
    for (int i = 0; i < gameFormat.length; i++) {
      Game newGame = Game(
          gameID: "$pouleNum${i + 1}",
          player1: players.players[gameFormat[i][0]],
          player2: players.players[gameFormat[i][1]],
          changeGameState: onGameStateChange);
      tempGames.add(newGame);
    }

    games.update(tempGames);
  }
}
