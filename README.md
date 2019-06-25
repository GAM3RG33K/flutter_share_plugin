# flutter_share_plugin
This plugin helps sharing content like, text, image or a file to other apps.
It supports both Android and iOS, no additional changes are required in native code or projects (Except ofcourse the Storage Access permissions).

Just install this plugin and use it as required.

## Installation:
add following line in your project's pubspec.yaml file
```dart
flutter_share_plugin: ^0.0.1
```
  

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

### Share file and text content: (text will be used only in case shared with email or chat app and will be set as body text )
```dart
String filePath = "../screenshot_123.jpg";
FlutterShare.shareFileWithText(textContent: "Screenshot attached", filePath: filePath);
```
