import 'package:flutter/material.dart';
import 'package:darttoernooi/defs.dart';
import 'package:darttoernooi/classes/players_notifier.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PouleRankings extends StatefulWidget {
  const PouleRankings(
      {super.key, required this.rankings, required this.pouleNum});
  final PlayersNotifier rankings;
  final String pouleNum;

  @override
  State<PouleRankings> createState() => _PouleRankingsState();
}

class _PouleRankingsState extends State<PouleRankings> {
  List<int> playerIndexList = [];

  @override
  void initState() {
    playerIndexList.clear();
    playerIndexList =
        Iterable<int>.generate(widget.rankings.players.length).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.rankings,
      builder: (BuildContext context, Widget? child) {
        playerIndexList =
            Iterable<int>.generate(widget.rankings.players.length).toList();
        return PhysicalModel(
            elevation: 20,
            color: cardBackground,
            borderRadius: BorderRadius.circular(15),
            child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(color: cardOutlineColor),
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    Text(
                      "Poule ${widget.pouleNum}",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Table(
                      border: const TableBorder(
                        horizontalInside:
                            BorderSide(width: 1, color: Colors.grey),
                      ),
                      columnWidths: const <int, TableColumnWidth>{
                        0: FixedColumnWidth(80),
                        1: FixedColumnWidth(50),
                        2: FixedColumnWidth(50),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: <TableRow>[
                        const TableRow(children: <Widget>[
                          Center(
                              child: Text(
                            "Speler",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          )),
                          Center(
                              child: Text(
                            "Score",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          )),
                          Center(
                              child: Text(
                            "Saldo",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ))
                        ]),
                        ...playerIndexList
                            .map((int i) => TableRow(
                                  children: [
                                    Center(
                                      child: Tooltip(
                                        message:
                                            "Gemiddelde score: ${widget.rankings.players[i].tournamentAverage.toString()}",
                                        child: AutoSizeText(
                                          widget.rankings.players[i].name,
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: i == 0
                                                  ? Colors.amber
                                                  : i == 1
                                                      ? Colors.grey
                                                      : Colors.white),
                                        ),
                                      ),
                                    ),
                                    Center(
                                        child: Text(widget
                                            .rankings.players[i].legsWon
                                            .toString())),
                                    Center(
                                        child: Text(widget.rankings.players[i]
                                            .pointsDifference
                                            .toString()))
                                  ],
                                ))
                            .toList()
                      ],
                    ),
                  ],
                )));
      },
    );
  }
}
