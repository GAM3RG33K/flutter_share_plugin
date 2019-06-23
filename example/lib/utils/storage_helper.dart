import 'package:path_provider/path_provider.dart';

import 'notification_helper.dart';
import 'permission_manager.dart';

/// We can have an entry here repactive to a directory we need.
///  This will help separete the internal code to access any directory,
///  and have a direct way to provide custom directory path
///  to access required directory paths anywhere in the entire app.
enum AppDirectory { AppDownload, Screenshot }

/// This class will contain the utility methods to access the device storage.
///
/// Like, App specific paths, method to get required app specific path based on enum value provided
/// or methods which can access the directories.
///
/// Also, Make sure to add only static methods,
///  so that there is no instance dependency for the utility.
///
/// If required the dependencies can be passed as method parameters, main purpose
///  here is to keep the utility methods accessible to every class without any instance of the
///  utility class.
///
/// Dependencies to be added in pubspec.yaml:
///   path_provider: ^1.1.0
///
/// Author: Harshvardhan Joshi
/// Date: 13-06-2019
///
class StorageHelper {
  /// This method will provide the app specific directory path,
  ///  based on the given type of directory requested with [directory].
  static getDirectory(AppDirectory directory) async {
    //get an instance of the permission manager
    var manager = PermissionManager();

    //get status of Storage permission before accessing the directories
    var status = await manager.hasPermission(AppPermission.Storage);
    if (!status) {
      NotificationHelper.showToast(
          "Storage access permission is denied.", true);
      return null;
    }

    //if permission is already granted then return required directory's absolute path
    switch (directory) {
      //Download directory path
      case AppDirectory.AppDownload:
        var externalPath = (await getExternalStorageDirectory()).path;
        return "$externalPath/Download/";
        break;

      //Path of the directory where the screenshot will be stored
      case AppDirectory.Screenshot:
        var internalPath = (await getApplicationDocumentsDirectory()).path;
        return "$internalPath/screenshots/";
        break;
    }
  }
}
