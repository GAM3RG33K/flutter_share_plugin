# flutter_share_plugin
[![pub package](https://img.shields.io/pub/v/flutter_share_plugin.svg)](https://pub.dev/packages/flutter_share_plugin)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)


Easily share content like text, image or any file to other apps.

Both Android and iOS platforms are supported, no additional changes are required in native code or projects.
*Except, the **Specific permissions** (like Storage Access permission), you'll need to add that in your project manually.*


### Install plugin:
Visit https://pub.dev/packages/flutter_share_plugin#-installing-tab-

### Import library:
```dart
import 'package:flutter_share_plugin/flutter_share_plugin.dart';
```

That's it. Now, you are ready to go.


## Usage Examples:

### Share only text:
```dart
String text = "Check out this plugin: https://pub.dev/packages/flutter_share_plugin ";
FlutterShare.shareText(text);
```


### Share only file:

#### Example 1:
```dart
String filePath = bohemianRhapsodySong.absolute.path;

// pass the string as `filePath` parameter
FlutterShare.shareFile(filePath: filePath);
```

#### Example 2:
```dart
Uint8List bytes = bohemianRhapsodySong.readAsBytes();

// pass the Uint8List data as `bytes` parameter
FlutterShare.shareFile(bytes: bytes);
```


### Share file and text content:

#### Example 1:
```dart
// use preferred method here to get URI string of the file
String uri = screenshot.absolute.path;
String text = "Transaction Screenshot";

FlutterShare.shareFileWithText(
    textContent: text, filePath: uri);
```

#### Example 2:
```dart
// use preferred method here to get bytes of the files
Uint8List bytes = screenshot.readAsBytes();
String text = "Transaction Screenshot";

FlutterShare.shareFileWithText(
    textContent: text, bytes: bytes);
```


## Screenshots:

### Share text only
![](/images/share_text_1.jpg?raw=true "share text 1")
![](/images/share_text_2.jpg?raw=true "share text 2")


### Share a file with text
![](/images/share_file_with_text_1.jpg?raw=true "share file with text 1")
![](/images/share_file_with_text_2.jpg?raw=true "share file with text 2")
![](/images/share_file_with_text_3.jpg?raw=true "share file with text 3")

