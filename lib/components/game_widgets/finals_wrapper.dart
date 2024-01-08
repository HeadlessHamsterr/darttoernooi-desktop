import 'package:darttoernooi/classes/finals_game_types.dart';
import 'package:darttoernooi/defs.dart';
import 'package:flutter/material.dart';
import 'package:darttoernooi/components/game_widgets/final_games.dart';
import 'package:darttoernooi/classes/finals_game.dart';
import 'package:darttoernooi/components/game_widgets/winner.dart';

class FinalsWrapper extends StatefulWidget {
  const FinalsWrapper({super.key, required this.games});

  final FinalsGameNotifier games;

  @override
  State<FinalsWrapper> createState() => _FinalsWrapperState();
}

class _FinalsWrapperState extends State<FinalsWrapper> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: widget.games,
        builder: (BuildContext context, Widget? child) {
          return PhysicalModel(
              color: cardBackground,
              elevation: 20,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                  decoration: BoxDecoration(
                      border: Border.all(color: cardOutlineColor),
                      borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    children: widget.games.finalsGames
                        .map((List<FinalsGame> games) =>
                            games[0].gameType != FinalsGameType.winner
                                ? Row(
                                    children: [
                                      FinalGame(games: games),
                                      const SizedBox(
                                        width: 20,
                                      )
                                    ],
                                  )
                                : Winner(games: games))
                        .toList(),
                  )));
        });
  }
}
