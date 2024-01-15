import 'package:darttoernooi/defs.dart';
import 'package:flutter/material.dart';
import 'package:darttoernooi/components/start_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:darttoernooi/classes/custom_scroll_behavior.dart';

const List<int> appVersion = [0, 1, 0];

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Darttoernooi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
          surface: const Color.fromRGBO(92, 0, 0, 1),
          background: const Color.fromRGBO(24, 24, 24, 1),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      //routes: {'/start_screen': (context) => const StartScreen()},
      onGenerateRoute: (settings) {
        if (settings.name == '/start_screen') {
          return PageRouteBuilder(
            settings:
                settings, // Pass this to make popUntil(), pushNamedAndRemoveUntil(), works
            pageBuilder: (_, __, ___) => const StartScreen(),
          );
        }
      },
      debugShowCheckedModeBanner: false,
      scrollBehavior: CustomScrollBehavior(),
      home: const CheckUpdate(),
    );
  }
}

class CheckUpdate extends StatefulWidget {
  const CheckUpdate({super.key});

  @override
  State<CheckUpdate> createState() => _CheckUpdateState();
}

class _CheckUpdateState extends State<CheckUpdate> {
  bool checking = false;
  bool newVersionAvailable = false;
  bool downloading = false;
  bool downloadDone = false;

  @override
  void initState() {
    super.initState();

    http
        .get(Uri.https('api.github.com',
            '/repos/HeadlessHamsterr/darttoernooi-desktop/releases/latest'))
        .then((value) {
      final body = json.decode(value.body);
      String tagName = body['tag_name'];
      List<int> latestVersion = [];
      tagName
          .replaceAll('V', '')
          .split('.')
          .forEach((element) => latestVersion.add(int.parse(element)));

      if (latestVersion[0] > appVersion[0]) {
        newVersionAvailable = true;
      } else if (latestVersion[0] == appVersion[0] &&
          latestVersion[1] > appVersion[1]) {
        newVersionAvailable = true;
      } else if (latestVersion[0] == appVersion[0] &&
          latestVersion[1] == appVersion[1] &&
          latestVersion[2] > appVersion[2]) {
        newVersionAvailable = true;
      }

      checking = false;

      if (!newVersionAvailable) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/start_screen', (route) => false);
      }
    });
  }

  void installUpdate() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Darttoernooi')),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            PhysicalModel(
              color: cardBackground,
              elevation: 20,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                    width: 300,
                    height: 120,
                    child: !checking
                        ? checkingUpdate()
                        : newVersionAvailable && !downloading && !downloadDone
                            ? updateAvailable()
                            : downloading && !downloadDone
                                ? downloadingFile()
                                : downloadDone
                                    ? doneDownloading()
                                    : errorDownloading()),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget checkingUpdate() {
  return const Column(
    children: [
      Text(
        'Zoeken naar een update',
        style: TextStyle(fontSize: 20),
      ),
      SizedBox(
        height: 20,
      ),
      CircularProgressIndicator()
    ],
  );
}

Widget updateAvailable() {
  return Column(
    children: [
      const Text(
        "Update beschikbaar",
        style: TextStyle(fontSize: 20),
      ),
      const SizedBox(
        height: 5,
      ),
      const Text(
        "Wil je de update installeren?",
        style: TextStyle(fontSize: 15),
      ),
      const SizedBox(
        height: 20,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () => print("Install"), child: const Text("Ja")),
          const SizedBox(
            width: 20,
          ),
          ElevatedButton(
              onPressed: () => print("Don't install"), child: const Text("Nee"))
        ],
      )
    ],
  );
}

Widget downloadingFile() {
  return const Text("Downloading...");
}

Widget doneDownloading() {
  return const Text("Download done");
}

Widget errorDownloading() {
  return const Text("Download error");
}
