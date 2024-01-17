enum FinalsGameType { quart, half, finals, winner }

FinalsGameType toGameType(String gameType) {
  switch (gameType) {
    case "FinalsGameType.quart":
      return FinalsGameType.quart;
    case "FinalsGameType.half":
      return FinalsGameType.half;
    case "FinalsGameType.finals":
      return FinalsGameType.finals;
    case "FinalsGameType.winner":
      return FinalsGameType.winner;
    default:
      return FinalsGameType.winner;
  }
}
