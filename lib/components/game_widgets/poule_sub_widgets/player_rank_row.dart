import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/player.dart';

class PlayerRankRow extends TableRow {
  final Player player;
  final int position;

  const PlayerRankRow(
      {super.key, required this.player, required this.position});

  TableRow build(BuildContext context) {
    return TableRow(
      children: [
        Text(
          player.name,
          style: TextStyle(
              color: position == 0
                  ? Colors.amber
                  : position == 1
                      ? Colors.grey
                      : Colors.white),
        ),
        Text(player.legsWon.toString()),
        Text(player.pointsDifference.toString())
      ],
    );
  }
}
