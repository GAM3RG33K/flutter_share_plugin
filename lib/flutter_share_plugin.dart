import 'dart:async';

import 'package:flutter/services.dart';

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
  static Future<bool> share({String textContent, String fileUrl}) async {
    if (textContent.isEmpty && fileUrl.isEmpty) {
      print(
          "FlutterShare: share(textContent, fileUrl) method requires at least one Non-empty parameter.");
      return false;
    }
    final bool success = await _channel.invokeMethod('share', <String, dynamic>{
      'content': textContent,
      'fileUrl': fileUrl,
    });
    return success;
  }
}
