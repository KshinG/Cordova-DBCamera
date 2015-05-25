/********* CDVdbcamera.m Cordova Plugin Implementation *******/

#import "Cordova/CDV.h"
#import "DBCameraViewController.h"
#import "DBCameraContainerViewController.h"
#import "DBCameraView.h"
#import "UIImage+CropScaleOrientation.h"
#import "UIImage+fixOrientation.m"

// Uncomment custom camera related to start implementing your own
#import "CustomCamera.h"

#define CDV_DBCAMERA_PHOTO_PREFIX @"cdv_dbcamera_photo_"

@interface CDVdbcamera : CDVPlugin <DBCameraViewControllerDelegate, UINavigationControllerDelegate>{}

@property (copy) NSString* callbackId;

- (void)openCamera:(CDVInvokedUrlCommand*)command;
- (void)openCameraWithSettings:(CDVInvokedUrlCommand*)command;
- (void)openCustomCamera:(CDVInvokedUrlCommand*)command;
- (void)openCameraWithoutSegue:(CDVInvokedUrlCommand*)command;
- (void)openCameraWithoutContainer:(CDVInvokedUrlCommand*)command;
- (void)cleanup:(CDVInvokedUrlCommand*)command;
- (NSURL*) urlTransformer:(NSURL*)url;
@end

@implementation CDVdbcamera

- (void)openCamera:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    DBCameraContainerViewController *cameraContainer = [[DBCameraContainerViewController alloc] initWithDelegate:self];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cameraContainer];
    nav.delegate = self;
    [nav setNavigationBarHidden:YES];
    [self.viewController presentViewController:nav animated:YES completion:nil];
}

- (void)openCameraWithSettings:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    DBCameraContainerViewController *cameraContainer = [[DBCameraContainerViewController alloc] initWithDelegate:self cameraSettingsBlock:^(DBCameraView *cameraView, DBCameraContainerViewController *container) {
        [cameraView.gridButton setHidden:YES];
    }];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cameraContainer];
    nav.delegate = self;
    [nav setNavigationBarHidden:YES];
    [self.viewController presentViewController:nav animated:YES completion:nil];
}

- (void)openCustomCamera:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;

    CustomCamera *camera = [CustomCamera initWithFrame:[[UIScreen mainScreen] bounds]];

    camera.sceneText.text = [[command argumentAtIndex:0 withDefault:@"No Text"] uppercaseString];
    [camera buildInterface];
    BOOL cameraDirection = [[command argumentAtIndex:3 withDefault:@(NO)] boolValue];

    self.callbackId = command.callbackId;

    DBCameraViewController *cameraController = [DBCameraViewController initWithDelegate:self];


    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[cameraController initWithDelegate:self cameraView:camera]];
    [cameraController setUseCameraSegue:NO];

    nav.delegate = self;

    [nav setNavigationBarHidden:YES];
    [self.viewController presentViewController:nav animated:YES completion:^(){
        [camera.delegate triggerFlashForMode:AVCaptureFlashModeAuto];
        if (cameraDirection == true){
          [camera.delegate switchCamera];
        }
    }];

}

- (void)openCameraWithoutSegue:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    DBCameraContainerViewController *container = [[DBCameraContainerViewController alloc] initWithDelegate:self];
    DBCameraViewController *cameraController = [DBCameraViewController initWithDelegate:self];
    [cameraController setUseCameraSegue:NO];
    [container setCameraViewController:cameraController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:container];
    nav.delegate = self;
    [nav setNavigationBarHidden:YES];
    [self.viewController presentViewController:nav animated:YES completion:nil];
}

- (void)openCameraWithoutContainer:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[DBCameraViewController initWithDelegate:self]];
    nav.delegate = self;
    [nav setNavigationBarHidden:YES];
    [self.viewController presentViewController:nav animated:YES completion:nil];
}

- (void)cleanup:(CDVInvokedUrlCommand*)command
{
    // empty the tmp directory
    NSFileManager* fileMgr = [[NSFileManager alloc] init];
    NSError* err = nil;
    BOOL hasErrors = NO;

    // clear contents of NSTemporaryDirectory
    NSString* tempDirectoryPath = NSTemporaryDirectory();
    NSDirectoryEnumerator* directoryEnumerator = [fileMgr enumeratorAtPath:tempDirectoryPath];
    NSString* fileName = nil;
    BOOL result;

    while ((fileName = [directoryEnumerator nextObject])) {
        // only delete the files we created
        if (![fileName hasPrefix:CDV_DBCAMERA_PHOTO_PREFIX]) {
            continue;
        }
        NSString* filePath = [tempDirectoryPath stringByAppendingPathComponent:fileName];
        result = [fileMgr removeItemAtPath:filePath error:&err];
        if (!result && err) {
            NSLog(@"Failed to delete: %@ (error: %@)", filePath, err);
            hasErrors = YES;
        }
    }

    CDVPluginResult* pluginResult;
    if (hasErrors) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:@"One or more files failed to be deleted."];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - DBCameraViewControllerDelegate


- (NSURL*) urlTransformer:(NSURL*)url
{
    NSURL* urlToTransform = url;

    // for backwards compatibility - we check if this property is there
    SEL sel = NSSelectorFromString(@"urlTransformer");
    if ([self.commandDelegate respondsToSelector:sel]) {
        // grab the block from the commandDelegate
        NSURL* (^urlTransformer)(NSURL*) = ((id(*)(id, SEL))objc_msgSend)(self.commandDelegate, sel);
        // if block is not null, we call it
        if (urlTransformer) {
            urlToTransform = urlTransformer(url);
        }
    }

    return urlToTransform;
}

- (void) captureImageDidFinish:(UIImage *)image withMetadata:(NSDictionary *)metadata
{

    CGSize targetSize;
    NSString* orient;

    if (image.size.width >= image.size.height){
        orient = @"landscape";
    }
    else{
        orient = @"portrait";
    }

    if (MAX(image.size.width, image.size.height) > 398){
        if ([orient  isEqual: @"landscape"]){
            targetSize.width = 396;
            targetSize.height = image.size.height * (396/image.size.width);
        } else {
            targetSize.height = 396;
            targetSize.width = image.size.width * (396/image.size.height);
        }
    }






    image = [image fixOrientation];
   // UIImage* scaledImage = nil;
   // scaledImage = [image imageByScalingNotCroppingForSize:targetSize];

    NSData* data = UIImagePNGRepresentation(image);
    NSString* docsPath = [NSTemporaryDirectory()stringByStandardizingPath];
    NSError* err = nil;
    NSFileManager* fileMgr = [[NSFileManager alloc] init];
    NSString* filePath;

    int i = 1;
    do {
        filePath = [NSString stringWithFormat:@"%@/%@%03d.%@", docsPath, CDV_DBCAMERA_PHOTO_PREFIX, i++, @"png"];
    } while ([fileMgr fileExistsAtPath:filePath]);

    CDVPluginResult* pluginResult = nil;

    if (![data writeToFile:filePath options:NSAtomicWrite error:&err]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[self urlTransformer:[NSURL fileURLWithPath:filePath]] absoluteString]];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) dismissCamera
{
    NSMutableDictionary* resultDictionary = [[NSMutableDictionary alloc] init];
    [resultDictionary setValue:@"" forKey:@"imageURL"];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDictionary];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UINavigationControllerDelegate

- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController;
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
