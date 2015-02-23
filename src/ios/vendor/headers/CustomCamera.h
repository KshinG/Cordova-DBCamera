#import "DBCameraDelegate.h"
#import "DBCameraView.h"


@interface CustomCamera : DBCameraView

/**
 *  Create the default interface
 */
- (void) buildInterface;
@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UILabel *sceneText;
@end