import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/settings_row.dart';
import 'package:darttoernooi/classes/setting.dart';
import 'package:darttoernooi/components/enter_players.dart';
import 'package:darttoernooi/defs.dart';

class NewGame extends StatefulWidget {
  const NewGame({super.key});

  @override
  State<NewGame> createState() => _NewGameState();
}

class _NewGameState extends State<NewGame> {
  final _formKey = GlobalKey<FormState>();
  int numberOfPlayers = 0;
  int numberOfPoules = 0;

  List<Setting> settings = [
    const Setting(
        name: 'pouleScore',
        friendlyName: 'Poule beginscore',
        type: 'textfield',
        defaultValue: '301'),
    const Setting(
        name: 'pouleLegs',
        friendlyName: 'Poule best of',
        type: 'textfield',
        defaultValue: '3'),
    const Setting(
        name: 'quartScore',
        friendlyName: 'Kwartfinale beginscore',
        type: 'textfield',
        defaultValue: '301'),
    const Setting(
        name: 'quartLegs',
        friendlyName: 'Kwartfinale best of',
        type: 'textfield',
        defaultValue: '3'),
    const Setting(
        name: 'halfScore',
        friendlyName: 'Halve finale beginscore',
        type: 'textfield',
        defaultValue: '301'),
    const Setting(
        name: 'halfLegs',
        friendlyName: 'Halve finale best of',
        type: 'textfield',
        defaultValue: '5'),
    const Setting(
        name: 'finalScore',
        friendlyName: 'Finale beginscore',
        type: 'textfield',
        defaultValue: '501'),
    const Setting(
        name: 'finalLegs',
        friendlyName: 'Finale best of',
        type: 'textfield',
        defaultValue: '5'),
  ];
  List<Setting> otherSettings = [
    /*const Setting(
        name: "panMode",
        friendlyName: "Pan modus",
        type: "checkbox",
        defaultValue: 'false')*/
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nieuw spel"),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () =>
              Navigator.popUntil(context, (route) => route.isFirst),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: SizedBox(
            height: 1000,
            width: 400,
            child: ListView(children: [
              const SizedBox(
                height: 50,
              ),
              PhysicalModel(
                color: Theme.of(context).colorScheme.background,
                elevation: 20,
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
                      SizedBox(
                        width: 150,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: "Aantal spelers",
                              helperText: "(max 20)"),
                          onSaved: (String? value) {
                            if (value!.isNotEmpty) {
                              numberOfPlayers = int.parse(value.toString());
                            }
                          },
                          validator: (value) {
                            if (value!.isNotEmpty) {
                              RegExp regex = RegExp(r'([0-9]+)');
                              Iterable<RegExpMatch> matches =
                                  regex.allMatches(value);
                              if (matches.isNotEmpty) {
                                try {
                                  if (int.parse(value) >= 0) {
                                    return null;
                                  }
                                } catch (e) {
                                  return "Vul een rond getal in";
                                }
                              }
                              return "Vul een getal in";
                            }
                            return "Vul een getal in";
                          },
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: "Aantal poules",
                              helperText: "(max 4)"),
                          onSaved: (String? value) {
                            if (value!.isNotEmpty) {
                              numberOfPoules = int.parse(value.toString());
                            }
                          },
                          validator: (value) {
                            if (value!.isNotEmpty) {
                              RegExp regex = RegExp(r'([0-9]+)');
                              Iterable<RegExpMatch> matches =
                                  regex.allMatches(value);
                              if (matches.isNotEmpty) {
                                try {
                                  if (int.parse(value) >= 0) {
                                    return null;
                                  }
                                } catch (e) {
                                  return "Vul een rond getal in";
                                }
                              }
                              return "Vul een getal in";
                            }
                            return "Vul een getal in";
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: 200,
                        child: ExpansionTile(
                          title: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Icon(Icons.settings),
                                Text("Legs & Sets")
                              ]),
                          children: settings
                              .map((e) => SettingsRow(
                                    setting: e,
                                    onChange: (e) {
                                      int settingIndex = settings.indexWhere(
                                          (element) => element.name == e.name);

                                      settings[settingIndex] = e;
                                    },
                                  ))
                              .toList(),
                        ),
                      ),
                      otherSettings.isNotEmpty
                          ? SizedBox(
                              width: 200,
                              child: ExpansionTile(
                                title: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Icon(Icons.settings),
                                      Text("Overig")
                                    ]),
                                children: otherSettings
                                    .map((e) => SettingsRow(
                                          setting: e,
                                          onChange: (e) {
                                            int settingIndex = otherSettings
                                                .indexWhere((element) =>
                                                    element.name == e.name);
                                            otherSettings[settingIndex] = e;
                                          },
                                        ))
                                    .toList(),
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            FocusManager.instance.primaryFocus!.unfocus();
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              print(numberOfPlayers);
                              if (numberOfPlayers > 20) {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text("Sluiten"))
                                          ],
                                          title: Text(
                                              "$numberOfPlayers spelers is te veel."),
                                          content: const Text(
                                              "Er mogen maximaal 20 spelers meedoen."),
                                        ));
                              } else if (numberOfPlayers < 2) {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text("Sluiten"))
                                          ],
                                          title: Text(
                                              "$numberOfPlayers ${numberOfPlayers == 1 ? "speler" : "spelers"} is te weinig."),
                                          content: const Text(
                                              "Er moeten minimaal 2 spelers meedoen."),
                                        ));
                              } else if (numberOfPoules > 4) {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text("Sluiten"))
                                          ],
                                          title: Text(
                                              "$numberOfPoules poules is te veel."),
                                          content: const Text(
                                              "Er kunnen maximaal 4 poules gemaakt worden."),
                                        ));
                              } else if (numberOfPoules < 1) {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text("Sluiten"))
                                          ],
                                          title: const Text("Maat."),
                                          content: const Text(
                                              "Je moet wel poules toevoegen"),
                                        ));
                              } else if (numberOfPlayers / numberOfPoules > 5) {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text("Sluiten"))
                                          ],
                                          title: const Text(
                                              "Te veel spelers per poule."),
                                          content: Text(
                                              "Er kunnen maar 5 spelers in elke poule. \nIn deze configuratie is het ${double.parse((numberOfPlayers / numberOfPoules).toStringAsFixed(2))} spelers per poule."),
                                        ));
                              } else if (numberOfPlayers / numberOfPoules < 2) {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text("Sluiten"))
                                          ],
                                          title: const Text(
                                              "Te weinig spelers per poule."),
                                          content: Text(
                                              "Er moeten minimaal 2 spelers in elke poule. \nIn deze configuratie is het ${double.parse((numberOfPlayers / numberOfPoules).toStringAsFixed(2))} spelers per poule."),
                                        ));
                              } else {
                                Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                        pageBuilder: (context, animation1,
                                                animation2) =>
                                            EnterPlayers(
                                              numberOfPlayers: numberOfPlayers,
                                              numberOfPoules: numberOfPoules,
                                              settings: settings,
                                            ),
                                        transitionDuration:
                                            const Duration(seconds: 0)));
                              }
                            }
                          },
                          child: const Text("Spel starten"))
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
