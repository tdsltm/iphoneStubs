//
//  ViewController.h
//  VideoCamCaptureExample-RedGlassesBlog
//
//  Created by Tereus Scott on 11-11-13.
// 2011 Little Tiny Machines.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreFoundation/CFData.h>
#import <CoreFoundation/CFSocket.h>
#import <ImageIO/CGImageProperties.h>


@interface ViewController : UIViewController
<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    int iFrameCount;
}

@property(nonatomic, retain) IBOutlet UIView *          vImagePreview;
@property(nonatomic, retain) IBOutlet UIImageView *     vImage;
@property(nonatomic, retain) IBOutlet UILabel *         lFrameCount;

@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;

@end
