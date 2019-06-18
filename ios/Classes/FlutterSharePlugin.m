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
      // [self share:call];

      NSDictionary *arguments = [call arguments];
      NSString *textContent = arguments[@"content"];
      
      if (textContent.length == 0) {
          result([FlutterError errorWithCode:@"error" message:@"FlutterSharePlugin: Non-empty text content expected" details:nil]);
          return;
      
      }
      NSArray *items;
      // items = @[textContent];
      
      NSString *fileUrl = arguments[@"fileUrl"];
      NSData *fileData = [NSData dataWithContentsOfFile:fileUrl];
      if(fileData){
        items = @[fileData];
      }else {
        items = @[textContent];
      }

      NSNumber *originX = arguments[@"originX"];
      NSNumber *originY = arguments[@"originY"];
      NSNumber *originWidth = arguments[@"originWidth"];
      NSNumber *originHeight = arguments[@"originHeight"];

      CGRect originRect;
      if (originX != nil && originY != nil && originWidth != nil && originHeight != nil) {
        originRect = CGRectMake([originX doubleValue], [originY doubleValue], 
                                  [originWidth doubleValue], [originHeight doubleValue]);
      }


      [self share:items
          withController:[UIApplication sharedApplication].keyWindow.rootViewController
          atSource:originRect];
          
      result(@"share successful!!");
  } else {
    result(FlutterMethodNotImplemented);
  }
}

+ (void)share:(id)sharedItems
    withController:(UIViewController *)controller
          atSource:(CGRect)origin {
  UIActivityViewController *activityViewController =
      [[UIActivityViewController alloc] initWithActivityItems:sharedItems
                                        applicationActivities:nil];
  activityViewController.popoverPresentationController.sourceView = controller.view;
  if (!CGRectIsEmpty(origin)) {
    activityViewController.popoverPresentationController.sourceRect = origin;
  }
  [controller presentViewController:activityViewController animated:YES completion:nil];
}

@end

