import 'package:darttoernooi/classes/finals_game.dart';
import 'package:darttoernooi/classes/player.dart';
import 'package:darttoernooi/classes/finals_game_types.dart';
import 'package:darttoernooi/classes/poule.dart';
import 'package:darttoernooi/defs.dart';

class Finals {
  final int amountOfPoules;
  List<Player> winners = [];
  List<Player> secondPlaces = [];
  List<List<int>> gameFormat = [];
  FinalsGameNotifier games = FinalsGameNotifier();
  bool quartsDone = false;
  bool halfsDone = false;
  bool finalDone = false;

  Finals({required this.amountOfPoules});

  List<Player> _generateFinalsPlayers(int numberOfGames) {
    List<Player> players = [];

    for (int i = 0; i < numberOfGames; i++) {
      players.add(Player(playerID: "", name: ""));
    }

    for (int i = 0; i < numberOfGames; i++) {
      String pouleNumToFind = "";
      switch (i) {
        case 0:
          pouleNumToFind = "A";
          break;
        case 1:
          pouleNumToFind = "B";
          break;
        case 2:
          pouleNumToFind = "C";
          break;
        case 3:
          pouleNumToFind = "D";
          break;
      }

      int player1Index = winners
          .indexWhere((Player player) => player.pouleNum == pouleNumToFind);
      int player2Index = secondPlaces
          .indexWhere((Player player) => player.pouleNum == pouleNumToFind);

      late Player winner;
      late Player secondPlace;

      if (player1Index == -1) {
        winner = Player(name: "", playerID: "");
      } else {
        winner = winners[player1Index];
      }

      if (player2Index == -1) {
        secondPlace = Player(name: "", playerID: "");
      } else {
        secondPlace = secondPlaces[player2Index];
      }

      switch (i) {
        case 0:
          players[0] = winner;
          players[3] = secondPlace;
          break;
        case 1:
          players[1] = secondPlace;
          players[2] = winner;
          break;
        case 2:
          players[4] = winner;
          players[7] = secondPlace;
          break;
        case 3:
          players[5] = secondPlace;
          players[6] = winner;
          break;
      }
    }

    return players;
  }

  void generateFinalsGames() {
    List<List<FinalsGame>> newGames = [];

    if (amountOfPoules > 2) {
      print("Generating quarts...");
      List<FinalsGame> quarts = [
        FinalsGame(
            gameID: "quart1",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.quart,
            changeGameState: _onGameChangeState),
        FinalsGame(
            gameID: "quart2",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.quart,
            changeGameState: _onGameChangeState),
        FinalsGame(
            gameID: "quart3",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.quart,
            changeGameState: _onGameChangeState),
      ];

      if (amountOfPoules == 4) {
        quarts.add(FinalsGame(
            gameID: "quart4",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.quart,
            changeGameState: _onGameChangeState));
      }

      newGames.add(quarts);
    }

    if (amountOfPoules > 1) {
      print("Generating semi's...");
      List<FinalsGame> halfs = [];
      halfs.add(FinalsGame(
          gameID: "half1",
          player1: Player(name: "", playerID: ""),
          player2: Player(name: "", playerID: ""),
          gameType: FinalsGameType.half,
          changeGameState: _onGameChangeState));

      if (amountOfPoules != 3) {
        halfs.add(FinalsGame(
            gameID: "half2",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.half,
            changeGameState: _onGameChangeState));
      }
      newGames.add(halfs);

      print("Generating finals...");
      newGames.add([
        FinalsGame(
            gameID: "finals",
            player1: Player(name: "", playerID: ""),
            player2: Player(name: "", playerID: ""),
            gameType: FinalsGameType.finals,
            changeGameState: _onGameChangeState),
      ]);
    }

    print("Generating winner...");
    newGames.add([
      FinalsGame(
          gameID: "winner",
          player1: Player(name: "", playerID: ""),
          player2: Player(name: "", playerID: ""),
          gameType: FinalsGameType.winner,
          changeGameState: _onGameChangeState)
    ]);

    games.update(newGames);

    for (int i = 0; i < amountOfPoules; i++) {
      winners.add(Player(name: "", playerID: ""));
      secondPlaces.add(Player(playerID: "", name: ""));
    }

    gameFormat = getFinalsGameFormat(amountOfPoules);
/*
    if (amountOfPoules == 1) {
      games.update([
        [
          FinalsGame(
              gameID: "winner",
              player1: Player(name: "", playerID: ""),
              player2: Player(name: "", playerID: ""),
              gameType: FinalsGameType.winner,
              changeGameState: _onGameChangeState)
        ]
      ]);
    } else if (amountOfPoules == 2) {
      games.update([
        [
          FinalsGame(
              gameID: "half1",
              player1: Player(name: "", playerID: ""),
              player2: Player(name: "", playerID: ""),
              gameType: FinalsGameType.half,
              changeGameState: _onGameChangeState),
          FinalsGame(
              gameID: "half2",
              player1: Player(name: "", playerID: ""),
              player2: Player(name: "", playerID: ""),
              gameType: FinalsGameType.half,
              changeGameState: _onGameChangeState),
        ],
        [
          FinalsGame(
              gameID: "finals",
              player1: Player(name: "", playerID: ""),
              player2: Player(name: "", playerID: ""),
              gameType: FinalsGameType.finals,
              changeGameState: _onGameChangeState),
        ],
        [
          FinalsGame(
              gameID: "winner",
              player1: Player(name: "", playerID: ""),
              player2: Player(name: "", playerID: ""),
              gameType: FinalsGameType.winner,
              changeGameState: _onGameChangeState)
        ]
      ]);
    } else if (amountOfPoules == 3) {
      games.update([
        [
          FinalsGame(
              gameID: "quart1",
              player1: Player(name: "", playerID: ""),
              player2: Player(name: "", playerID: ""),
              gameType: FinalsGameType.quart,
              changeGameState: _onGameChangeState),
          FinalsGame(
              gameID: "quart2",
              player1: Player(name: "", playerID: ""),
              player2: Player(name: "", playerID: ""),
              gameType: FinalsGameType.quart,
              changeGameState: _onGameChangeState),
          FinalsGame(
              gameID: "quart3",
              player1: Player(name: "", playerID: ""),
              player2: Player(name: "", playerID: ""),
              gameType: FinalsGameType.quart,
              changeGameState: _onGameChangeState),
        ],
        [
          FinalsGame(
              gameID: "half1",
              player1: Player(name: "", playerID: ""),
              player2: Player(name: "", playerID: ""),
              gameType: FinalsGameType.half,
              changeGameState: _onGameChangeState),
        ],
        [
          FinalsGame(
              gameID: "finals",
              player1: Player(name: "", playerID: ""),
              player2: Player(name: "", playerID: ""),
              gameType: FinalsGameType.finals,
              changeGameState: _onGameChangeState),
        ],
        [
          FinalsGame(
              gameID: "winner",
              player1: Player(name: "", playerID: ""),
              player2: Player(name: "", playerID: ""),
              gameType: FinalsGameType.winner,
              changeGameState: _onGameChangeState)
        ]
      ]);
    } else if (amountOfPoules == 4) {
      games.update([
        [
          FinalsGame(
              gameID: "quart1",
              player1: Player(name: "", playerID: ""),
              player2: Player(name: "", playerID: ""),
              gameType: FinalsGameType.quart,
              changeGameState: _onGameChangeState),
          FinalsGame(
              gameID: "quart2",
              player1: Player(name: "", playerID: ""),
              player2: Player(name: "", playerID: ""),
              gameType: FinalsGameType.quart,
              changeGameState: _onGameChangeState),
          FinalsGame(
              gameID: "quart3",
              player1: Player(name: "", playerID: ""),
              player2: Player(name: "", playerID: ""),
              gameType: FinalsGameType.quart,
              changeGameState: _onGameChangeState),
          FinalsGame(
              gameID: "quart4",
              player1: Player(name: "", playerID: ""),
              player2: Player(name: "", playerID: ""),
              gameType: FinalsGameType.quart,
              changeGameState: _onGameChangeState),
        ],
        [
          FinalsGame(
              gameID: "half1",
              player1: Player(name: "", playerID: ""),
              player2: Player(name: "", playerID: ""),
              gameType: FinalsGameType.half,
              changeGameState: _onGameChangeState),
          FinalsGame(
              gameID: "half2",
              player1: Player(name: "", playerID: ""),
              player2: Player(name: "", playerID: ""),
              gameType: FinalsGameType.half,
              changeGameState: _onGameChangeState),
        ],
        [
          FinalsGame(
              gameID: "finals",
              player1: Player(name: "", playerID: ""),
              player2: Player(name: "", playerID: ""),
              gameType: FinalsGameType.finals,
              changeGameState: _onGameChangeState),
        ],
        [
          FinalsGame(
              gameID: "winner",
              player1: Player(name: "", playerID: ""),
              player2: Player(name: "", playerID: ""),
              gameType: FinalsGameType.winner,
              changeGameState: _onGameChangeState)
        ]
      ]);
    }
    */
  }

  void updateWinners(Poule poule) {
    List<List<FinalsGame>> tempGames = List.from(games.finalsGames);

    switch (poule.pouleNum) {
      case "A":
        winners[0] = poule.winner.player;
        secondPlaces[0] = poule.secondPlace.player;
        break;
      case "B":
        winners[1] = poule.winner.player;
        secondPlaces[1] = poule.secondPlace.player;
        break;
      case "C":
        winners[2] = poule.winner.player;
        secondPlaces[2] = poule.secondPlace.player;
        break;
      case "D":
        winners[3] = poule.winner.player;
        secondPlaces[3] = poule.secondPlace.player;
        break;
    }

    for (int i = 0; i < amountOfPoules; i++) {
      tempGames[0][i].player1 = winners[gameFormat[i][0]];
      tempGames[0][i].player2 = secondPlaces[gameFormat[i][1]];
    }

    games.update(tempGames);
  }

  //This function handles moving the players to the next finals game when a
  //previous game is finished. The function also resets the next finals game
  //when a previous game is not finished anymore.
  void _onGameChangeState(FinalsGame game, bool finished) {
    print("Game ${game.gameID} finished: $finished");
    List<List<FinalsGame>> tempFinals = List.from(games.finalsGames);
    int gameTypeIndex = 0;

    if (game.gameID.contains("quart")) {
      gameTypeIndex = 1;
    } else if (game.gameID.contains("half")) {
      if (amountOfPoules > 2) {
        gameTypeIndex = 2;
      } else {
        gameTypeIndex = 1;
      }
    } else if (game.gameID == "finals") {
      if (amountOfPoules > 2) {
        gameTypeIndex = 3;
      } else {
        gameTypeIndex = 2;
      }
    } else if (game.gameID == "winner") {
      if (amountOfPoules == 1) {
        gameTypeIndex = 1;
      } else if (amountOfPoules == 2) {
        gameTypeIndex = 3;
      } else if (amountOfPoules > 2) {
        gameTypeIndex = 4;
      }
    }

    switch (game.gameID) {
      //The winner of the first quarter final gets through as
      //the first player in the first semi-final
      case "quart1":
        int gameToEditIndex = tempFinals[gameTypeIndex]
            .indexWhere((FinalsGame game) => game.gameID == "half1");

        if (finished) {
          tempFinals[gameTypeIndex][gameToEditIndex].player1 = game.winner;
        } else {
          tempFinals[gameTypeIndex][gameToEditIndex].player1 =
              Player(playerID: "", name: "");
        }
        break;
      //The winner of the second quarter final gets through as
      //the second player in the first semi-final
      case "quart2":
        int gameToEditIndex = tempFinals[gameTypeIndex]
            .indexWhere((FinalsGame game) => game.gameID == "half1");

        if (finished) {
          tempFinals[gameTypeIndex][gameToEditIndex].player2 = game.winner;
        } else {
          tempFinals[gameTypeIndex][gameToEditIndex].player2 =
              Player(playerID: "", name: "");
        }
        break;
      //The winner of the third quarter final gets through as
      //the first player in the second semi-final, if there are 4 poules.
      //If there are three poules, the winner goes directly to the finals
      case "quart3":
        int gameToEditIndex = 0;
        if (amountOfPoules == 3) {
          gameToEditIndex = tempFinals[gameTypeIndex]
              .indexWhere((FinalsGame game) => game.gameID == "finals");
          if (finished) {
            tempFinals[gameTypeIndex][gameToEditIndex].player2 = game.winner;
          } else {
            tempFinals[gameTypeIndex][gameToEditIndex].player2 =
                Player(playerID: "", name: "");
          }
        } else {
          gameToEditIndex = tempFinals[gameTypeIndex]
              .indexWhere((FinalsGame game) => game.gameID == "half2");
          if (finished) {
            tempFinals[gameTypeIndex][gameToEditIndex].player1 = game.winner;
          } else {
            tempFinals[gameTypeIndex][gameToEditIndex].player1 =
                Player(playerID: "", name: "");
          }
        }
        break;
      //The winner of the fourth quarter final gets through as
      //the second player in the second semi-final
      case "quart4":
        int gameToEditIndex = tempFinals[gameTypeIndex]
            .indexWhere((FinalsGame game) => game.gameID == "half2");
        if (finished) {
          tempFinals[gameTypeIndex][gameToEditIndex].player2 = game.winner;
        } else {
          tempFinals[gameTypeIndex][gameToEditIndex].player2 =
              Player(playerID: "", name: "");
        }
        break;
      //The winners from the semifinals get through to the final
      case "half1":
        int gameToEditIndex = tempFinals[gameTypeIndex]
            .indexWhere((FinalsGame game) => game.gameID == "finals");
        if (finished) {
          tempFinals[gameTypeIndex][gameToEditIndex].player1 = game.winner;
        } else {
          tempFinals[gameTypeIndex][gameToEditIndex].player1 =
              Player(playerID: "", name: "");
        }
        break;
      case "half2":
        int gameToEditIndex = tempFinals[gameTypeIndex]
            .indexWhere((FinalsGame game) => game.gameID == "finals");
        if (finished) {
          tempFinals[gameTypeIndex][gameToEditIndex].player2 = game.winner;
        } else {
          tempFinals[gameTypeIndex][gameToEditIndex].player2 =
              Player(playerID: "", name: "");
        }
        break;
      //The winner of the final gets through to the "game" winner, that just
      //displays the player name as the winner in the UI.
      case "finals":
        int gameToEditIndex = tempFinals[gameTypeIndex]
            .indexWhere((FinalsGame game) => game.gameID == "winner");
        if (finished) {
          tempFinals[gameTypeIndex][gameToEditIndex].player1 = game.winner;
        } else {
          tempFinals[gameTypeIndex][gameToEditIndex].player1 =
              Player(playerID: "", name: "");
        }
        break;
    }

    games.update(tempFinals);
  }
}
