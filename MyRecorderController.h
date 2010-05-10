//
//  MyRecorderController.h
//  MyRecorder
//
//  Created by Arb on 5/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@interface MyRecorderController : NSObject {
	IBOutlet QTCaptureView *mCaptureView;
	
	QTCaptureSession           *mCaptureSession;
	QTCaptureMovieFileOutput   *mCaptureMovieFileOutput;
	QTCaptureDeviceInput       *mCaptureDeviceInput;	
	
	NSTimer *_timer;
}

@property (nonatomic, retain) NSTimer *timer;

- (IBAction)startRecording:(id)sender;
- (IBAction)stopRecording:(id)sender;
- (IBAction)recordToNextFile:(id)sender;

@end
