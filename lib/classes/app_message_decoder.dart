class AppMessage {
  String gameType = "";
  String gameID = "";
  bool player1Turn = false;
  String startingPlayer = "";

  String player1 = "";
  int player1Score = 0;
  int player1LegsWon = 0;
  double player1Average = 0;
  int player1DartsThrown = 0;

  String player2 = "";
  int player2Score = 0;
  int player2LegsWon = 0;
  double player2Average = 0;
  int player2DartsThrown = 0;

  int thrownScore = 0;

  int legsBestOf = 0;
}

AppMessage appMessageDecoder(String messageType, String message) {
  List<String> messageList = message.split(',');
  AppMessage tempAppMessage = AppMessage();

  print(messageList);

  switch (messageType) {
    case "activeGameInfo":
      tempAppMessage.gameID = messageList[0];
      tempAppMessage.player1Turn = bool.parse(messageList[7]);

      if (messageList[8] == "0") {
        tempAppMessage.startingPlayer = "player1";
      } else {
        tempAppMessage.startingPlayer = "player2";
      }

      print(tempAppMessage.startingPlayer);

      //tempAppMessage.thrownScore = int.parse(messageList[11]);

      tempAppMessage.player1Score = int.parse(messageList[1]);
      tempAppMessage.player1LegsWon = int.parse(messageList[2]);
      tempAppMessage.player1DartsThrown = int.parse(messageList[3]);

      tempAppMessage.player2Score = int.parse(messageList[4]);
      tempAppMessage.player2LegsWon = int.parse(messageList[5]);
      tempAppMessage.player2DartsThrown = int.parse(messageList[6]);

      tempAppMessage.player1 = messageList[9];
      tempAppMessage.player2 = messageList[10];

      tempAppMessage.legsBestOf = int.parse(messageList[11]);

      if (tempAppMessage.gameID[0] == 'h' ||
          tempAppMessage.gameID[0] == 'q' ||
          tempAppMessage.gameID[0] == 'f') {
        tempAppMessage.gameType = 'finals_game';
      } else {
        tempAppMessage.gameType = 'poule_game';
      }
      break;
    case "gamePlayed":
      tempAppMessage.gameID = messageList[0];

      tempAppMessage.player1LegsWon = int.parse(messageList[1]);
      tempAppMessage.player1Average = double.parse(messageList[2]);
      tempAppMessage.player1DartsThrown = int.parse(messageList[3]);

      tempAppMessage.player2LegsWon = int.parse(messageList[4]);
      tempAppMessage.player2Average = double.parse(messageList[5]);
      tempAppMessage.player2DartsThrown = int.parse(messageList[6]);

      if (tempAppMessage.gameID[0] == 'h' ||
          tempAppMessage.gameID[0] == 'q' ||
          tempAppMessage.gameID[0] == 'f') {
        tempAppMessage.gameType = 'finals_game';
      } else {
        tempAppMessage.gameType = 'poule_game';
      }
      break;
  }

  return tempAppMessage;
}
