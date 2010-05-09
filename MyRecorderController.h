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
}

- (IBAction)startRecording:(id)sender;

- (IBAction)stopRecording:(id)sender;
@end
