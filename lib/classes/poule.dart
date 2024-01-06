import 'package:calc/calc.dart';
import 'package:darttoernooi/classes/player.dart';
import 'package:darttoernooi/classes/player_notifier.dart';

class Poule {
  final String pouleNum;
  PlayerNotifier players = PlayerNotifier();
  PlayerNotifier rankings = PlayerNotifier();
  List<Player> tiedPlayers = [];
  late Player winner;
  late Player secondPlace;
  late int numGames;

  Poule({required this.pouleNum});

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

  void reloadRankings() {
    List<Player> tempPlayers = List.from(players.players);

    tempPlayers.sort((player1, player2) {
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

    rankings.update(tempPlayers);
  }
}
