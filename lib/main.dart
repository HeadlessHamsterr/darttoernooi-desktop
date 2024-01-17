import 'package:darttoernooi/defs.dart';
import 'package:flutter/material.dart';
import 'package:darttoernooi/components/start_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:darttoernooi/classes/custom_scroll_behavior.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
      onGenerateRoute: (settings) {
        if (settings.name == '/start_screen') {
          return PageRouteBuilder(
            settings:
                settings, // Pass this to make popUntil(), pushNamedAndRemoveUntil(), work
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
  Dio dio = Dio();
  bool checking = true;
  bool newVersionAvailable = false;
  bool downloading = false;
  bool downloadDone = false;
  bool failedToInstall = false;
  String fileURL = "";
  String filename = "";
  double downloadProgress = 0;
  String downloadError = "";
  String filepath = "";

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
      } else {
        for (var asset in body['assets']) {
          if (asset['name'].contains('.exe')) {
            fileURL = asset['browser_download_url'];
            filename = asset['name'];
            break;
          }
        }
        setState(() {});
      }
    });
  }

  void downloadUpdate() async {
    downloading = true;
    setState(() {});

    Directory? downloads = await getDownloadsDirectory();
    if (downloads != null) {
      filepath = '${downloads.path}\\$filename';
      try {
        await dio.download(fileURL, filepath,
            onReceiveProgress: (receivedBytes, totalBytes) {
          setState(() {
            downloadProgress = receivedBytes / totalBytes;
          });
        }, deleteOnError: true).then((_) {
          downloadFinished();
          installUpdate();
        });
      } catch (e) {
        setState(() {
          downloading = false;
          downloadError = e.toString();
        });
      }
    }
  }

  void downloadFinished() {
    setState(() {
      downloading = false;
      downloadDone = true;
    });
  }

  void installUpdate() {
    print("Installing update");
    setState(() {
      failedToInstall = false;
      Process.run(filepath, []).then((ProcessResult value) {
        if (value.exitCode == 0) {
          exit(0);
        } else {
          setState(() {
            failedToInstall = true;
          });
        }
      });
    });
  }

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
                    width: 320,
                    height: 120,
                    child: checking
                        ? checkingUpdate()
                        : newVersionAvailable && !downloading && !downloadDone
                            ? updateAvailable(context, downloadUpdate)
                            : downloading && !downloadDone
                                ? downloadingFile(downloadProgress)
                                : downloadDone
                                    ? !failedToInstall
                                        ? doneDownloading()
                                        : failedToInstallMsg(
                                            context, installUpdate)
                                    : errorDownloading(downloadError)),
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

Widget updateAvailable(BuildContext context, Function downloadUpdate) {
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
              onPressed: () => downloadUpdate(), child: const Text("Ja")),
          const SizedBox(
            width: 20,
          ),
          ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/start_screen', (route) => false),
              child: const Text("Nee"))
        ],
      )
    ],
  );
}

Widget downloadingFile(double progress) {
  return Column(
    children: [
      const Text(
        "Update wordt gedownload",
        style: TextStyle(fontSize: 20),
      ),
      const SizedBox(
        height: 20,
      ),
      LinearProgressIndicator(
        value: progress,
        color: Colors.red,
      )
    ],
  );
}

Widget doneDownloading() {
  return const Column(
    children: [
      Text(
        "Update gedownload!",
        style: TextStyle(fontSize: 20),
      ),
      SizedBox(
        height: 5,
      ),
      Text(
        "De nieuwe versie wordt nu geïnstalleerd",
        style: TextStyle(fontSize: 15),
      ),
      SizedBox(
        height: 20,
      ),
      CircularProgressIndicator()
    ],
  );
}

Widget errorDownloading(String error) {
  return Text("Download error: $error");
}

Widget failedToInstallMsg(BuildContext context, Function installUpdate) {
  return Column(children: [
    const Text(
      "Update installeren is mislukt",
      style: TextStyle(fontSize: 20),
    ),
    const SizedBox(
      height: 5,
    ),
    const Text(
      "Wil je het opnieuw proberen, of doorgaan met de oude versie?",
      style: TextStyle(fontSize: 15),
    ),
    const SizedBox(
      height: 10,
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            onPressed: () => installUpdate(),
            child: const Text("Opnieuw proberen")),
        const SizedBox(
          width: 20,
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/start_screen', (route) => false),
            child: const Text("Doorgaan"))
      ],
    )
  ]);
}
