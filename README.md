# flutter_share_plugin
This plugin helps sharing content like, text, image or a file to other apps.
It supports both Android and iOS, no additional changes are required in native code or projects.

Just install this plugin and use it as required.

## Installation:
Plugin is not published yet
  

## Usage Examples:

### Share only text:
```dart
FlutterShare.share(textContent: "Text to be shared");
```

### Share only file:
```dart
String fileName = "abc.txt"; //or abc.png or abc.mp3 or abc.xml, all files are supported 

//use your own file here, this is just for example
File file = File($fileName);
//read file as bytes
var bytes = await file.readAsBytes();
FlutterShare.share(fileName: fileName, bytes: bytes);
```


### Share file and text content: (text will be used only in case shared with email or chat app and will be set as body text )
```dart
String fileName = "screenshot_123.jpg";
//use your own file here, this is just for example
File screenshot = File($fileName);
//read file as bytes
var bytes = await screenshot.readAsBytes();
FlutterShare.share(textContent: "Screenshot attached", fileName: fileName, bytes: bytes);
```
