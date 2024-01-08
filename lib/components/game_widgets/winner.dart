import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/finals_game.dart';

class Winner extends StatelessWidget {
  const Winner({super.key, required this.games});

  final List<FinalsGame> games;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [const Text("Winnaar"), Text(games[0].player1.name)],
    );
  }
}
