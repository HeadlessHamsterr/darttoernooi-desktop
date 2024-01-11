import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/active_game.dart';
import 'package:darttoernooi/components/active_game_widget.dart';

class ActiveGames extends StatefulWidget {
  const ActiveGames({super.key, required this.activeGamesList});

  final ActiveGameList activeGamesList;

  @override
  State<ActiveGames> createState() => _ActiveGamesState();
}

class _ActiveGamesState extends State<ActiveGames> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.activeGamesList,
      builder: (BuildContext context, Widget? child) {
        return Row(
          children: widget.activeGamesList.activeGames
              .map((ActiveGame activeGame) => Row(
                    children: [
                      ActiveGameWidget(game: activeGame),
                      const SizedBox(
                        width: 10,
                      )
                    ],
                  ))
              .toList(),
        );
      },
    );
  }
}
