import 'package:darttoernooi/classes/finals_game.dart';
import 'package:darttoernooi/classes/player.dart';
import 'package:darttoernooi/classes/finals_game_types.dart';

class Finals {
  final int amountOfPoules;
  FinalsGameNotifier games = FinalsGameNotifier();
  bool quartsDone = false;
  bool halfsDone = false;
  bool finalDone = false;

  Finals({required this.amountOfPoules});

  void generateFinalsGames() {
    if (amountOfPoules == 1) {
      games.update([
        FinalsGame(
            gameID: "winner",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.winner,
            changeGameState: onGameChangeState)
      ]);
    } else if (amountOfPoules == 2) {
      games.update([
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
