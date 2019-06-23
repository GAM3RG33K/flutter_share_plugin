import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class FlutterShare {
  static const MethodChannel _channel =
      const MethodChannel('flutter_share_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// This method will call the respective OS's method implementation throigh method channel
  /// provided by flutter
  ///
  /// NOTE: this plugin can only provide functionality upto showing share UI
  /// Anything after Showing the UI is upto the respective OS to handle.
  static Future<bool> share(
      {String textContent, String fileName, List<int> bytes}) async {
    if (textContent.isEmpty && fileName.isEmpty) {
      print(
          "FlutterShare: share(textContent, fileUrl) method requires at least one Non-empty parameter.");
      return false;
    }

    if (fileName.isNotEmpty) {
      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/$fileName').create();
      await file.writeAsBytes(bytes);
      print("file size: ${ await file.length()} bytes");
    }
    final bool success = await _channel.invokeMethod('share', <String, dynamic>{
      'content': textContent,
      'fileName': fileName,
    });
    return success;
  }
}
