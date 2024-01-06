import 'package:flutter/material.dart';
import 'package:calc/calc.dart';
import 'package:darttoernooi/classes/player.dart';

class Poule {
  final String pouleNum;
  List<Player> players = [];
  List<Player> rankings = [];
  List<Player> tiedPlayers = [];
  late Player winner;
  late Player secondPlace;
  late int numGames;

  Poule({required this.pouleNum, required this.players});

  void updatePlayers(List<Player> newPlayers) {
    players = newPlayers;
  }

  void addPlayer(Player player) {
    players.add(player);
  }

  void calcNumGames() {
    if (players.length == 2) {
      numGames = 1;
    } else {
      numGames =
          (factorial(players.length) / (2 * factorial(players.length - 2)))
              .floor();
    }
  }

  void reloadRankings() {
    rankings = List.from(players);

    rankings.sort((player1, player2) {
      if (player1.legsWon != player2.legsWon) {
        return player1.legsWon.compareTo(player2.legsWon) *
            -1; //Result is inverted, because the default sorting method is smallest first, we want biggest first.
      } else if (player1.pointsDifference != player2.pointsDifference) {
        return player1.pointsDifference.compareTo(player2.pointsDifference) *
            -1;
      } else if (player1.tournamentAverage != player2.tournamentAverage &&
          player1.tournamentAverage != 0 &&
          player2.tournamentAverage != 0) {
        return player1.tournamentAverage.compareTo(player2.pointsDifference) *
            -1;
      } else {
        return 0; //All metrics are equal, for now keep ranking the same. Later might implement a random sort.
      }
    });
  }
}
