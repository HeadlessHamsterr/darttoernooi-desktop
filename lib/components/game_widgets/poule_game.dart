import 'package:darttoernooi/defs.dart';
import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/poule.dart';

class PouleGame extends StatefulWidget {
  const PouleGame({super.key, required this.poule});

  final Poule poule;

  @override
  State<PouleGame> createState() => _PouleGameState();
}

class _PouleGameState extends State<PouleGame> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.poule.players,
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
              child: Table()),
        );
      },
    );
  }
}
