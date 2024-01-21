import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:darttoernooi/classes/finals_game.dart';
import 'package:darttoernooi/classes/game.dart';
import 'package:darttoernooi/components/active_games.dart';
import 'package:darttoernooi/defs.dart';
import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/player.dart';
import 'package:darttoernooi/classes/poule.dart';
import 'package:darttoernooi/classes/setting.dart';
import 'package:uuid/uuid.dart';
import 'package:darttoernooi/components/game_widgets/poule_wrapper.dart';
import 'package:darttoernooi/components/game_widgets/finals_wrapper.dart';
import 'package:darttoernooi/classes/finals.dart';
import 'package:socket_io/socket_io.dart';
import 'package:darttoernooi/names.dart';
import 'package:darttoernooi/classes/active_game.dart';
import 'package:darttoernooi/classes/app_message_decoder.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_window_close/flutter_window_close.dart';

const List<String> pouleNums = ["A", "B", "C", "D"];

class GameScreen extends StatefulWidget {
  const GameScreen(
      {super.key,
      required this.playersNames,
      required this.settings,
      required this.numberOfPoules,
      required this.saveFileContents});

  final List<String> playersNames;
  final List<Setting> settings;
  final int numberOfPoules;
  final String saveFileContents;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Setting> newSettings = [];
  late RawDatagramSocket udpReceiver;
  List<Poule> poules = [];
  ActiveGameList activeGameList = ActiveGameList();
  String serverName = "";
  Finals finals = Finals(amountOfPoules: 0, onFinalDone: () {});
  Server socketio = Server();
  bool playSpecialSounds = true;
  bool playSound = true;
  bool alertShowing = false;

  final ExpansionTileController settingsController = ExpansionTileController();
  final ExpansionTileController playerNameController =
      ExpansionTileController();
  final settingsFormKey = GlobalKey<FormState>();
  final playerNamesFormKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    newSettings = List.from(widget.settings);

    if (widget.saveFileContents == "") {
      generatePoules();
      finals = Finals(
          amountOfPoules: widget.numberOfPoules, onFinalDone: sendFinalsInfo);
      finals.generateFinalsGames();
    } else {
      try {
        Map<String, dynamic> saveFileObject =
            jsonDecode(widget.saveFileContents);

        if (!supportedSaveGameVersions.contains(saveFileObject['version'])) {
          Navigator.popUntil(context, ModalRoute.withName('/start_screen'));
        }

        finals = Finals(
            amountOfPoules: saveFileObject['numPoules'],
            onFinalDone: sendFinalsInfo);
        finals.generateFinalsGames();

        saveFileObject['poules'].forEach((String pouleName, dynamic data) {
          poules.add(Poule(
              pouleNum: pouleName.replaceAll('poule', ''),
              onPouleDone: onPouleDone,
              onGameDone: sendPouleInfo));

          int pouleIndex = poules.indexWhere((Poule poule) =>
              poule.pouleNum == pouleName.replaceAll('poule', ''));

          Poule pouleToEdit = poules[pouleIndex];

          for (Map<String, dynamic> player in data['players']) {
            pouleToEdit.addPlayer(
                Player(playerID: player['playerID'], name: player['name']));
          }
          pouleToEdit.numGames = data['games'].length;

          List<Game> games = [];
          for (Map<String, dynamic> game in data['games']) {
            int player1Index = pouleToEdit.players.players.indexWhere(
                (Player player) => player.playerID == game['player1']);
            int player2Index = pouleToEdit.players.players.indexWhere(
                (Player player) => player.playerID == game['player2']);

            games.add(Game(
                gameID: game['gameID'],
                player1: pouleToEdit.players.players[player1Index],
                player2: pouleToEdit.players.players[player2Index],
                changeGameState: pouleToEdit.onGameStateChange));
          }

          pouleToEdit.games.update(games);
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          saveFileObject['poules'].forEach((String pouleName, dynamic data) {
            late Poule pouleToEdit;

            switch (pouleName) {
              case 'pouleA':
                pouleToEdit = poules[
                    poules.indexWhere((Poule poule) => poule.pouleNum == 'A')];
                break;
              case 'pouleB':
                pouleToEdit = poules[
                    poules.indexWhere((Poule poule) => poule.pouleNum == 'B')];
                break;
              case 'pouleC':
                pouleToEdit = poules[
                    poules.indexWhere((Poule poule) => poule.pouleNum == 'C')];
                break;
              case 'pouleD':
                pouleToEdit = poules[
                    poules.indexWhere((Poule poule) => poule.pouleNum == 'D')];
                break;
            }
            for (Map<String, dynamic> game in data['games']) {
              int gameIndex = pouleToEdit.games.games.indexWhere(
                  (Game pouleGame) => pouleGame.gameID == game['gameID']);

              Game gameToEdit = pouleToEdit.games.games[gameIndex];

              if (game['player1Score'] > -1) {
                gameToEdit.updateScore(gameToEdit.player1, game['player1Score'],
                    double.parse(game['player1Average'].toString()),
                    sendWSMessage: false);
              }

              if (game['player2Score'] > -1) {
                gameToEdit.updateScore(gameToEdit.player2, game['player2Score'],
                    double.parse(game['player2Average'].toString()),
                    sendWSMessage: false);
              }
              pouleToEdit.games.sendNotification();
            }
          });

          for (List<FinalsGame> finalsGames in finals.games.finalsGames) {
            for (FinalsGame finalsGame in finalsGames) {
              int gameIndex = saveFileObject['games'].indexWhere(
                  (dynamic game) => game['gameID'] == finalsGame.gameID);

              Map<String, dynamic> savedGame =
                  saveFileObject['games'][gameIndex];
              finalsGame.finished = savedGame['finished'];

              if (savedGame['player1Score'] > -1) {
                finalsGame.updateScore(
                    finalsGame.player1, savedGame['player1Score'],
                    sendWSMessage: false);
              }

              if (savedGame['player2Score'] > -1) {
                finalsGame.updateScore(
                    finalsGame.player2, savedGame['player2Score'],
                    sendWSMessage: false);
              }
            }
          }
        });

        Map<String, dynamic> savedSettingsObj = saveFileObject['settings'];

        List<Setting> savedSettings = [
          Setting(
              name: 'pouleScore',
              friendlyName: 'Poule beginscore',
              type: 'textfield',
              defaultValue: savedSettingsObj['pouleScore']),
          Setting(
              name: 'pouleLegs',
              friendlyName: 'Poule best of',
              type: 'textfield',
              defaultValue: savedSettingsObj['pouleLegs']),
          Setting(
              name: 'quartScore',
              friendlyName: 'Kwartfinale beginscore',
              type: 'textfield',
              defaultValue: savedSettingsObj['quartScore']),
          Setting(
              name: 'quartLegs',
              friendlyName: 'Kwartfinale best of',
              type: 'textfield',
              defaultValue: savedSettingsObj['quartLegs']),
          Setting(
              name: 'halfScore',
              friendlyName: 'Halve finale beginscore',
              type: 'textfield',
              defaultValue: savedSettingsObj['halfScore']),
          Setting(
              name: 'halfLegs',
              friendlyName: 'Halve finale best of',
              type: 'textfield',
              defaultValue: savedSettingsObj['halfLegs']),
          Setting(
              name: 'finalScore',
              friendlyName: 'Finale beginscore',
              type: 'textfield',
              defaultValue: savedSettingsObj['finalScore']),
          Setting(
              name: 'finalLegs',
              friendlyName: 'Finale best of',
              type: 'textfield',
              defaultValue: savedSettingsObj['finalLegs']),
        ];

        newSettings = List.from(savedSettings);
      } catch (e) {
        Navigator.popUntil(context, ModalRoute.withName('/start_screen'));
        return;
      }
    }

    startSocketIOServer();
    startUDPListener();

    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      if (alertShowing) {
        return false;
      }

      int closeResult = await stopGame(context);

      if (closeResult == 0) {
        return false;
      } else if (closeResult == 1) {
        return true;
      } else if (closeResult == 2) {
        String? path = await FilePicker.platform.saveFile(
            dialogTitle: 'Wedstrijd opslaan',
            allowedExtensions: ['darts'],
            fileName: 'savegame.darts');
        if (path != null) {
          bool gameSaved = await saveGame(path, false);
          if (gameSaved) {
            return true;
          } else {
            // ignore: use_build_context_synchronously
            Flushbar(
              message: "Spel opslaan mislukt, probeer het opnieuw.",
              forwardAnimationCurve: Curves.easeIn,
              reverseAnimationCurve: Curves.easeOut,
              flushbarPosition: FlushbarPosition.BOTTOM,
              messageSize: 17,
              icon: const Icon(Icons.error),
              isDismissible: true,
              backgroundColor: flushbarRed,
              flushbarStyle: FlushbarStyle.GROUNDED,
              duration: const Duration(seconds: 5),
            ).show(context);
            return false;
          }
        } else {
          return false;
        }
      } else {
        return false;
      }
    });
  }

  void startSocketIOServer() {
    socketio.on('connection', (client) {
      client.on('clientGreeting', (data) {
        client.emit('fromServer', 'ok');
      });

      client.on('disconnect', (data) {
        try {
          for (var game in activeGameList.activeGames) {
            if (game.clientID == client.hashCode) {
              activeGameList.removeGame(game.gameID);
            }
          }
        } catch (e) {
          print("Cannot close client ${client.hashCode} game");
        }
      });

      client.on('allPouleInfoRequest', (data) {
        List msg = [];
        List<String> pouleNames = [];

        for (Poule poule in poules) {
          pouleNames.add(poule.pouleNum);
        }
        msg.add(pouleNames);

        List<int> settings = [];
        for (Setting setting in widget.settings) {
          settings.add(int.parse(setting.defaultValue));
        }
        msg.add(settings);
        client.emit('pouleInfo', msg);
      });

      client.on('singlePouleInfoRequest', (data) {
        int pouleIndex =
            poules.indexWhere((Poule poule) => poule.pouleNum == data);

        if (pouleIndex == -1) {
          List msg = [
            ['No active', 'game']
          ];
          client.emit('poule${data}Ranks', msg);
        } else {
          List msg = [
            poules[pouleIndex].rankings.convertToList(),
            poules[pouleIndex].games.convertToList(),
            'poule'
          ];

          client.emit('poule${data}Ranks', msg);
        }
      });

      client.on('activeGameInfo', (data) {
        AppMessage appMessage =
            appMessageDecoder("activeGameInfo", data.toString());

        bool newGame = true;
        int activeGameIndex = activeGameList.activeGames.indexWhere(
            (ActiveGame activeGame) => activeGame.gameID == appMessage.gameID);

        if (activeGameIndex != -1) {
          newGame = false;
        }

        if (newGame) {
          ActiveGame newActiveGame = ActiveGame(
              player1: appMessage.player1,
              player2: appMessage.player2,
              player1Score: appMessage.player1Score,
              player2Score: appMessage.player2Score,
              player1Turn: appMessage.player1Turn,
              startingPlayer: appMessage.startingPlayer,
              gameID: appMessage.gameID,
              clientID: client.hashCode,
              legsBestOf: appMessage.legsBestOf);

          activeGameList.addGame(newActiveGame);
          if (appMessage.gameType == 'finals_game') {
            sendFinalsInfo();
          } else {
            sendPouleInfo(appMessage.gameID[0]);
          }
        } else {
          activeGameList.activeGames[activeGameIndex]
              .updatePlayerSettings(appMessage);

          playAudio(appMessage.thrownScore, appMessage.gameID);
        }
      });

      client.on('stopActiveGame', (gameID) {
        activeGameList.removeGame(gameID);
      });

      client.on('gamePlayed', (data) {
        AppMessage appMessage = appMessageDecoder('gamePlayed', data);
        activeGameList.removeGame(appMessage.gameID);
        print("Game played for game type: ${appMessage.gameType}");

        if (appMessage.gameType == "finals_game") {
          int gameIndex = -1;
          int gameCounter = 0;
          for (List<FinalsGame> finalsGames in finals.games.finalsGames) {
            gameIndex = finalsGames.indexWhere(
                (FinalsGame game) => game.gameID == appMessage.gameID);

            if (gameIndex > -1) {
              break;
            }
            gameCounter++;
          }

          if (gameIndex == -1) {
            print("Unkown final (Final ${appMessage.gameID[0]})");
            return;
          }

          FinalsGame gameToEdit =
              finals.games.finalsGames[gameCounter][gameIndex];
          gameToEdit.updateScore(gameToEdit.player1, appMessage.player1LegsWon);
          gameToEdit.updateScore(gameToEdit.player2, appMessage.player2Score);
        } else {
          int pouleIndex = poules.indexWhere(
              (Poule poule) => poule.pouleNum == appMessage.gameID[0]);
          if (pouleIndex == -1) {
            print("Unkown poule (Poule ${appMessage.gameID[0]})");
            return;
          }

          int gameIndex = poules[pouleIndex]
              .games
              .games
              .indexWhere((Game game) => game.gameID == appMessage.gameID);
          if (gameIndex == -1) {
            print("Unkown game (Game ${appMessage.gameID})");
            return;
          }

          Game gameToEdit = poules[pouleIndex].games.games[gameIndex];

          gameToEdit.updateScore(gameToEdit.player1, appMessage.player1LegsWon,
              appMessage.player1Average);
          gameToEdit.updateScore(gameToEdit.player2, appMessage.player2LegsWon,
              appMessage.player2Average);

          poules[pouleIndex].games.sendNotification();
        }
      });

      client.on('finalsInfoRequest', (data) {
        List<List<String>> message = [];

        for (int i = 0; i < finals.games.finalsGames.length; i++) {
          for (int j = 0; j < finals.games.finalsGames[i].length; j++) {
            message.add(finals.games.finalsGames[i][j].convertToList());
          }
        }
        client.emit('finalsInfo', message);
      });
    });
    socketio.listen(11520);
  }

  void startUDPListener() {
    serverName = names[Random().nextInt(names.length)];
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8889)
        .then((RawDatagramSocket udpSocket) {
      udpReceiver = udpSocket;
      udpSocket.broadcastEnabled = true;
      udpSocket.listen((event) {
        Datagram? dg = udpSocket.receive();
        if (dg != null) {
          String message = utf8.decode(dg.data);
          List<String> messageList = message.split(',');

          if (messageList[0] == "serverNameRequest") {
            NetworkInterface.list().then((value) {
              bool msgSent = false;
              for (NetworkInterface network in value) {
                for (var addr in network.addresses) {
                  if (addr.address.isNotEmpty &&
                      addr.type == InternetAddressType.IPv4) {
                    String returnMsg = 'serverName,$serverName,${addr.address}';
                    print('Sending: $returnMsg to ${messageList[1]}');
                    udpSocket.send(utf8.encode(returnMsg),
                        InternetAddress(messageList[1]), 8889);
                    msgSent = true;
                    break;
                  }
                }
                if (msgSent) {
                  break;
                }
              }
            });
          }
        }
      });
    });
  }

  void sendPouleInfo(String pouleNum) {
    int pouleIndex =
        poules.indexWhere((Poule poule) => poule.pouleNum == pouleNum);

    if (pouleIndex == -1) {
      List msg = [
        ['No active', 'game']
      ];
      socketio.emit('poule${pouleNum}Ranks', msg);
    } else {
      List msg = [
        poules[pouleIndex].rankings.convertToList(),
        poules[pouleIndex].games.convertToList(),
        'poule'
      ];

      socketio.emit('poule${pouleNum}Ranks', msg);
    }
  }

  void sendFinalsInfo() {
    List<List<String>> message = [];

    for (int i = 0; i < finals.games.finalsGames.length; i++) {
      for (int j = 0; j < finals.games.finalsGames[i].length; j++) {
        message.add(finals.games.finalsGames[i][j].convertToList());
      }
    }

    print("Sending response to finals game request:");
    print(message);
    socketio.emit('finalsInfo', message);
  }

  void onPouleDone(Poule poule) {
    finals.updateWinners(poule);
    sendFinalsInfo();
  }

  void generatePoules() {
    for (int i = 0; i < widget.numberOfPoules; i++) {
      poules.add(Poule(
          pouleNum: pouleNums[i],
          onPouleDone: onPouleDone,
          onGameDone: sendPouleInfo));
    }
    double playersPerPoule = widget.playersNames.length / widget.numberOfPoules;
    int playersPerPouleAbs = playersPerPoule.floor();

    widget.playersNames.shuffle();

    for (int i = 0; i < widget.playersNames.length; i++) {
      if (i < playersPerPouleAbs) {
        poules[0].addPlayer(
            Player(playerID: const Uuid().v4(), name: widget.playersNames[i]));
      } else if (playersPerPouleAbs <= i && i < (2 * playersPerPouleAbs)) {
        poules[1].addPlayer(
            Player(playerID: const Uuid().v4(), name: widget.playersNames[i]));
      } else if ((2 * playersPerPouleAbs) <= i &&
          i < (3 * playersPerPouleAbs)) {
        poules[2].addPlayer(
            Player(playerID: const Uuid().v4(), name: widget.playersNames[i]));
      } else if ((3 * playersPerPouleAbs) <= i &&
          i < (4 * playersPerPouleAbs)) {
        poules[3].addPlayer(
            Player(playerID: const Uuid().v4(), name: widget.playersNames[i]));
      }
    }

    for (int i = 0; i < poules.length; i++) {
      poules[i].calcNumGames();
      poules[i].reloadRankings();
      poules[i].generateGames();
    }
  }

  void updateSettings() {
    FocusManager.instance.primaryFocus!.unfocus();
    if (settingsFormKey.currentState!.validate()) {
      settingsFormKey.currentState!.save();

      List<int> settings = [];
      for (Setting setting in newSettings) {
        settings.add(int.parse(setting.defaultValue));
      }
      socketio.emit('settingsUpdate', settings);

      settingsController.collapse();

      Flushbar(
        message: "Instellingen aangepast!",
        forwardAnimationCurve: Curves.easeIn,
        reverseAnimationCurve: Curves.easeOut,
        flushbarPosition: FlushbarPosition.BOTTOM,
        messageSize: 17,
        icon: const Icon(Icons.check),
        isDismissible: true,
        backgroundColor: const Color.fromRGBO(56, 142, 60, 1),
        flushbarStyle: FlushbarStyle.GROUNDED,
        duration: const Duration(seconds: 5),
      ).show(context);

      setState(() {});
    }
  }

  Future<bool> saveGame(String? path, bool quicksave) async {
    Completer<bool> c = Completer();
    if (quicksave) {
      Directory directory = await getApplicationDocumentsDirectory();
      path = directory.path;

      bool saveFileExists = Directory('$path/darttoernooi-games').existsSync();

      if (!saveFileExists) {
        Directory('$path/darttoernooi-games').create();
      }

      path = '$path/darttoernooi-games';

      List<FileSystemEntity> files = Directory(path).listSync();

      for (FileSystemEntity file in files) {
        File newFile = file as File;
        if (newFile.path.contains('quicksave')) {
          newFile.delete();
        }
      }
    }

    if (path == null) {
      c.complete(false);
    } else {
      print("Saving game to: $path");
      print("Number of poules: ${widget.numberOfPoules}");

      Map<String, dynamic> saveObject = {
        "version": '${appVersion[0]}.${appVersion[1]}.${appVersion[2]}',
        "numPoules": poules.length,
        "poules": {},
        "games": [],
        "settings": {
          "pouleScore": newSettings[0].defaultValue,
          "pouleLegs": newSettings[1].defaultValue,
          "quartScore": newSettings[2].defaultValue,
          "quartLegs": newSettings[3].defaultValue,
          "halfScore": newSettings[4].defaultValue,
          "halfLegs": newSettings[5].defaultValue,
          "finalScore": newSettings[6].defaultValue,
          "finalLegs": newSettings[7].defaultValue,
        }
      };

      for (Poule poule in poules) {
        Map<String, dynamic> pouleObject = {
          'numPlayers': poule.players.players.length,
          'players': [],
          'games': []
        };

        for (Player player in poule.players.players) {
          Map<String, dynamic> playerObject = {
            'name': player.name,
            'points': player.legsWon,
            'counterPoints': player.legsLost,
            'averages': player.averages,
            'gamesPlayed': player.gamesPlayed,
            'gamesIDPlayed': player.gameIDsPlayed,
            'playerID': player.playerID
          };

          pouleObject['players'].add(playerObject);
        }

        for (Game game in poule.games.games) {
          Map<String, dynamic> gameObject = {
            'gameID': game.gameID,
            'player1': game.player1.playerID,
            'player1Score': game.player1Score,
            'player1Average': game.player1Average,
            'player2': game.player2.playerID,
            'player2Score': game.player2Score,
            'player2Average': game.player2Average,
            'finished': game.finished
          };

          pouleObject['games'].add(gameObject);
        }
        saveObject['poules']['poule${poule.pouleNum}'] = pouleObject;
      }

      for (List<FinalsGame> games in finals.games.finalsGames) {
        for (FinalsGame game in games) {
          Map<String, dynamic> gameObject = {
            'gameID': game.gameID,
            'player1': game.player1.playerID,
            'player1Score': game.player1Score,
            'player2': game.player2.playerID,
            'player2Score': game.player2Score,
            'winner': game.winner.playerID,
            'finished': game.finished,
            'gameType': game.gameType.toString()
          };

          saveObject['games'].add(gameObject);
        }
      }

      String saveObjString = jsonEncode(saveObject);
      String fileName = path;

      if (quicksave) {
        fileName = '$fileName\\quicksave.darts';
      }
      File saveFile = File(fileName);

      saveFile.create().then((value) =>
          value.writeAsString(saveObjString).then((value) => c.complete(true)));
    }
    return c.future;
  }

  Future<int> stopGame(BuildContext context) {
    Completer<int> c = Completer();

    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text("Wedstrijd opslaan?"),
              content: const Text(
                  'Wil je de wedstrijd opslaan, voordat je de wedstrijd verlaat?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, 0),
                    child: const Text("Annuleren")),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context, 1),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer),
                    child: const Text(
                      "Verlaten",
                    )),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context, 2),
                    child: const Text("Opslaan"))
              ],
            )).then((value) {
      if (value == null) {
        c.complete(0);
      } else {
        c.complete(value);
      }
    });

    return c.future;
  }

  void playAudio(String score, String gameID) {
    try {
      if (playSound &&
          score != '-1' &&
          (widget.numberOfPoules == 1 || gameID[0] == 'f')) {
        score = score.padLeft(3, '0');
        score = '$score.mp3';

        String url = 'https://darttoernooi.rietdijk.dev';

        if (playSpecialSounds) {
          url = '$url/special_sounds';
        } else {
          url = '$url/normal_sounds';
        }

        url = '$url/$score';

        print("Playing sound from $url");
        Process.run('ffplay', ['-autoexit', '-nodisp', url]);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Wedstrijdnaam: $serverName'),
        leading: IconButton(
          onPressed: () {
            stopGame(context).then((value) {
              if (value == 1) {
                socketio.emit("gameClose", "doei");

                socketio.close().then((value) {
                  udpReceiver.close();
                  Navigator.popUntil(
                      context, ModalRoute.withName('/start_screen'));
                });
              } else if (value == 2) {
                FilePicker.platform
                    .saveFile(
                        dialogTitle: 'Wedstrijd opslaan',
                        allowedExtensions: ['darts'],
                        fileName: 'savegame.darts')
                    .then((value) {
                  if (value != null) {
                    saveGame(value, false).then((value) {
                      if (value) {
                        socketio.emit("gameClose", "doei");

                        socketio.close().then((value) {
                          udpReceiver.close();
                          Navigator.popUntil(
                              context, ModalRoute.withName('/start_screen'));
                        });
                      }
                    });
                  }
                });
              }
            });
          },
          icon: const Icon(Icons.home),
        ),
        actions: [
          IconButton(
              onPressed: () => setState(() {
                    playSound = !playSound;
                  }),
              icon: playSound
                  ? const Icon(Icons.volume_up)
                  : const Icon(Icons.volume_off)),
          IconButton(
              onPressed: () {
                FilePicker.platform
                    .saveFile(
                        dialogTitle: 'Wedstrijd opslaan',
                        allowedExtensions: ['darts'],
                        fileName: 'savegame.darts')
                    .then((value) {
                  if (value != null) {
                    saveGame(value, false);
                  }
                });
              },
              icon: const Icon(Icons.save)),
          IconButton(
              onPressed: () => scaffoldKey.currentState!.openEndDrawer(),
              icon: const Icon(Icons.menu))
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: cardBackground,
        child: Column(
          children: [
            ExpansionTile(
                title: const Text("Legs & Scores"),
                controller: settingsController,
                onExpansionChanged: (value) {
                  if (value) {
                    if (playerNameController.isExpanded) {
                      playerNameController.collapse();
                    }
                  }
                },
                children: [
                  Form(
                    key: settingsFormKey,
                    child: Column(
                      children: [
                        ...newSettings.map((Setting setting) {
                          return SizedBox(
                            width: 150,
                            child: TextFormField(
                              initialValue: setting.defaultValue,
                              onSaved: (String? value) {
                                if (value!.isNotEmpty) {
                                  int settingIndex = newSettings.indexWhere(
                                      (Setting oldSetting) =>
                                          oldSetting.name == setting.name);
                                  newSettings[settingIndex] = Setting(
                                      name: setting.name,
                                      friendlyName: setting.friendlyName,
                                      type: setting.type,
                                      defaultValue: value);
                                }
                              },
                              onFieldSubmitted: (_) => updateSettings(),
                              validator: (value) {
                                if (value!.isNotEmpty) {
                                  RegExp regex = RegExp(r'([0-9]+)');
                                  Iterable<RegExpMatch> matches =
                                      regex.allMatches(value);

                                  if (matches.isNotEmpty) {
                                    try {
                                      int newSetting = int.parse(value);
                                      if (newSetting >= 0) {
                                        if (setting.name.contains("Legs") &&
                                            newSetting % 2 == 0) {
                                          return "Alleen oneven getallen";
                                        }
                                        return null;
                                      }
                                    } catch (e) {
                                      return "Vul een rond getal in";
                                    }
                                  }
                                  return "Vul een getal in";
                                }
                                return "Vul een getal in";
                              },
                              decoration: InputDecoration(
                                helperText: setting.friendlyName,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(
                          height: 15,
                        ),
                        ElevatedButton(
                            onPressed: () => updateSettings(),
                            child: const Text("Opslaan")),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ]),
            ExpansionTile(
                title: const Text("Spelers"),
                controller: playerNameController,
                onExpansionChanged: (value) {
                  if (value) {
                    if (settingsController.isExpanded) {
                      settingsController.collapse();
                    }
                  }
                },
                children: [
                  Form(
                      key: playerNamesFormKey,
                      child: Column(
                        children: widget.playersNames
                            .map((String player) => SizedBox(
                                  width: 100,
                                  child: TextFormField(
                                    initialValue: player,
                                  ),
                                ))
                            .toList(),
                      )),
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                      onPressed: () => print("Spelers opslaan"),
                      child: const Text("Opslaan")),
                  const SizedBox(
                    height: 15,
                  ),
                ])
          ],
        ),
      ),
      body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 10,
              ),
              SingleChildScrollView(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                      children: poules.map(
                    (Poule poule) {
                      return Row(
                        children: [
                          PouleWrapper(poule: poule),
                          const SizedBox(
                            width: 10,
                          )
                        ],
                      );
                    },
                  ).toList()),
                ],
              )),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      ActiveGames(activeGamesList: activeGameList),
                      SizedBox(
                        height: 185,
                        child: PhysicalModel(
                          color: cardBackground,
                          elevation: 20,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  FinalsWrapper(
                    games: finals.games,
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
