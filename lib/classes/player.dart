class Player {
  final String playerID;
  String pouleNum = "";
  String name = "";
  int legsWon = 0;
  int legsLost = 0;
  int pointsDifference = 0;
  int gamesPlayed = 0;
  double legAverage = 0;
  double tournamentAverage = 0;

  Player({required this.playerID, required this.name});

  List<dynamic> convertToArray() {
    return [name, legsWon, legsLost, gamesPlayed];
  }

  void calculatePointsDifference() {
    pointsDifference = legsWon - legsLost;
  }
}
