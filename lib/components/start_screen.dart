import 'package:darttoernooi/main.dart';
import 'package:flutter/material.dart';
import 'package:darttoernooi/defs.dart';
import 'package:darttoernooi/components/new_game.dart';
import 'package:darttoernooi/components/game_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Darttoernooi"),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            PhysicalModel(
              elevation: 20,
              color: cardBackground,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: cardOutlineColor),
                    borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.fromLTRB(100, 50, 100, 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ElevatedButton(
                        onPressed: () => Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        const NewGame(),
                                transitionDuration:
                                    const Duration(seconds: 0))),
                        style: ButtonStyle(
                          fixedSize:
                              MaterialStateProperty.all(const Size(150, 50)),
                        ),
                        child: const Text(
                          "Nieuw spel",
                          style: TextStyle(fontSize: 20),
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['darts']).then((result) {
                            if (result != null) {
                              if (result.files.single.path!
                                  .endsWith('.darts')) {
                                File file = File(result.files.single.path!);

                                final String saveFileContent =
                                    file.readAsStringSync();

                                Navigator.pushAndRemoveUntil(
                                    context,
                                    PageRouteBuilder(
                                        pageBuilder: (context, _, __) =>
                                            GameScreen(
                                                playersNames: const [],
                                                settings: const [],
                                                numberOfPoules: 0,
                                                saveFileContents:
                                                    saveFileContent)),
                                    ModalRoute.withName('/start_screen'));
                              } else {
                                Flushbar(
                                  message:
                                      "Het gekozen bestandstype is niet ondersteund",
                                  forwardAnimationCurve: Curves.easeIn,
                                  reverseAnimationCurve: Curves.easeOut,
                                  flushbarPosition: FlushbarPosition.BOTTOM,
                                  messageSize: 17,
                                  icon: const Icon(Icons.error),
                                  isDismissible: true,
                                  backgroundColor: flushbarRed,
                                  flushbarStyle: FlushbarStyle.GROUNDED,
                                  duration: const Duration(seconds: 5),
                                ).show(context);
                              }
                            }
                          });
                        },
                        style: ButtonStyle(
                          fixedSize:
                              MaterialStateProperty.all(const Size(150, 50)),
                        ),
                        child: const Text(
                          "Spel laden",
                          style: TextStyle(fontSize: 20),
                        ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
