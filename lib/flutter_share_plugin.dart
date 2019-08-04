import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// This is the entry class for the plugin.
///
/// This is a utility class, so all the methods here are static only.
/// All the dependencies are passed as the parameters in the.
/// 
/// Author: Harshvardhan Joshi <hj2931996@gmail.com>
class FlutterShare {
  static const MethodChannel _channel =
      const MethodChannel('flutter_share_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// This method will call the respective OS's method implementation through method channel
  /// provided by flutter
  ///
  /// There are all the parameters are kept optional right now, to provide customizaed method
  /// implementations.
  ///
  /// For Sharing text or link [textContent] is content is used, while for sharing a file [fileName] and [bytes]
  /// are used.
  ///
  /// Any of the above parameter can be null at any time.
  /// NOTE: this plugin can only provide functionality upto showing share UI
  /// Anything after Showing the UI is upto the respective OS to handle.
  static Future<bool> share(
      {String textContent = "Remove or Replace with your text",
      String fileName,
      List<int> bytes}) async {
    if (fileName == null) {
      fileName = "";
    }
    if (textContent.isEmpty && fileName.isEmpty) {
      print(
          "FlutterShare: share(textContent, fileName, bytes) method requires at least one Non-empty parameter.");
      return false;
    }

    if (fileName.isNotEmpty && bytes != null && bytes.isNotEmpty) {
      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/$fileName').create();
      await file.writeAsBytes(bytes);
      print("file size: ${await file.length()} bytes");
    }
    final bool success = await _channel.invokeMethod('share', <String, dynamic>{
      'content': textContent,
      'fileName': fileName,
    });
    return success;
  }

  /// Method implementation for sharing file with a [textContent], file is accessed via [filePath] given as
  /// parameter
  ///
  ///Under the hood this method uses
  ///```dart
  ///share(textContent, fileName, bytes);
  ///```
  static Future<bool> shareFileWithText(
      {String textContent, String filePath = ""}) async {
    if (textContent == null) {
      textContent = "";
    }

    String fileName;
    List<int> bytes;
    if (filePath != null && filePath.isNotEmpty) {
      fileName = _getFileNameFromPath(filePath);
      bytes = await _getFileBytes(filePath);
    }

    return share(textContent: textContent, fileName: fileName, bytes: bytes);
  }

  ///Method implementation for sharing only text,
  ///
  ///Under the hood this method uses
  ///```dart
  ///shareFileWithText(textContent, filePath);
  ///```
  ///
  static Future<bool> shareText(String textContent) async {
    return shareFileWithText(textContent: textContent, filePath: null);
  }

  ///Method implementation for sharing only file,
  ///
  ///
  ///
  ///Under the hood this method uses
  ///```dart
  ///shareFileWithText(textContent, filePath);
  ///```
  ///
  static Future<bool> shareFile(String filePath) async {
    return shareFileWithText(textContent: null, filePath: filePath);
  }

  /// This method will get a file using the given [filePaht].
  /// After fetching the files,
  ///   then file will be converted to list of byte
  ///
  /// list of bytes is returnes.
  static Future<List<int>> _getFileBytes(String filePath) async {
    var file = File.fromUri(Uri.parse(filePath));
    var fileBytes = await file.readAsBytes();
    return fileBytes;
  }

  /// This method will get fileName from the given [filePaht].
  /// name of the file is returned.
  static String _getFileNameFromPath(String filePath) {
    int fileNameStartIndex = filePath.lastIndexOf("/") + 1;
    return filePath.substring(fileNameStartIndex, filePath.length);
  }
}
