import 'package:flutter/material.dart';

const Color cardOutlineColor = Color.fromARGB(95, 10, 10, 10);

List<List<int>> getGameFormat(int amountOfPlayers) {
  List<List<int>> gameFormat = [[]];
  switch (amountOfPlayers) {
    case 2:
      gameFormat = [
        [0, 1]
      ];
      break;
    case 3:
      gameFormat = [
        [0, 1],
        [1, 2],
        [0, 2]
      ];
      break;
    case 4:
      gameFormat = [
        [0, 1],
        [0, 2],
        [0, 3],
        [1, 3],
        [1, 2],
        [2, 3]
      ];
      break;
    case 5:
      gameFormat = [
        [0, 1],
        [0, 2],
        [0, 3],
        [0, 4],
        [1, 2],
        [1, 3],
        [1, 4],
        [2, 3],
        [2, 4],
        [3, 4]
      ];
  }
  gameFormat.shuffle();
  return gameFormat;
}
