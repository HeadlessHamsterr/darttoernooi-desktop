import 'package:flutter/material.dart';

const Color cardOutlineColor = Color.fromARGB(95, 10, 10, 10);
const Color cardBackground = Color.fromRGBO(36, 36, 36, 1);
const Color flushbarGreen = Color.fromRGBO(56, 142, 60, 1);
const Color flushbarRed = Color.fromRGBO(211, 47, 47, 1);
const List<int> appVersion = [4, 3, 1];

const List<String> supportedSaveGameVersions = [
  "4.0.0",
  "4.1.0",
  "4.2.0",
  "4.3.0",
  "4.3.1"
];
const List<String> specialSounds = ["006", "020", "023", "042", "063", "064"];

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

List<List<int>> getFinalsGameFormat(int amountOfPoules) {
  switch (amountOfPoules) {
    case 2:
      return [
        [0, 1],
        [1, 0]
      ];
      break;
    case 3:
      return [
        [0, 2],
        [1, 0],
        [2, 1]
      ];
      break;
    case 4:
      return [
        [0, 3],
        [1, 2],
        [2, 0],
        [3, 1]
      ];
      break;
    default:
      return [
        [0, 0]
      ];
  }
}
