import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share_plugin/flutter_share_plugin.dart';

import 'utils/notification_helper.dart';
import 'utils/permission_manager.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String recentFileName = 'None';
  String recentFilePath;
  Uint8List recentFileBytes;
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter file share app demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("recent file: $recentFileName"),
            RaisedButton(
              onPressed: () => chooseFile(),
              child: Text('Choose file'),
            ),
            TextField(
              autofocus: true,
              controller: textController,
            ),
            RaisedButton(
              onPressed: () =>
                  share(textController.text, recentFileName,
                      recentFilePath, recentFileBytes),
              child: Text('Share'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> shareFileUsingPath(String text, String fileName,
      String filePath) async {
    NotificationHelper.showToast(text, false);
    await FlutterShare.shareFileWithText(
        textContent: text, fileName: fileName, filePath: filePath);
  }

  Future<void> shareFileUsingBytes(String text, String fileName,
      Uint8List bytes) async {
    NotificationHelper.showToast(text, false);
    await FlutterShare.shareFileWithText(
        textContent: text, fileName: fileName, bytes: bytes);
  }

  void share(String text, String selectedFileName, String selectedFilePath,
      Uint8List recentFileBytes) {
    if (selectedFilePath == null || selectedFilePath.isEmpty) {
      FlutterShare.shareText(text);
    } else {
      print('\n text: $text');
      print('\n file: $selectedFilePath \n & \n bytes: $recentFileBytes');

//     share it using file path
//    shareFileUsingPath(textData, selectedFileName, selectedFilePath);

      shareFileUsingBytes(text, selectedFileName, recentFileBytes)
          .then((value) {
        NotificationHelper.showToast(text, false);
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textController.dispose();
    super.dispose();
  }

  void chooseFile() {
    var task = () {
      getFileFromChooser().then((filePath) {
        // share it using file path
//        shareFileUsingPath(text, filePath);
        // share it using bytes of the file
        getFileBytes(filePath).then((bytes) async {
          var fileNameFromPath = getFileNameFromPath(filePath);
          setState(() {
            this.recentFileName = fileNameFromPath;
            this.recentFilePath = filePath;
            this.recentFileBytes = bytes;
          });
        });
      });
    };
    PermissionManager.performTaskWithPermission(AppPermission.Storage, task);
  }
}

Future<String> getFileFromChooser() async {
  // Pick a single file directly
  String filePath = await FilePicker.getFilePath(
      type: FileType
          .ANY); // will return a File object directly from the selected file
  return filePath;
}

Future<Uint8List> getFileBytes(String filePath) async {
  var file = File.fromUri(Uri.parse(filePath));
  var fileBytes = await file.readAsBytes();
  return fileBytes;
}

String getFileNameFromPath(String filePath) {
  int fileNameStartIndex = filePath.lastIndexOf("/") + 1;
  return filePath.substring(fileNameStartIndex, filePath.length);
}
