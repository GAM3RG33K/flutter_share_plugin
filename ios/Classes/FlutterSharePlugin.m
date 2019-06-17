#import "FlutterSharePlugin.h"

@implementation FlutterSharePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_share_plugin"
            binaryMessenger:[registrar messenger]];
  FlutterSharePlugin* instance = [[FlutterSharePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"share" isEqualToString:call.method]) {

    NSDictionary *arguments = [call arguments];
    NSString *textContent = arguments[@"content"];
    NSString *fileUrl = arguments[@"fileUrl"];

    if (textContent.length == 0) {
      result([FlutterError errorWithCode:@"error" message:@"FlutterSharePlugin: Non-empty text content expected" details:nil]);
      return;
    }
    NSData *fileData = [NSData dataWithContentsOfFile:fileUrl];
    NSArray *activityItems = [NSArray arrayWithObjects: fileData, nil];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [activityController setValue: title, forKeyPath: "subject"];

    //if iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityController animated:YES completion:nil];
    }
    //if iPad
    else {
        // Change Rect to position Popover
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityController];
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
    result(YES);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
