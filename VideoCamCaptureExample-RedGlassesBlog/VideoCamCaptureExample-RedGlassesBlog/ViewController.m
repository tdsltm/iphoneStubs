//
//  ViewController.m
//  VideoCamCaptureExample-RedGlassesBlog
//
//  Created by Tereus Scott on 11-11-13.
//  2011 Little Tiny Machines. 
//
//  This project incorporates and extends example code from: 
//  http://blog.red-glasses.com/index.php/tutorials/ios4-take-photos-with-live-video-preview-using-avfoundation/
//  
//  This sample shows how to set up a capture session to grab video frames along with still image snapshots.
//  This demonstrates using a capture session with multiple outputs.
//  A delegate callback is called each time a frame is ready. This example simply updates a frame counter
//  in the main view.
//  You need to add additional code if you wish to do something with the video frames as they are coming in.

#import "ViewController.h"

@implementation ViewController

@synthesize vImagePreview;
@synthesize vImage;
@synthesize stillImageOutput;
@synthesize lFrameCount;

/////////////////////////////////////////////////////////////////////
#pragma mark - UI Actions
/////////////////////////////////////////////////////////////////////
-(IBAction) captureNow
{
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in stillImageOutput.connections)
	{
		for (AVCaptureInputPort *port in [connection inputPorts])
		{
			if ([[port mediaType] isEqual:AVMediaTypeVideo] )
			{
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) { break; }
	}
 
	NSLog(@"about to request a capture from: %@", stillImageOutput);
	[stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
	{
		 CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
		 if (exifAttachments)
		 {
			// Do something with the attachments.
			NSLog(@"attachements: %@", exifAttachments);
		 }
		else
			NSLog(@"no attachments");
 
		NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
		UIImage *image = [[UIImage alloc] initWithData:imageData];
 
		self.vImage.image = image;
	 }];
}



/////////////////////////////////////////////////////////////////////
#pragma mark - Video Frame Delegate
/////////////////////////////////////////////////////////////////////
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
	   fromConnection:(AVCaptureConnection *)connection 
{ 
    //NSLog(@"got frame");
    
    iFrameCount++;
    
    // Update Display
    NSString * frameCountString = [[NSString alloc] initWithFormat:@"%4.4d", iFrameCount];
    [lFrameCount performSelectorOnMainThread: @selector(setText:) withObject:frameCountString waitUntilDone:YES];
    
    NSLog(@"frame count %d", iFrameCount);
}




/////////////////////////////////////////////////////////////////////
#pragma mark - Guts
/////////////////////////////////////////////////////////////////////

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}



/////////////////////////////////////////////////////////////////////
#pragma mark - View lifecycle
/////////////////////////////////////////////////////////////////////

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    /////////////////////////////////////////////////////////////////////////////
    // Create a preview layer that has a capture session attached to it.
    // Stick this preview layer into our UIView.
    /////////////////////////////////////////////////////////////////////////////
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
	session.sessionPreset = AVCaptureSessionPresetMedium;
 
	CALayer *viewLayer = self.vImagePreview.layer;
	NSLog(@"viewLayer = %@", viewLayer);
 
	AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
 
	captureVideoPreviewLayer.frame = self.vImagePreview.bounds;
	[self.vImagePreview.layer addSublayer:captureVideoPreviewLayer];
 
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
 
	NSError *error = nil;
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	if (!input) {
		// Handle the error appropriately.
		NSLog(@"ERROR: trying to open camera: %@", error);
	}
	[session addInput:input];
 
    
    /////////////////////////////////////////////////////////////
    // OUTPUT #1: Still Image
    /////////////////////////////////////////////////////////////
    // Add an output object to our session so we can get a still image
	// We retain a handle to the still image output and use this when we capture an image.
	stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
	NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
	[stillImageOutput setOutputSettings:outputSettings];
	[session addOutput:stillImageOutput];
    
    
    /////////////////////////////////////////////////////////////
    // OUTPUT #2: Video Frames
    /////////////////////////////////////////////////////////////
    // Create Video Frame Outlet that will send each frame to our delegate
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
	captureOutput.alwaysDiscardsLateVideoFrames = YES; 
	//captureOutput.minFrameDuration = CMTimeMake(1, 3); // deprecated in IOS5
	
	// We need to create a queue to funnel the frames to our delegate
	dispatch_queue_t queue;
	queue = dispatch_queue_create("cameraQueue", NULL);
	[captureOutput setSampleBufferDelegate:self queue:queue];
	dispatch_release(queue);
	
	// Set the video output to store frame in BGRA (It is supposed to be faster)
	NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey; 
	// let's try some different keys, 
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]; 
	
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key]; 
	[captureOutput setVideoSettings:videoSettings];    
    
    [session addOutput:captureOutput]; 
    /////////////////////////////////////////////////////////////
    

	// start the capture session
	[session startRunning];

    /////////////////////////////////////////////////////////////////////////////

    // initialize frame counter
    iFrameCount = 0;
	
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
