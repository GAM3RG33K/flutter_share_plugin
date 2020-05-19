import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// This is the entry for the plugin.
///
/// It is a utility class, so all the methods here are static only.
///
/// This class performs following utility functions:
///  - [shareText] : allows sharing text content to other apps
///  - [shareFile] : allows sharing any files to other apps
///  - [shareFileWithText] : allows sharing any files with text of choice
///
///
/// Some notes to keep in mind while using these functions:
///  - while sharing text content, make sure that it is not [null] at any given time
///  - you can share file content in two ways:
///     1. by providing the files as bytes([Uint8List] form)
///         - make sure that the bytes are not null and can be used to recreate
///           the file, that file will be created in a temp directory.
///
///     2. by providing the string URI for fetching the file while sharing
///        - make sure that the URI is not empty & allows read access to the file
///        If the URI of the file needs storage access permissions, please add required
///        permission to android and iOS project respectively.
///             - to make this simple, use [file_picker] plugin and provide the
///               path result from the chooser as the URI for file.
///     3. While sharing the file, filePath will be given priority. [bytes] will
///         be used only if the filePath is not provided.
///
///
/// Refer to : https://codinglatte.com/posts/flutter/handling-requesting-for-permissions-like-a-pro-in-flutter/
class FlutterShare {
  static const MethodChannel _channel = MethodChannel('flutter_share_plugin');

  static Future<bool> _share({String message = "", String filePath}) async {
  //    filePath = filePath.absolute.path.replaceAll(" ","_");   // if file contains white spaces then it won't share file
    filePath.split("/").last.replaceAll(" ", "_"); // it will give file name without spaces...
    
    assert(
    message != null && message.isNotEmpty ||
        (filePath != null && filePath.isNotEmpty),
    'FlutterShare: while sharing provide at least one Non-empty parameter, a text or a file .');

    final String response =
    await _channel.invokeMethod<String>('share', <String, dynamic>{
      'message': message,
      'fileUrl': filePath,
    });
    print('Fluttershare: response: $response');
    return true;
  }

  /// Sharing file with a custom text:
  ///
  /// In this method custom text is represented by [textContent]
  /// and
  /// file is represented by:
  ///  - the [filePath] URI string
  ///  - the [bytes] in Uint8List format
  ///
  /// While sharing the file, [filePath] will be given priority. [bytes] will
  /// be used only if the [filePath] is not provided.
  ///
  /// you can use this method as following:
  /// 1.
  /// ```dart
  ///   // use preferred method here to get URI string of the file
  ///   String uri = bohemianRhapsodySong.absolute.path;
  ///
  ///   String text = "Take a look at this...";
  ///   FlutterShare.shareFileWithText(
  ///       textContent: text, filePath: uri);
  /// ```
  ///
  ///
  /// 2.
  /// ```dart
  ///   // use preferred method here to get bytes of the files
  ///   Uint8List bytes = bohemianRhapsodySong.readAsBytes();
  ///
  ///   String text = "Check out this song...";
  ///   FlutterShare.shareFileWithText(
  ///       textContent: text, bytes: bytes);
  /// ```
  ///
  /// *Note*:
  /// Check out the code in second example, file path is not provided, since we
  /// intend to share the file via bytes.
  static Future<bool> shareFileWithText({String textContent,
    String fileName,
    Uint8List bytes,
    String filePath}) async {
    if (textContent == null) {
      textContent = "";
    }

    if ((filePath == null || filePath.isEmpty) &&
        (fileName != null &&
            fileName.isNotEmpty &&
            bytes != null &&
            bytes.isNotEmpty)) {
      final tempDir = await getTemporaryDirectory();
      filePath = '${tempDir.path}/$fileName';
      final file = await File(filePath).create();
      await file.writeAsBytes(bytes);
    }

    assert(filePath != null && filePath.isNotEmpty, 'Could Not find file!!');
    return _share(message: textContent, filePath: filePath);
  }

  /// Sharing a custom text
  ///
  /// Usage Example :
  /// ```dart
  ///   String text = "Check out this plugin:https://pub.dev/packages/flutter_share_plugin ";
  ///   FlutterShare.shareText(text);
  /// ```
  static Future<bool> shareText(String textContent) async {
    bool status = await _share(message: textContent);
    return status;
  }

  /// Sharing a file
  ///
  /// This method allows 2 ways to share a file
  ///
  /// Usage Example :
  ///
  /// Assuming we sharing an in memory file
  ///  in this case `bohemianRhapsodySong`
  /// 1. Using file path
  /// ```dart
  ///   String filePath = bohemianRhapsodySong.absolute.path;
  ///
  ///   // pass the string as `filePath` parameter
  ///   FlutterShare.shareFile(filePath: filePath);
  /// ```
  ///
  /// 2. Using bytes
  /// ```dart
  ///   Uint8List bytes = bohemianRhapsodySong.readAsBytes();
  ///
  ///   // pass the Uint8List data as `bytes` parameter
  ///   FlutterShare.shareFile(bytes: bytes);
  /// ```
  ///
  /// Use of this method is equivalent to:
  /// ```dart
  ///   shareFileWithText(filePath: filePath, bytes: bytes);
  /// ```
  static Future<bool> shareFile({String filePath, Uint8List bytes}) async {
    bool status = await shareFileWithText(filePath: filePath, bytes: bytes);
    return status;
  }
}
