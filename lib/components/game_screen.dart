import 'dart:convert';
import 'dart:io';
import 'dart:math';
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

const List<String> pouleNums = ["A", "B", "C", "D"];

class Game extends StatefulWidget {
  const Game(
      {super.key,
      required this.playersNames,
      required this.settings,
      required this.numberOfPoules});

  final List<String> playersNames;
  final List<Setting> settings;
  final int numberOfPoules;

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  late RawDatagramSocket udpReceiver;
  List<Poule> poules = [];
  String serverName = "";
  late Finals finals;
  var io = Server();

  @override
  void initState() {
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
                  if (addr.address.isNotEmpty) {
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

    finals = Finals(amountOfPoules: widget.numberOfPoules);
    finals.generateFinalsGames();
    generatePoules();

    io.on('connection', (client) {
      print('Websocket client connected');
      client.emit('fromServer', 'ok');
      client.on('clientGreeting', (data) {
        print('Data from client: $data');
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
        print(msg);
        client.emit('pouleInfo', msg);
      });

      client.on('singlePouleInfoRequest', (data) {
        print("Poule info request for Poule $data");
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
    });
    io.listen(11520);
  }

  void onPouleDone(Poule poule) {
    finals.updateWinners(poule);
  }

  void generatePoules() {
    for (int i = 0; i < widget.numberOfPoules; i++) {
      poules.add(Poule(pouleNum: pouleNums[i], onGameDone: onPouleDone));
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

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(serverName),
          leading: IconButton(
            onPressed: () => io.close().then((value) {
              udpReceiver.close();
              Navigator.popUntil(context, (route) => route.isFirst);
            }),
            icon: const Icon(Icons.home),
          )),
      body: SingleChildScrollView(
        child: Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            Row(
                children: poules.map(
              (Poule poule) {
                return Row(
                  children: [
                    PouleWrapper(poule: poule),
                    const SizedBox(
                      width: 20,
                    )
                  ],
                );
              },
            ).toList()),
            FinalsWrapper(
              games: finals.games,
            )
          ],
        ),
      ),
    );
  }
}
