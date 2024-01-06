import 'package:flutter/material.dart';

class PlayerRankRow extends StatelessWidget {
  final String name;
  final int legsWon;
  final int legsDifference;
  final double averageScore;
  final int position;

  const PlayerRankRow(
      {super.key,
      required this.name,
      required this.legsWon,
      required this.legsDifference,
      required this.averageScore,
      required this.position});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          name,
          style: TextStyle(
              color: position == 0
                  ? Colors.amber
                  : position == 1
                      ? Colors.grey
                      : Colors.white),
        ),
        Text(legsWon.toString()),
        Text(legsDifference.toString())
      ],
    );
  }
}
