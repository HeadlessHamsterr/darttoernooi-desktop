import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/player.dart';
import 'package:darttoernooi/classes/poule.dart';
import 'package:darttoernooi/classes/setting.dart';
import 'package:uuid/uuid.dart';
import 'package:darttoernooi/components/game_widgets/poule_rankings/poule_rankings.dart';

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
  List<Poule> poules = [];

  @override
  void initState() {
    generatePoules();
  }

  void generatePoules() {
    for (int i = 0; i < widget.numberOfPoules; i++) {
      poules.add(Poule(pouleNum: pouleNums[i], players: []));
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
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Wedstrijd"),
          leading: IconButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            icon: const Icon(Icons.home),
          )),
      body: Column(
        children: [Row()],
      ),
    );
  }
}
