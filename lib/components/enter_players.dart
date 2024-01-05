import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/setting.dart';

class EnterPlayers extends StatefulWidget {
  const EnterPlayers(
      {super.key,
      required this.numberOfPlayers,
      required this.numberOfPoules,
      required this.settings});
  final int numberOfPlayers;
  final int numberOfPoules;
  final List<Setting> settings;

  @override
  State<EnterPlayers> createState() => _EnterPlayersState();
}

class _EnterPlayersState extends State<EnterPlayers> {
  final _formKey = GlobalKey<FormState>();
  List<String> players = [];
  List<int> indexList = [];
  @override
  void initState() {
    players.clear();
    indexList.clear();
    for (int i = 0; i < widget.numberOfPlayers; i++) {
      players.add("");
    }
    indexList = Iterable<int>.generate(players.length).toList();
  }

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
      body: Center(
        child: ListView(children: [
          Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              PhysicalModel(
                color: Theme.of(context).colorScheme.background,
                elevation: 20,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black38),
                      borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.fromLTRB(80, 50, 80, 50),
                  child: Column(children: [
                    SizedBox(
                      height: 600,
                      width: 250,
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          children: indexList
                              .map((i) => SizedBox(
                                    width: 150,
                                    child: TextFormField(
                                      initialValue: players[i],
                                      onChanged: (value) => setState(() {
                                        players[i] = value;
                                      }),
                                      validator: (value) {
                                        if (value!.isNotEmpty) {
                                          RegExp regex = RegExp(r'(\w+)');
                                          Iterable<RegExpMatch> matches =
                                              regex.allMatches(value);
                                          if (matches.isNotEmpty) {
                                            return null;
                                          }
                                        }
                                        return "Vul een naam in";
                                      },
                                      decoration: InputDecoration(
                                          hintText: "Speler ${i + 1}"),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade800),
                            child: const Text("Terug")),
                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              FocusManager.instance.primaryFocus!.unfocus();
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();

                                players.shuffle();
                                print(players);
                                print(
                                    "Amount of players: ${widget.numberOfPlayers}");
                                print(
                                    "Amount of poules: ${widget.numberOfPoules}");
                              }
                            },
                            child: const Text("Spel maken"))
                      ],
                    )
                  ]),
                ),
              )
            ],
          ),
        ]),
      ),
    );
  }
}
