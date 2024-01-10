import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/active_game.dart';
import 'package:darttoernooi/defs.dart';
import 'package:darttoernooi/outs.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ActiveGameWidget extends StatefulWidget {
  const ActiveGameWidget({super.key, required this.game});

  final ActiveGame game;

  @override
  State<ActiveGameWidget> createState() => _ActiveGameWidgetState();
}

class _ActiveGameWidgetState extends State<ActiveGameWidget> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: widget.game,
        builder: (BuildContext context, Widget? child) {
          return PhysicalModel(
            elevation: 20,
            color: cardBackground,
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 20),
              child: Table(
                columnWidths: const <int, TableColumnWidth>{
                  0: FixedColumnWidth(200),
                  1: FixedColumnWidth(10),
                  2: FixedColumnWidth(200),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(children: [
                    Center(
                        child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            widget.game.startingPlayer == "player1"
                                ? const Icon(
                                    Icons.fiber_manual_record,
                                    color: Colors.red,
                                    size: 10,
                                  )
                                : const SizedBox(),
                            AutoSizeText(
                              widget.game.player1,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 30),
                            ),
                          ],
                        ),
                        Text(
                          'Legs: ${widget.game.player1LegsWon}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    )),
                    Center(
                        child: AnimatedRotation(
                      turns: widget.game.player1Turn ? 0 : 0.5,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 30,
                      ),
                    )),
                    Center(
                        child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AutoSizeText(
                              widget.game.player2,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 30),
                            ),
                            widget.game.startingPlayer == "player2"
                                ? const Icon(
                                    Icons.fiber_manual_record,
                                    color: Colors.red,
                                    size: 10,
                                  )
                                : const SizedBox()
                          ],
                        ),
                        Text(
                          'Legs: ${widget.game.player2LegsWon}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    )),
                  ]),
                  TableRow(children: [
                    Center(
                      child: Text(
                        widget.game.player1Score.toString(),
                        style: const TextStyle(fontSize: 50),
                      ),
                    ),
                    const SizedBox(),
                    Center(
                      child: Text(
                        widget.game.player2Score.toString(),
                        style: const TextStyle(fontSize: 50),
                      ),
                    ),
                  ]),
                  TableRow(children: [
                    Center(
                      child: Text(
                          widget.game.player1Score <= 170
                              ? outs[170 - widget.game.player1Score]
                              : "",
                          style: const TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(),
                    Center(
                      child: Text(
                        widget.game.player2Score <= 170
                            ? outs[170 - widget.game.player2Score]
                            : "",
                        style: const TextStyle(fontSize: 20),
                      ),
                    )
                  ])
                ],
              ),
            ),
          );
        });
  }
}
