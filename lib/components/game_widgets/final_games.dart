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

  @override
  void initState() {
    if (widget.games[0].gameType == FinalsGameType.quart) {
      finalName = "Kwartfinale";
    } else if (widget.games[0].gameType == FinalsGameType.half) {
      finalName = "Halve finale";
    } else if (widget.games[0].gameType == FinalsGameType.finals) {
      finalName = "Finale";
    } else if (widget.games[0].gameType == FinalsGameType.winner) {
      finalName = "Winnaar";
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
        ...widget.games.map((FinalsGame game) => Table(
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
                      game.player1.name,
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
                      game.player2.name,
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
                            maxLength: 1,
                            keyboardType: TextInputType.number,
                            enabled: game.player1.name != "" &&
                                    game.player2.name != ""
                                ? true
                                : false,
                            initialValue: game.player1Score > -1
                                ? game.player1Score.toString()
                                : "",
                            onChanged: (value) {
                              if (value == "") {
                                game.resetScore(game.player1);
                              } else {
                                try {
                                  game.updateScore(
                                      game.player1, int.parse(value));
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
                            enabled: game.player2.name != "" &&
                                    game.player1.name != ""
                                ? true
                                : false,
                            initialValue: game.player2Score > -1
                                ? game.player2Score.toString()
                                : "",
                            onChanged: (value) {
                              if (value == "") {
                                game.resetScore(game.player2);
                              } else {
                                try {
                                  game.updateScore(
                                      game.player2, int.parse(value));
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
