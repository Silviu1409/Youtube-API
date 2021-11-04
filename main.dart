// ignore_for_file: non_constant_identifier_names, unnecessary_new, avoid_unnecessary_containers, curly_braces_in_flow_control_structures, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_api/youtube_api.dart';
import 'dart:io';
import 'dart:async';
import 'package:device_apps/device_apps.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const YoutubeDownloader());

class YoutubeDownloader extends StatelessWidget {
  const YoutubeDownloader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Youtube Downloader',
      home: Home(),
    );
  }
}

_openApp() async {
  bool vanced = await DeviceApps.isAppInstalled('com.vanced.android.youtube');
  bool youtube = await DeviceApps.isAppInstalled('com.google.android.youtube');
  if (vanced) {
    DeviceApps.openApp('com.vanced.android.youtube');
    return;
  } else if (youtube) {
    DeviceApps.openApp('com.google.android.youtube');
    return;
  }
  if (await canLaunch("https://www.youtube.com")) {
    await launch("https://www.youtube.com");
  } else {
    throw 'Cannot launch Youtube';
  }
}

int index = 0;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final controller = TextEditingController();
  String option = " ";
  List<String> choices = ['Video & audio', 'Video only', 'Audio only'];
  bool isDownloading = false;
  String filePath = "";
  int _selectedIndex = 0;

  @override
  void dispose() {
    controller.dispose();
    controller_search.dispose();
    super.dispose();
  }

  _saveValue(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("key", value);
    return true;
  }

  _getSavedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("key") != null) {
      option = prefs.getString("key") as String;
    } else {
      option = "Video & audio";
    }
  }

  f() async {
    isDownloading = false;
    setState(() {});
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Download completed and saved to: $filePath'),
          );
        });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static List<String> keys = [
    "Your-API-Key-1",
    "Your-API-Key-2",
    "Your-API-Key-3",
    "Your-API-Key-4"
  ];
  YoutubeAPI youtube = YoutubeAPI(keys[index]);
  List<YouTubeVideo> videoResult = [];
  final controller_search = TextEditingController();
  bool hasloaded = true;
  bool noAPIkeys = false;

  Future<void> callApi(nume) async {
    String query = nume;
    try {
      videoResult =
          await youtube.search(query, order: 'relevance', videoDuration: 'any');
    } catch (_) {
      if (index < keys.length - 1) {
        index += 1;
        hasloaded = false;
        youtube = new YoutubeAPI(keys[index]);
        callApi(nume);
      } else {
        noAPIkeys = true;
        setState(() {});
        return;
      }
    }
    videoResult = await youtube.nextPage();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  Widget listItem(YouTubeVideo video) {
    return Card(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 7.0),
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Image.network(
                video.thumbnail.small.url ?? '',
                width: 120.0,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    video.title,
                    softWrap: true,
                    style: const TextStyle(fontSize: 18.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Text(
                      video.channelTitle,
                      softWrap: true,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    video.url,
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _getSavedValue();
    return WillPopScope(
      onWillPop: onBackPressed,
      child: new Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _selectedIndex == 0
            ? AppBar(
                elevation: 0,
                backgroundColor: Colors.grey[800],
                title: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: RichText(
                        text: const TextSpan(
                          text: "Youtube Downloader",
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 35.0),
                      child: IconButton(
                        icon: Image.asset('assets/da.png'),
                        onPressed: _openApp,
                        iconSize: 35,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: IconButton(
                        icon: const Icon(Icons.settings),
                        color: Colors.white,
                        onPressed: () {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return StatefulBuilder(builder:
                                    (BuildContext context,
                                        StateSetter setState) {
                                  return AlertDialog(
                                    content: SingleChildScrollView(
                                      child: Column(
                                        children: <Widget>[
                                          Center(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0.0, 5.0, 0.0, 75.0),
                                              child: RichText(
                                                text: const TextSpan(
                                                  text:
                                                      "Select download option : ",
                                                  style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            child: DropdownButton(
                                              value: option,
                                              icon: const Icon(
                                                  Icons.arrow_downward),
                                              iconSize: 20,
                                              elevation: 0,
                                              dropdownColor: Colors.transparent,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 17,
                                              ),
                                              underline: Container(
                                                height: 2,
                                                color: Colors.blue,
                                              ),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  option = newValue!;
                                                });
                                              },
                                              items: choices.map<
                                                      DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                          child: const Text('Apply'),
                                          onPressed: () {
                                            _saveValue(option);
                                            Navigator.of(context).pop();
                                          })
                                    ],
                                  );
                                });
                              });
                        },
                      ),
                    ),
                  ],
                ),
              )
            : AppBar(
                elevation: 0,
                backgroundColor: Colors.grey[800],
                toolbarHeight: 60.0,
                title: Center(
                  child: Container(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: RichText(
                      text: const TextSpan(
                        text: "Youtube Search API",
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        body: _selectedIndex == 0
            ? Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/background.png"),
                        fit: BoxFit.cover)),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        child: TextField(
                          autocorrect: false,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                          controller: controller,
                          decoration: InputDecoration(
                            filled: true,
                            icon: const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 20,
                            ),
                            hintText: 'Insert a Youtube URL here',
                            hintStyle: const TextStyle(
                                color: Colors.white, fontSize: 15),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  controller.clear();
                                  FocusScope.of(context).unfocus();
                                },
                                icon: const Icon(Icons.clear),
                                color: Colors.white),
                          ),
                        ),
                      ),
                      Container(
                        child: TextButton(
                            child: const Text(
                              "DOWNLOAD",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                              ),
                            ),
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: const BorderSide(color: Colors.grey),
                                ),
                              ),
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.grey),
                            ),
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              var yt = YoutubeExplode();
                              var id;
                              try {
                                id = VideoId(controller.text);
                              } catch (_) {
                                controller.clear();
                                isDownloading = false;
                                return showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const AlertDialog(
                                        content: Text(
                                            "Requested video doesn't exist"),
                                      );
                                    });
                              }
                              isDownloading = true;
                              setState(() {});
                              var video = await yt.videos.get(id);
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Text(
                                          '\tDownload has started for :\n\tTitle: ${video.title}\n\tDuration: ${video.duration}'),
                                    );
                                  });
                              await Permission.storage.request();
                              var manifest =
                                  await yt.videos.streamsClient.getManifest(id);
                              dynamic streamInfo;
                              if (option == "Video & audio")
                                streamInfo =
                                    manifest.muxed.sortByVideoQuality()[0];
                              else if (option == "Video only")
                                streamInfo =
                                    manifest.videoOnly.sortByVideoQuality()[0];
                              else
                                streamInfo =
                                    manifest.audioOnly.sortByBitrate()[0];
                              Directory dir =
                                  Directory('storage/emulated/0/Download');
                              filePath = path.join(dir.uri.toFilePath(),
                                  '${video.title}.${streamInfo.container.name}');
                              var file = File(filePath);
                              var fileStream = file.openWrite();
                              await yt.videos.streamsClient
                                  .get(streamInfo)
                                  .pipe(fileStream);
                              await fileStream.flush();
                              await fileStream.close();
                              final String auxfilePath = path.join(
                                  'storage/emulated/0/Documents',
                                  '${video.title}.${streamInfo.container.name}');
                              await File(filePath).rename(auxfilePath);
                              await File(auxfilePath).rename(filePath);
                              await f();
                              setState(() {});
                            }),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: RichText(
                          text: TextSpan(
                            text: isDownloading ? "Downloading..." : "",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 30.0),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            : Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        child: TextField(
                            textInputAction: TextInputAction.search,
                            autocorrect: false,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                            controller: controller_search,
                            decoration: InputDecoration(
                              filled: true,
                              icon: const Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 20,
                              ),
                              hintText: 'Search',
                              hintStyle: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    controller_search.clear();
                                    FocusScope.of(context).unfocus();
                                  },
                                  icon: const Icon(Icons.clear),
                                  color: Colors.white),
                            ),
                            onSubmitted: (controllerSearch) async {
                              hasloaded = false;
                              setState(() {});
                              await callApi(controllerSearch);
                              if (noAPIkeys)
                                hasloaded = false;
                              else
                                hasloaded = true;
                              setState(() {});
                            }),
                      ),
                      hasloaded
                          ? Flexible(
                              child: ListView(
                                children:
                                    videoResult.map<Widget>(listItem).toList(),
                              ),
                            )
                          : noAPIkeys
                              ? Container(
                                  padding: const EdgeInsets.only(top: 200.0),
                                  child: Center(
                                    child: RichText(
                                      text: const TextSpan(
                                        text:
                                            "No API Keys available, try later.",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 25.0),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.only(top: 200.0),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.download),
              label: 'Youtube Downloader',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_arrow),
              label: 'Youtube API',
              backgroundColor: Colors.black,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.green,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Future<bool> onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to exit the app?'),
        actions: <Widget>[
          new GestureDetector(
            onTap: () => {
              Navigator.of(context).pop(false),
            },
            child: const Text("No"),
          ),
          const SizedBox(height: 16),
          new GestureDetector(
            onTap: () => {
              exit(1),
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }
}
