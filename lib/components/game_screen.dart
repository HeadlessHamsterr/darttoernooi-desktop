import 'dart:convert';
import 'dart:io';
import 'dart:math';
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

const List<String> pouleNums = ["A", "B", "C", "D"];

class GameScreen extends StatefulWidget {
  const GameScreen(
      {super.key,
      required this.playersNames,
      required this.settings,
      required this.numberOfPoules});

  final List<String> playersNames;
  final List<Setting> settings;
  final int numberOfPoules;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Setting> newSettings = [];
  late RawDatagramSocket udpReceiver;
  List<Poule> poules = [];
  ActiveGameList activeGameList = ActiveGameList();
  String serverName = "";
  late Finals finals;
  var io = Server();

  final ExpansionTileController settingsController = ExpansionTileController();
  final ExpansionTileController playerNameController =
      ExpansionTileController();
  final settingsFormKey = GlobalKey<FormState>();
  final playerNamesFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    newSettings = List.from(widget.settings);
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

    generatePoules();
    finals = Finals(
        amountOfPoules: widget.numberOfPoules, onFinalDone: sendFinalsInfo);
    finals.generateFinalsGames();

    io.on('connection', (client) {
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
        }
      });

      client.on('stopActiveGame', (gameID) {
        activeGameList.removeGame(gameID);
      });

      client.on('gamePlayed', (data) {
        AppMessage appMessage = appMessageDecoder('gamePlayed', data);
        activeGameList.removeGame(appMessage.gameID);

        if (appMessage.gameType == "finals_game") {
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
          print(
              "Finishing game ${gameToEdit.gameID} with player 1: ${appMessage.player1Average} and player 2: ${appMessage.player2Average}");
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
    io.listen(11520);
  }

  void sendPouleInfo(String pouleNum) {
    print("Poule info request for Poule $pouleNum");
    int pouleIndex =
        poules.indexWhere((Poule poule) => poule.pouleNum == pouleNum);

    if (pouleIndex == -1) {
      List msg = [
        ['No active', 'game']
      ];
      io.emit('poule${pouleNum}Ranks', msg);
    } else {
      List msg = [
        poules[pouleIndex].rankings.convertToList(),
        poules[pouleIndex].games.convertToList(),
        'poule'
      ];

      io.emit('poule${pouleNum}Ranks', msg);
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
    io.emit('finalsInfo', message);
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
      io.emit('settingsUpdate', settings);

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

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(serverName),
        leading: IconButton(
          onPressed: () {
            io.emit("gameClose", "doei");

            io.close().then((value) {
              udpReceiver.close();
              Navigator.popUntil(context, ModalRoute.withName('/start_screen'));
            });
          },
          icon: const Icon(Icons.home),
        ),
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
                                      if (int.parse(value) >= 0) {
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
