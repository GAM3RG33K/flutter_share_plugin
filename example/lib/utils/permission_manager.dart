import 'package:permission_handler/permission_handler.dart';

import 'notification_helper.dart';

//Do not forget to as the required permissions in the Android Manifest file
enum AppPermission {
  ///Permission to add in Android Manifest
  ///
  ///<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
  ///<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
  Storage,

  ///Permission to add in Android Manifest
  ///
  ///<uses-permission android:name="android.permission.READ_CONTACTS"/>
  Contacts,

  ///Permission to add in Android Manifest
  ///
  ///<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
  Phone,

  ///Permission to add in Android Manifest
  ///
  ///<uses-permission android:name="android.permission.CAMERA"/>
  Camera,

  ///Permission to add in Android Manifest
  ///
  ///<uses-permission android:name="android.permission.READ_SMS"/>
  SMS
}

/// This class will contain the utility methods to notify a user,
/// it can be a toast or a notification outside of the app (on status bar).
///
/// Also, Make sure to add only static methods,
///  so that there is no instance dependency for the utility.
///
/// If required the dependencies can be passed as method parameters, main purpose
///  here is to keep the utility methods accessible to every class without any instance of the
///  utility class.
///
/// Note: This is a singleton class for now, we can convert it to utility class
///  just like other utility classes if there is no app specific requirement in future.
///
/// Dependencies to be added in pubspec.yaml:
///   permission_handler: ^3.1.0
///
/// Author: Harshvardhan Joshi
/// Date: 13-06-2019
///
class PermissionManager {
  static final PermissionManager _instance = new PermissionManager._internal();
  static final _permissionHandler = PermissionHandler();

  factory PermissionManager() {
    return _instance;
  }

  PermissionManager._internal();

  /// This method is used to check the app permission
  ///   based on [permissionEnum] which is of AppPermission type.
  Future<bool> hasPermission(permissionEnum) async {
    //get Permission Group from the AppPermission value
    PermissionGroup permission = getPermissionGroupFromEnum(permissionEnum);

    //get the permission status
    // this value will return true only if the permission is granted, otherwise false.
    var status = await _permissionHandler
        .checkPermissionStatus(permission)
        .then((permission) {
      return permission.value == PermissionStatus.granted.value;
    });

    return status;
  }

  /// This method will request a single permission requested by [permissionEnum]
  /// parameter
  requestPermission(AppPermission permissionEnum) async {
    //get Permission Group from the AppPermission value
    PermissionGroup permission = getPermissionGroupFromEnum(permissionEnum);

    //create a list of single permission
    var permissionList = [permission];
    //request the permission
    await _requestMultiplePermissions(permissionList);
  }

  /// This method will request mulitple permissions mentioned in the
  /// [permissionsEnum] list
  ///
  requestPermissions(List<AppPermission> permissionsEnum) async {
    //get a list of PermissionGroup from the enum values in the list
    var permissionList = permissionsEnum.map<PermissionGroup>((enumValue) {
      return getPermissionGroupFromEnum(enumValue);
    }).toList();

    //request permissions with the above collected list of permissions.
    await _requestMultiplePermissions(permissionList);
  }

  /// This method is used request permissions form the platform.
  /// Also, this method is the base method of any publically accessible methods of this class
  _requestMultiplePermissions(List<PermissionGroup> permissionList) async {
    try {
      //This map holds both Group of permission and it's status for this app
      Map<PermissionGroup, PermissionStatus> permissions =
          await _permissionHandler
              .requestPermissions(permissionList)
              .catchError((error) {
        print("exception while requesting permission: $error");
      });

      //we iterate on each permission if we need to do any specific operation once after the permission is
      // status changes.
      int grantedCount = 0;
      permissions.forEach((group, status) async {
        //for e.g.
        if (status.value == PermissionStatus.granted.value) {
          //Do something
          grantedCount++;
        }
      });

      if (grantedCount == permissionList.length) {
        NotificationHelper.showToast("All permissions granted!", true);
      } else {
        NotificationHelper.showToast(
            "Only $grantedCount are granted from ${permissionList.length}!",
            true);
      }
    } catch (ex) {
      print("exception while processing requested permissions: $ex");
    }
  }

  /// This method is a utility method which will excute given [task] after checking the
  /// given [permission].
  ///
  /// If the permission is not granted then this method will ask for the permission,
  ///  but will not execute the tsak afterwards.
  /// This is done to make sure that the tasks executes only after the permission status is found granted everytime.
  ///
  /// In case a user removes granted permissions manually.
  ///
  /// This approch can be improved or modified based on the requirement of the app or feature.
  ///
  static performTaskWithPermission(
      AppPermission permission, Function task) async {
    var manager = PermissionManager();
    var status = await manager.hasPermission(permission);
    if (!status) {
      NotificationHelper.showToast(
          "Please grant storage permission and try again!!", true);
      await manager.requestPermission(permission);
    } else {
      NotificationHelper.showToast("Success", true);
      task();
    }
  }
}

/// This method is used to map the app specific [permissionEnum] to
/// library specific [PermissionGroup].
///
/// This is done to separate the PermissionGroup dependency from the app, in case future updates
/// of this library changes/modifies any of the PermissionGroups.
getPermissionGroupFromEnum(AppPermission permissionEnum) {
  switch (permissionEnum) {
    case AppPermission.Storage:
      return PermissionGroup.storage;
      break;
    case AppPermission.Contacts:
      return PermissionGroup.contacts;
      break;
    case AppPermission.Phone:
      return PermissionGroup.phone;
      break;
    case AppPermission.Camera:
      return PermissionGroup.camera;
      break;
    case AppPermission.SMS:
      return PermissionGroup.sms;
      break;
  }
}
