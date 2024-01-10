import 'package:darttoernooi/defs.dart';
import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/game.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PouleGame extends StatefulWidget {
  const PouleGame({super.key, required this.games});

  final GameNotifier games;

  @override
  State<PouleGame> createState() => _PouleGameState();
}

class _PouleGameState extends State<PouleGame> {
  List<List<TextEditingController>> textControllers = [];
  List<int> indexList = [];
  @override
  void initState() {
    super.initState();
    indexList.clear();
    indexList = Iterable<int>.generate(widget.games.games.length).toList();
    textControllers.clear();

    for (Game game in widget.games.games) {
      TextEditingController player1ScoreController = TextEditingController();
      TextEditingController player2ScoreController = TextEditingController();

      game.addListener(() {
        print('Game ${game.gameID} is done');
        print('Setting player1Controller to: ${game.player1Score}');
        print('Setting player2Controller to: ${game.player2Score}');

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
    return ListenableBuilder(
      listenable: widget.games,
      builder: (BuildContext context, Widget? child) {
        return PhysicalModel(
            color: cardBackground,
            elevation: 20,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              decoration: BoxDecoration(
                  border: Border.all(color: cardOutlineColor),
                  borderRadius: BorderRadius.circular(15)),
              child: Column(children: [
                const Text(
                  "Wedstrijden",
                  style: TextStyle(fontSize: 20),
                ),
                ...indexList.map((i) => ListenableBuilder(
                    listenable: widget.games.games[i],
                    builder: (BuildContext context, Widget? child) {
                      return Table(
                        border: const TableBorder(
                          bottom: BorderSide(width: 1, color: Colors.grey),
                        ),
                        columnWidths: const <int, TableColumnWidth>{
                          0: FixedColumnWidth(80),
                          1: FixedColumnWidth(20),
                          2: FixedColumnWidth(80)
                        },
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: <TableRow>[
                          TableRow(children: [
                            Center(
                                child: AutoSizeText(
                              widget.games.games[i].player1.name,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 17,
                              ),
                            )),
                            const Center(child: Text("-")),
                            Center(
                                child: AutoSizeText(
                              widget.games.games[i].player2.name,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 17,
                              ),
                            ))
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
                            )
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
                                      onChanged: (value) {
                                        if (value == "") {
                                          widget.games.games[i].resetScore(
                                              widget.games.games[i].player1);
                                        } else {
                                          try {
                                            widget.games.games[i].updateScore(
                                                widget.games.games[i].player1,
                                                int.parse(value),
                                                0);
                                          } catch (e) {}
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
                                      onChanged: (value) {
                                        if (value == "") {
                                          widget.games.games[i].resetScore(
                                              widget.games.games[i].player2);
                                        } else {
                                          try {
                                            widget.games.games[i].updateScore(
                                                widget.games.games[i].player2,
                                                int.parse(value),
                                                0);
                                          } catch (e) {}
                                        }
                                      },
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    )))
                          ])
                        ],
                      );
                    }))
              ]),
            ));
      },
    );
  }
}
