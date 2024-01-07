import 'package:darttoernooi/classes/finals_game.dart';
import 'package:darttoernooi/classes/player.dart';
import 'package:darttoernooi/classes/finals_game_types.dart';

class Finals {
  final int amountOfPoules;
  final List<Player> winners;
  final List<Player> secondPlaces;
  FinalsGameNotifier games = FinalsGameNotifier();
  bool quartsDone = false;
  bool halfsDone = false;
  bool finalDone = false;

  Finals(
      {required this.amountOfPoules,
      required this.winners,
      required this.secondPlaces});

  List<Player> generateFinalsPlayers(int numberOfHalves) {}

  void generateFinalsGames() {
    if (amountOfPoules == 1) {
      games.update([
        FinalsGame(
            gameID: "winner",
            player1: winners[0],
            player2: secondPlaces[0],
            gameType: FinalsGameType.winner,
            changeGameState: onGameChangeState)
      ]);
    } else if (amountOfPoules == 2) {
      late Player half1Player1;
      late Player half1Player2;
      late Player half2Player1;
      late Player half2Player2;

      for (int i = 0; i < 2; i++) {
        String pouleNumToFind = "";
        switch (i) {
          case 0:
            pouleNumToFind = "A";
            break;
          case 1:
            pouleNumToFind = "B";
            break;
        }

        int player1Index = winners
            .indexWhere((Player player) => player.pouleNum == pouleNumToFind);
        int player2Index = secondPlaces
            .indexWhere((Player player) => player.pouleNum == pouleNumToFind);

        switch (i) {
          case 0:
            half1Player1 = winners[player1Index];
            half2Player2 = secondPlaces[player2Index];
            break;
          case 1:
            half2Player1 = winners[player1Index];
            half1Player2 = secondPlaces[player2Index];
            break;
        }
      }
      games.update([
        FinalsGame(
            gameID: "half1",
            player1: half1Player1,
            player2: half1Player2,
            gameType: FinalsGameType.half,
            changeGameState: onGameChangeState),
        FinalsGame(
            gameID: "half2",
            player1: half2Player1,
            player2: half2Player2,
            gameType: FinalsGameType.half,
            changeGameState: onGameChangeState),
        FinalsGame(
            gameID: "finals",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.finals,
            changeGameState: onGameChangeState),
        FinalsGame(
            gameID: "winner",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.winner,
            changeGameState: onGameChangeState)
      ]);
    } else if (amountOfPoules == 3) {
      games.update([
        FinalsGame(
            gameID: "quart1",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.quart,
            changeGameState: onGameChangeState),
        FinalsGame(
            gameID: "quart2",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.quart,
            changeGameState: onGameChangeState),
        FinalsGame(
            gameID: "quart3",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.quart,
            changeGameState: onGameChangeState),
        FinalsGame(
            gameID: "half1",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.half,
            changeGameState: onGameChangeState),
        FinalsGame(
            gameID: "finals",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.finals,
            changeGameState: onGameChangeState),
        FinalsGame(
            gameID: "winner",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.winner,
            changeGameState: onGameChangeState)
      ]);
    } else if (amountOfPoules == 4) {
      games.update([
        FinalsGame(
            gameID: "quart1",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.quart,
            changeGameState: onGameChangeState),
        FinalsGame(
            gameID: "quart2",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.quart,
            changeGameState: onGameChangeState),
        FinalsGame(
            gameID: "quart3",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.quart,
            changeGameState: onGameChangeState),
        FinalsGame(
            gameID: "quart4",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.quart,
            changeGameState: onGameChangeState),
        FinalsGame(
            gameID: "half1",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.half,
            changeGameState: onGameChangeState),
        FinalsGame(
            gameID: "half2",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.half,
            changeGameState: onGameChangeState),
        FinalsGame(
            gameID: "finals",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.finals,
            changeGameState: onGameChangeState),
        FinalsGame(
            gameID: "winner",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.winner,
            changeGameState: onGameChangeState)
      ]);
    }
  }

  void onGameChangeState(FinalsGame game, bool finished) {
    print("Game ${game.gameID} finished: $finished");
  }
}
