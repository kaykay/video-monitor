//
//  MyRecorderController.m
//  MyRecorder
//
//  Created by Arb on 5/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyRecorderController.h"

//NSString * fileName = @"/Users/Shared/stream.mov";


@implementation MyRecorderController
@synthesize timer = _timer;

- (void)awakeFromNib {
	/*
	// Create the output file first if necessary	
	NSError *err;
	[[NSFileManager defaultManager] removeItemAtPath:fileName error:&err];
	[[NSFileManager defaultManager] createFileAtPath:fileName contents: nil attributes: nil];
	self.oStream = [NSOutputStream outputStreamToFileAtPath:fileName append:NO];
	//[self.oStream setDelegate:self];
	[self.oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.oStream open];
	
	// Now open outfile for writing
	//outFile = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
	//if (outFile == nil) {
	//	NSLog (@"Open of %@ for writing failed\n", fileName);
	//}
	 */

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
		//[mCaptureMovieFileOutput setMaximumRecordedFileSize:100000];
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

-(NSString *) setNextFileName {
	static int count = 0;
	NSString *f = [NSString stringWithFormat:@"/Users/Shared/MyMovie-%d.mov", count++];
	return f;
}


-(void) startTimer {
	self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(recordToNextFile:) userInfo:nil repeats:YES];
}

-(void) stopTimer {
	[self.timer invalidate];
	self.timer = nil;
}

- (IBAction)recordToNextFile:(id)sender{
	NSString *fName = [self setNextFileName];
	[mCaptureMovieFileOutput recordToOutputFileURL:[NSURL fileURLWithPath:fName]];
	NSLog(@"Starting recording to %@", fName); 
}


- (IBAction)startRecording:(id)sender{
	NSLog(@"%@", @"Recording");
	[mCaptureMovieFileOutput recordToOutputFileURL:[NSURL fileURLWithPath:[self setNextFileName]]];
	[self startTimer];
}
- (IBAction)stopRecording:(id)sender{
	[self stopTimer];
	NSLog(@"%@", @"Stopping");
	[mCaptureMovieFileOutput recordToOutputFileURL:nil];
}
	 
	 
/*
- (BOOL)captureOutput:(QTCaptureFileOutput *)captureOutput shouldChangeOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error {
	[self setNextFileName];
	return NO;
}
*/


//Finish recording and then launch your recording as a QuickTime movie on your Desktop.
- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error {	
	//[outFile closeFile];
	//[self.oStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	NSLog(@"Finsihed recording to %@", [outputFileURL description]); 
	//[[NSWorkspace sharedWorkspace] openURL:outputFileURL];
}
	 
	/*
-(void) appendChunkToFile:(NSString *)chunkFileName {
	@synchronized (self) {
	NSFileHandle *inFile = [NSFileHandle fileHandleForReadingAtPath:chunkFileName];
	NSData *buffer = [inFile readDataToEndOfFile];
  [outFile writeData: buffer]; 
	[inFile closeFile];

  if (inFile == nil) {
		NSLog (@"Open of fileA for reading failed\n");
		return;
  }
	NSError *err;
	[[NSFileManager defaultManager] removeItemAtPath:chunkFileName error:&err];
	}
}
*/

- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didOutputSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection {
	//static int count = 0;
	
	//if (YES==[self.oStream hasSpaceAvailable]) {
	//	[self.oStream  write:(const uint8_t *)[sampleBuffer bytesForAllSamples] maxLength:[sampleBuffer lengthForAllSamples]];
	//}
	//NSDictionary *atts =[sampleBuffer sampleBufferAttributes];
	//NSLog(@" Samples:%d   Len:%d   Format:%@  atts:%@", [sampleBuffer numberOfSamples], [sampleBuffer lengthForAllSamples], [[sampleBuffer formatDescription] localizedFormatSummary], atts);
	/*
	char *sampleBuf = [sampleBuffer bytesForAllSamples];
	int bufLen = [sampleBuffer lengthForAllSamples];
	char buf[bufLen];
	for (int idx=0; idx<bufLen; idx++) {
		buf[idx] = *(sampleBuf+idx);
	}
	*/
	
	/*
	 @"/Users/Shared/MyRecordedMovie.mov"
	NSString *f = [NSString stringWithFormat:@"/Users/Shared/stream-%d.mov", count++];
	NSData *buffer = [NSData dataWithBytes:[sampleBuffer bytesForAllSamples] length:[sampleBuffer lengthForAllSamples]];
	[buffer writeToFile:f atomically:NO];
	
	[self appendChunkToFile:f];
	 */
	//NSData *buffer = [NSData dataWithBytes:[sampleBuffer bytesForAllSamples] length:[sampleBuffer lengthForAllSamples]];
	//[outFile seekToEndOfFile];
  //[outFile writeData:buffer];
  //[outFile writeData:b];
	//NSLog(@"len: %@", [buffer length]);
	//bytesWritten += [sampleBuffer lengthForAllSamples];
}

  
@end
