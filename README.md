# flutter_share_plugin
This plugin helps sharing content like, text, image or a file to other apps.
It supports both Android and iOS, no additional changes are required in native code or projects (Except ofcourse the Storage Access permissions, you'll need to add that in your project manually).

## Getting Started:

### Install plugin:
Visit [Pub Packages page for flutter share plugin](https://pub.dev/packages/flutter_share_plugin#-installing-tab-)

### Import library:
```dart
import 'package:flutter_share_plugin/flutter_share_plugin.dart';
```
That's it. Now, you are ready to go.


## Usage Examples:

### Share only text:
```dart
FlutterShare.shareText("Text to be shared");
```

### Share only file:
```dart
String filePath = "../song.mp3";
FlutterShare.shareFile(filePath);
```

### Share file and text content:
```dart
String filePath = "../screenshot_123.jpg";
FlutterShare.shareFileWithText(textContent: "Screenshot attached", filePath: filePath);
```
