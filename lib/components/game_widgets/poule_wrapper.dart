import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/poule.dart';
import 'package:darttoernooi/components/game_widgets/poule_sub_widgets/poule_rankings.dart';
import 'package:darttoernooi/components/game_widgets/poule_game.dart';

class PouleWrapper extends StatefulWidget {
  const PouleWrapper({super.key, required this.poule});

  final Poule poule;

  @override
  State<PouleWrapper> createState() => _PouleWrapperState();
}

class _PouleWrapperState extends State<PouleWrapper> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        PouleRankings(
            rankings: widget.poule.rankings, pouleNum: widget.poule.pouleNum),
        const SizedBox(
          height: 10,
        ),
        PouleGame(games: widget.poule.games)
      ],
    );
  }
}
