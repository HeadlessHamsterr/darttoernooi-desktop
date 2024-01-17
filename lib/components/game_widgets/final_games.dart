import 'package:auto_size_text/auto_size_text.dart';
import 'package:darttoernooi/classes/finals_game_types.dart';
import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/finals_game.dart';

class FinalGame extends StatefulWidget {
  const FinalGame({super.key, required this.games});

  final List<FinalsGame> games;

  @override
  State<FinalGame> createState() => _FinalGameState();
}

class _FinalGameState extends State<FinalGame> {
  String finalName = "";
  List<List<TextEditingController>> textControllers = [];
  List<int> indexList = [];

  @override
  void initState() {
    super.initState();
    if (widget.games[0].gameType == FinalsGameType.quart) {
      finalName = "Kwartfinale";
    } else if (widget.games[0].gameType == FinalsGameType.half) {
      finalName = "Halve finale";
    } else if (widget.games[0].gameType == FinalsGameType.finals) {
      finalName = "Finale";
    } else if (widget.games[0].gameType == FinalsGameType.winner) {
      finalName = "Winnaar";
    }

    indexList.clear();
    indexList = Iterable<int>.generate(widget.games.length).toList();
    textControllers.clear();

    for (FinalsGame game in widget.games) {
      TextEditingController player1ScoreController = TextEditingController();
      TextEditingController player2ScoreController = TextEditingController();

      game.addListener(() {
        if (game.player1Score > -1) {
          player1ScoreController.text = game.player1Score.toString();
        }

        if (game.player2Score > -1) {
          player2ScoreController.text = game.player2Score.toString();
        }
      });

      textControllers.add([player1ScoreController, player2ScoreController]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          finalName,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(
          height: 20,
        ),
        ...indexList.map((i) => Table(
              border: const TableBorder(
                  bottom: BorderSide(width: 1, color: Colors.grey)),
              columnWidths: const <int, TableColumnWidth>{
                0: FixedColumnWidth(80),
                1: FixedColumnWidth(20),
                2: FixedColumnWidth(80)
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                TableRow(children: [
                  Center(
                    child: AutoSizeText(
                      widget.games[i].player1.name,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text("-"),
                  ),
                  Center(
                    child: AutoSizeText(
                      widget.games[i].player2.name,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  )
                ]),
                const TableRow(children: [
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ]),
                TableRow(children: [
                  Center(
                      child: SizedBox(
                          width: 15,
                          height: 40,
                          child: TextFormField(
                            controller: textControllers[i][0],
                            maxLength: 1,
                            keyboardType: TextInputType.number,
                            enabled: widget.games[i].player1.name != "" &&
                                    widget.games[i].player2.name != ""
                                ? true
                                : false,
                            onChanged: (value) {
                              if (value == "") {
                                widget.games[i]
                                    .resetScore(widget.games[i].player1);
                              } else {
                                try {
                                  widget.games[i].updateScore(
                                      widget.games[i].player1,
                                      int.parse(value));
                                } catch (e) {}
                                ;
                              }
                            },
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ))),
                  const Center(child: Text("")),
                  Center(
                      child: SizedBox(
                          width: 15,
                          height: 40,
                          child: TextFormField(
                            controller: textControllers[i][1],
                            maxLength: 1,
                            keyboardType: TextInputType.number,
                            enabled: widget.games[i].player2.name != "" &&
                                    widget.games[i].player1.name != ""
                                ? true
                                : false,
                            onChanged: (value) {
                              if (value == "") {
                                widget.games[i]
                                    .resetScore(widget.games[i].player2);
                              } else {
                                try {
                                  widget.games[i].updateScore(
                                      widget.games[i].player2,
                                      int.parse(value));
                                } catch (e) {}
                                ;
                              }
                            },
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          )))
                ])
              ],
            ))
      ],
    );
  }
}
