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
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.games,
      builder: (BuildContext context, Widget? child) {
        return PhysicalModel(
            color: Theme.of(context).colorScheme.background,
            elevation: 20,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: cardOutlineColor),
                  borderRadius: BorderRadius.circular(15)),
              child: Column(children: [
                const Text(
                  "Wedstrijden",
                  style: TextStyle(fontSize: 15),
                ),
                ...widget.games.games.map((game) => Table(
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
                            game.player1.name,
                            maxLines: 1,
                          )),
                          const Center(child: Text("-")),
                          Center(
                              child: AutoSizeText(
                            game.player2.name,
                            maxLines: 1,
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
                                    maxLength: 1,
                                    keyboardType: TextInputType.number,
                                    initialValue: game.player1Score > -1
                                        ? game.player1Score.toString()
                                        : "",
                                    onChanged: (value) {
                                      if (value == "") {
                                        game.resetScore(game.player1);
                                      } else {
                                        try {
                                          game.updateScore(game.player1,
                                              int.parse(value), 0);
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
                                    maxLength: 1,
                                    keyboardType: TextInputType.number,
                                    initialValue: game.player2Score > -1
                                        ? game.player2Score.toString()
                                        : "",
                                    onChanged: (value) {
                                      if (value == "") {
                                        game.resetScore(game.player2);
                                      } else {
                                        try {
                                          game.updateScore(game.player2,
                                              int.parse(value), 0);
                                        } catch (e) {}
                                        ;
                                      }
                                    },
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  )))
                        ])
                      ],
                    ))
              ]),
            ));
      },
    );
  }
}
