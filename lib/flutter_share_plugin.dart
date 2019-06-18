import 'dart:async';

import 'package:flutter/services.dart';

class FlutterSharePlugin {
  static const MethodChannel _channel =
  const MethodChannel('flutter_share_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> share(String textContent, {String fileUrl}) async {
    print("calling the share method");
    final bool success = await _channel.invokeMethod('share', <String, dynamic>{
      'content': textContent,
      'fileUrl': fileUrl,
    });

    return success;
  }
}
