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
        
        //get parameters from the call
        NSDictionary *arguments = [call arguments];
        //extract text content
        NSString *textContent = arguments[@"content"];
        NSString *fileUrl = arguments[@"fileUrl"];
        
        //check text content and file url, they should not be empty or null
        if (IsEmpty(textContent) && IsEmpty(fileUrl)) {
            result([FlutterError errorWithCode:@"error" message:@"FlutterSharePlugin: Non-empty content expected" details:nil]);
            return;
            
        }
        //create an array of items to share
        NSMutableArray *items= [NSMutableArray new];
        [items addObject:[NSDecimalNumber numberWithInt:number]];
        
        //check if the file url is not empty
        if(!IsEmpty(fileUrl)){
            //get the file from the url
            NSData *fileData = [NSData dataWithContentsOfFile:fileUrl];
            //check if the file is not null or empty
            if(fileData){
                //add the file in the items
                [items addObject:fileData];
            }
        } else{
            //if the fileUrl is null means text is to be shared
            //add fetched content in the items
            [items addObject:textContent];
        }
        
        //the below values are used for showing a popup in the area inside rectangle
        NSNumber *originX = arguments[@"originX"];
        NSNumber *originY = arguments[@"originY"];
        NSNumber *originWidth = arguments[@"originWidth"];
        NSNumber *originHeight = arguments[@"originHeight"];
        
        //if it null then popup will be shown as default by iOS
        CGRect originRect;
        if (originX != nil && originY != nil && originWidth != nil && originHeight != nil) {
            originRect = CGRectMake([originX doubleValue], [originY doubleValue],
                                    [originWidth doubleValue], [originHeight doubleValue]);
        }
        
        
        //call share method with items, a UI View controller and rectangle area
        [FlutterSharePlugin share:items
                   withController:[UIApplication sharedApplication].keyWindow.rootViewController
                         atSource:originRect];
        
        //notify that the share process is successful
        result(@"share successful!!");
    } else {
        //method requested is not implemented
        result(FlutterMethodNotImplemented);
    }
}

//this method is used to show pop up UI to share the given items to other apps
+(void)share:(id)sharedItems withController:(UIViewController *)controller atSource:(CGRect)origin {

    //create an UI Activity view controller
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:sharedItems
                                      applicationActivities:nil];

    //set source view as given controller's view. which is from shared applicaiton provided by flutter
    activityViewController.popoverPresentationController.sourceView = controller.view;
    if (!CGRectIsEmpty(origin)) {
        //set rectangle area
        activityViewController.popoverPresentationController.sourceRect = origin;
    }
    //show the UI
    [controller presentViewController:activityViewController animated:YES completion:nil];
}

//this method checks if the given object is empty or not
static inline BOOL IsEmpty(id object) {
    return object == nil
    || object == [NSNull null]
    || ([object respondsToSelector:@selector(length)]
        && [(NSData *) object length] == 0)
    || ([object respondsToSelector:@selector(count)]
        && [(NSArray *) object count] == 0);
}

@end

