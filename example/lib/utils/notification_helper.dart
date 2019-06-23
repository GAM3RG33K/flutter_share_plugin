import 'package:fluttertoast/fluttertoast.dart';

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
/// Dependencies to be added in pubspec.yaml:
///   fluttertoast: ^3.1.0
///
/// Author: Harshvardhan Joshi
/// Date: 13-06-2019
///
class NotificationHelper {
  /// This method will show/raise a toast with given [message]
  ///  and the toast length will be decided based on the [isLongToast] boolean flag.
  ///
  /// Optional parameters:
  ///   - [gravity]: (package: fluttertoast)ToastGravity : where toast will be displayed
  ///   - [timeInSec]: Int : toast length for iOS devices in seconds
  ///   - [backgroundColor]: Color : color to be set as toast's background color
  ///   - [textColor] : Color : color to be set as toast's text color
  ///   - [fontSize] : double : font size of the toast's text
  ///
  static showToast(message, isLongToast,
      {gravity, timeInSecIos, backgroundColor, textColor, fontSize}) {
    //show a toast with given message and customizations
    Fluttertoast.showToast(
        msg: message,
        toastLength: isLongToast ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
        gravity: gravity,
        timeInSecForIos: timeInSecIos,
        backgroundColor: backgroundColor,
        textColor: textColor,
        fontSize: fontSize);
  }
}
