//
//  MyRecorderController.m
//  MyRecorder
//
//  Created by Arb on 5/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyRecorderController.h"


@implementation MyRecorderController

- (void)awakeFromNib {
	//Create the capture session
	mCaptureSession = [[QTCaptureSession alloc] init];
	
	//Connect inputs and outputs to the session.
	BOOL success = NO;
	NSError *error;
	
	NSArray * devices = [QTCaptureDevice inputDevices];
	for (QTCaptureDevice * c in devices) {
		NSLog(@"Found %@", [c localizedDisplayName]);
	}
	
	//Find the device and create the device input. Then add it to the session.	
	QTCaptureDevice *device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
	if (device) {
		success = [device open:&error];
		if (!success) {
		}
		mCaptureDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:device];
		success = [mCaptureSession addInput:mCaptureDeviceInput error:&error];
		if (!success) {
			// Handle error
		}
		
		// Create the movie file output and add it to the session.
    mCaptureMovieFileOutput = [[QTCaptureMovieFileOutput alloc] init];
    success = [mCaptureSession addOutput:mCaptureMovieFileOutput error:&error];
    if (!success) {
    }
    [mCaptureMovieFileOutput setDelegate:self];
		
		//Specify the compression options with an identifier with a size for video and a quality for audio.
		NSEnumerator *connectionEnumerator = [[mCaptureMovieFileOutput connections] objectEnumerator];
		QTCaptureConnection *connection;
		while ((connection = [connectionEnumerator nextObject])) {
			NSString *mediaType = [connection mediaType];
			QTCompressionOptions *compressionOptions = nil;
			if ([mediaType isEqualToString:QTMediaTypeVideo]) {
				compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptions240SizeH264Video"];
			} else if ([mediaType isEqualToString:QTMediaTypeSound]) {				
				compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptionsHighQualityAACAudio"];
			}			
			[mCaptureMovieFileOutput setCompressionOptions:compressionOptions forConnection:connection];
			// Associate the capture view in the user interface with the session.
			[mCaptureView setCaptureSession:mCaptureSession];
    }
		//Start the capture session running.
    [mCaptureSession startRunning];
	}
}

//Handle the closing of the window and notify for your input device, and then stop the capture session.
- (void)windowWillClose:(NSNotification *)notification {
	[mCaptureSession stopRunning];
	[[mCaptureDeviceInput device] close];	
}
	
- (void)dealloc {
	[mCaptureSession release];
	[mCaptureDeviceInput release];
	[mCaptureMovieFileOutput release];
	[super dealloc];
}

- (IBAction)startRecording:(id)sender{
	NSLog(@"%@", @"Recording");
	[mCaptureMovieFileOutput recordToOutputFileURL:[NSURL fileURLWithPath:@"/Users/Shared/MyRecordedMovie.mov"]];
}

- (IBAction)stopRecording:(id)sender{
	NSLog(@"%@", @"Stopping");
	[mCaptureMovieFileOutput recordToOutputFileURL:nil];
}

//Finish recording and then launch your recording as a QuickTime movie on your Desktop.
- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error {	
	[[NSWorkspace sharedWorkspace] openURL:outputFileURL];
	NSLog(@"%@", @"Recording Finished.");	
}

@end
