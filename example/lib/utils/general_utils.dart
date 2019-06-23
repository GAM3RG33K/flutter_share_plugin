import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_share_plugin/flutter_share_plugin.dart';

import 'drawing_utils.dart';
import 'permission_manager.dart';
import 'storage_helper.dart';

/// This class will contain the most general utility methods,
/// which can be used across the entire app.
///
/// For example, Take screenshot of the widget or any other feature whic can be used
///  in any page of the app.
///
/// For developers:
///   Make sure to add only static methods,
///   so that there is no instance dependency for the utility.
///
/// If required the dependencies can be passed as method parameters, main purpose
///  here is to keep the utility methods accessible to every class without any instance of the
///  utility class.
///
/// Dependencies:
///   PermissionManager and StorageManager utility classes for this app
///
/// Author: Harshvardhan Joshi
/// Date: 13-06-2019
///
class GeneralUtils {
  /// This method will take screenshot
  ///
  /// Requirement of this method is a Global key named [globalWidgetKey],
  ///  which is assigned to a single widget and is unique thorugh out the app
  ///
  /// The screenshot file will be stored in the Download folder as of now. Which is
  ///  denoted by [AppDirectory.AppDownload] here.
  ///  We can change it to other directories as well, e.g. [AppDirectory.Screenshot]
  ///
  ///
  /// Note: Image quality of the screenshot is by default SD(Standard lossy quality).
  ///   No other quality tweaks are found yet.
  ///
  static takeScreenshot(globalWidgetKey) async {
    /// Create a task which runs after a second, so that no animations are running
    ///
    /// This is just temp. solution. If possible find a stable solution so that in screenshot
    ///  no running animations captured. E.g. Ripple/Inkwell from button click.
    var task = () {
      //delay task by 1 second
      Future.delayed(Duration(seconds: 1), () async {
        //get Image data from the widget screen
        RenderRepaintBoundary boundary =
            globalWidgetKey.currentContext.findRenderObject();
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        //add watermark text in the screenshot
        image = await DrawingUtils.drawWaterMark(image);
        //extract byte data to write it in a file
        ByteData byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData.buffer.asUint8List();

        //get timestamp to make sure that every screenshot file is unique
        var timeStamp = DateTime.now().millisecondsSinceEpoch;

        //for test  use download folder
        final directory =
            await StorageHelper.getDirectory(AppDirectory.AppDownload);
        // final directory = await StorageHelper.getDirectory(AppDirectory.Screenshot);

        //create screenshot file name uysnig timestamp value
        String fileName = "screenshot_$timeStamp.png";
        share("screenshot at : ${DateTime.now()}",
            fileName: fileName, bytes: pngBytes);
      });
    };

    //This will perform the above task only if the required permission is granted,
    // otherwise it will ask for permission
    await PermissionManager.performTaskWithPermission(
        AppPermission.Storage, task);
  }

  static void share(String textContent, {String fileName, List<int> bytes}) {
    FlutterShare.share(
        textContent: textContent, fileName: fileName, bytes: bytes);
  }
}
