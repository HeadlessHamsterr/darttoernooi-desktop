import 'package:darttoernooi/defs.dart';
import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/poule.dart';
import 'package:darttoernooi/classes/game.dart';

class FinalsWrapper extends StatefulWidget {
  const FinalsWrapper({super.key});

  @override
  State<FinalsWrapper> createState() => _FinalsWrapperState();
}

class _FinalsWrapperState extends State<FinalsWrapper> {
  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
        color: Theme.of(context).colorScheme.background,
        elevation: 20,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border.all(color: cardOutlineColor),
              borderRadius: BorderRadius.circular(15)),
        ));
  }
}
