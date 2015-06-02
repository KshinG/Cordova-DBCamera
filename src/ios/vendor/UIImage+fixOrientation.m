#define previewFrame (CGRect){ 0, 65, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 138 }


@implementation UIImage (fixOrientation)

- (UIImage *)fixOrientation {

    // No-op if the orientation is already correct
    //if (self.imageOrientation == UIImageOrientationUp) return self;

    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.

    NSString* orient;
    size_t width = 0;
    size_t height = 0;
    CGRect cropRect;




//    switch (self.imageOrientation) {
//        case UIImageOrientationDown:
//        case UIImageOrientationDownMirrored:
            //phone top left
//            cropRect = CGRectMake( 130, 0, self.size.width-280, self.size.height);
//            break;

//        case UIImageOrientationLeft:
//        case UIImageOrientationLeftMirrored:
            //phone top down
//            cropRect = CGRectMake( 130, 138, self.size.height-276, self.size.width-260);
//            break;

//        case UIImageOrientationRight:
//        case UIImageOrientationRightMirrored:
            //phone top up
//            cropRect = CGRectMake( 138, 130, self.size.height-276, self.size.width-260);
//            break;
//        case UIImageOrientationUp:
//        case UIImageOrientationUpMirrored:
            //phone top right
//            cropRect = CGRectMake( 138, 0, self.size.width-276, self.size.height);

//            break;
//    }

cropRect = CGRectMake( 0, 0, self.size.width, self.size.height);

    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    UIImage *smallimg = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];

    CGImageRelease(imageRef);


    UIImage *result = smallimg;

    if (result.size.width >= result.size.height){
        orient = @"landscape";
    }
    else{
        orient = @"portrait";
    }


    if (MAX(result.size.width, result.size.height) > 488){
        if ([orient  isEqual: @"landscape"]){
            width = 487;
            height = result.size.height * (487/result.size.width);
        } else {
            height = 487;
            width = result.size.width * (487/result.size.height);
        }
    }

    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (result.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, width, height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;

        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }

    switch (result.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }

    //scale the image
    //transform = CGAffineTransformScale(transform, 396, 396);

    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height,
                                             CGImageGetBitsPerComponent(result.CGImage), 0,
                                             CGImageGetColorSpace(result.CGImage),
                                             CGImageGetBitmapInfo(result.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,height,width), result.CGImage);
            break;

        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,width,height), result.CGImage);
            break;
    }

    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);




    return img;
}

@end