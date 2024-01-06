import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/player.dart';
import 'package:darttoernooi/defs.dart';
import 'package:darttoernooi/components/game_widgets/poule_rankings/player_rank_row.dart';

class PouleRankings extends StatefulWidget {
  const PouleRankings(
      {super.key, required this.players, required this.pouleNum});
  final List<Player> players;
  final String pouleNum;

  @override
  State<PouleRankings> createState() => _PouleRankingsState();
}

class _PouleRankingsState extends State<PouleRankings> {
  List<Player> sortedPlayers = [];

  @override
  void initState() {
    sortedPlayers = List<Player>.from(widget.players);
  }

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      elevation: 20,
      color: Theme.of(context).colorScheme.background,
      borderRadius: BorderRadius.circular(15),
      child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: cardOutlineColor),
              borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.all(50),
          child: Column(
            children: [
              const Row(
                children: [Text("Speler"), Text("Score"), Text("Saldo")],
              ),
              ...sortedPlayers.map((Player player) => PlayerRankRow(
                  name: player.name,
                  legsWon: player.legsWon,
                  legsDifference: player.pointsDifference,
                  averageScore: player.tournamentAverage,
                  position: 0))
            ],
          )),
    );
  }
}
