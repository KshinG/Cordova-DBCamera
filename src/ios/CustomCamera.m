#import "Cordova/CDV.h"
#import "DBCameraViewController.h"
#import "DBCameraContainerViewController.h"
#import "DBCameraMacros.h"
#import "CustomCamera.h"
#import "UIImage+TintColor.h"

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)
#define previewFrame (CGRect){ 0, 65, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 138 }


@interface CustomCamera () <DBCameraViewControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) CALayer *focusBox, *exposeBox;
@property (nonatomic, strong) UIView *bottomContainerBar, *topContainerBar;
@end

@implementation CustomCamera

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    //Obtain current device orientation
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    CGFloat newY = CGRectGetMaxY(previewFrame);
    if (orientation == UIInterfaceOrientationPortrait) {
        //[self.sceneText setText:@"Portrait"];

        self.sceneText.transform=CGAffineTransformMakeRotation( DEGREES_TO_RADIANS(0) );
        self.sceneText.center = CGPointMake(previewFrame.size.width/2, newY-40);

    } else if ( orientation == UIInterfaceOrientationLandscapeLeft){
        //[self.sceneText setText:@"Landscape Left"];

        self.sceneText.transform=CGAffineTransformMakeRotation( DEGREES_TO_RADIANS(-90) );
        self.sceneText.center = CGPointMake(previewFrame.size.width-40, previewFrame.size.height/2+80);
    }  else if (orientation == UIInterfaceOrientationLandscapeRight){
       // [self.sceneText setText:@"Landscape Right"];

        self.sceneText.transform=CGAffineTransformMakeRotation( DEGREES_TO_RADIANS(90) );
        self.sceneText.center = CGPointMake(40, previewFrame.size.height/2+80);
    }else if (orientation == UIInterfaceOrientationPortraitUpsideDown){
       // [self.sceneText setText:@"Upside Down"];
        self.sceneText.transform=CGAffineTransformMakeRotation( DEGREES_TO_RADIANS(180) );
        self.sceneText.center = CGPointMake(previewFrame.size.width/2, 100);
    }


    //Do my thing
}

- (void) buildInterface
{
      [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

     [[NSNotificationCenter defaultCenter] addObserver: self selector:   @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    [self addSubview: self.sceneText];

    [self.previewLayer addSublayer:self.focusBox];
    [self.previewLayer addSublayer:self.exposeBox];

    [self addSubview:self.topContainerBar];
    [self addSubview:self.bottomContainerBar];


    [self.topContainerBar addSubview:self.cameraButton];
    [self.topContainerBar addSubview:self.flashButton];

    [self.bottomContainerBar addSubview:self.triggerButton];
    [self.bottomContainerBar addSubview:self.closeButton];
}

#pragma mark - Containers

- (UIView *) topContainerBar
{
    if ( !_topContainerBar ) {
        _topContainerBar = [[UIView alloc] initWithFrame:(CGRect){ 0, 0, CGRectGetWidth(self.bounds), CGRectGetMinY(previewFrame) }];
        [_topContainerBar setBackgroundColor:RGBColor(0x000000, 1)];
    }
    return _topContainerBar;
}

- (UIView *) bottomContainerBar
{
    if ( !_bottomContainerBar ) {
        CGFloat newY = CGRectGetMaxY(previewFrame);
        _bottomContainerBar = [[UIView alloc] initWithFrame:(CGRect){ 0, newY, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - newY }];
        [_bottomContainerBar setUserInteractionEnabled:YES];
        [_bottomContainerBar setBackgroundColor:RGBColor(0x000000, 1)];
    }
    return _bottomContainerBar;
}

- (UILabel *) sceneText
{
    if( !_sceneText) {
        CGFloat newY = CGRectGetMaxY(previewFrame);
        _sceneText = [[UILabel alloc] initWithFrame:CGRectMake(previewFrame.size.width/2-100, newY-80, 200, 80)];
        _sceneText.textAlignment= NSTextAlignmentCenter;
        _sceneText.numberOfLines = 0;
        [_sceneText setBackgroundColor:[UIColor clearColor]];
        [_sceneText setTextColor: [UIColor whiteColor]];
        [_sceneText setShadowColor:[UIColor blackColor]];
        [_sceneText setFont: [UIFont fontWithName:@"Verdana-Bold" size:15.0]];

        }
    return _sceneText;

}





#pragma mark - Focus / Expose Box

- (CALayer *) focusBox
{
    if ( !_focusBox ) {
        _focusBox = [[CALayer alloc] init];
        [_focusBox setCornerRadius:45.0f];
        [_focusBox setBounds:CGRectMake(0.0f, 0.0f, 90, 90)];
        [_focusBox setBorderWidth:5.f];
        [_focusBox setBorderColor:[[UIColor whiteColor] CGColor]];
        [_focusBox setOpacity:0];
    }

    return _focusBox;
}

- (CALayer *) exposeBox
{
    if ( !_exposeBox ) {
        _exposeBox = [[CALayer alloc] init];
        [_exposeBox setCornerRadius:55.0f];
        [_exposeBox setBounds:CGRectMake(0.0f, 0.0f, 110, 110)];
        [_exposeBox setBorderWidth:5.f];
        [_exposeBox setBorderColor:[[UIColor redColor] CGColor]];
        [_exposeBox setOpacity:0];
    }

    return _exposeBox;
}

- (void) drawFocusBoxAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove
{
    [super draw:_focusBox atPointOfInterest:point andRemove:remove];
}

- (void) drawExposeBoxAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove
{
    [super draw:_exposeBox atPointOfInterest:point andRemove:remove];
}
#pragma mark InterfaceOrientationMethods


@end