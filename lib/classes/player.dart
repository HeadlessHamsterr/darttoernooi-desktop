class Player {
  final String playerID;
  String pouleNum = "";
  String name = "";
  int legsWon = 0;
  int legsLost = 0;
  int pointsDifference = 0;
  int gamesPlayed = 0;
  List<String> gameIDsPlayed = [];
  double tournamentAverage = 0;
  List<double> averages = [];
  bool allGamesHaveAverages = true;

  Player({required this.playerID, required this.name});

  List<dynamic> convertToArray() {
    return [name, legsWon, legsLost, gamesPlayed];
  }

  void calculatePointsDifference() {
    pointsDifference = legsWon - legsLost;
  }

  void calculateTournamentAverage() {
    double totalAverage = 0;
    allGamesHaveAverages = true;

    for (double average in averages) {
      if (average == 0.0) {
        allGamesHaveAverages = false;
      }
      totalAverage += average;
    }

    tournamentAverage = totalAverage / gamesPlayed;
  }

  void calculateGamesPlayed() {
    gamesPlayed = gameIDsPlayed.length;
  }
}
