#
#  MyController.rb
#  str
#
#  Created by krishna krishnamaneni on 5/9/10.
#  Copyright (c) 2010 Apple Inc. All rights reserved.
#
require 'fileutils'
require 'pp'
class MyController < NSWindowController
  attr_writer :button
  attr_accessor :qt_capture_view
  attr_accessor :capture_movie_file_output
  attr_accessor :file
  attr_accessor :capture_session_started
  attr_accessor :ind
  FileNamePrefix = "/Users/Shared/rec/seg"
  ProcessedDirPath = "/Users/kk/Sites/proc/"
  ProcessedStreams = []
  def awakeFromNib
	capture_session = QTCaptureSession.new()
	success = false
	error = nil
	device = QTCaptureDevice.defaultInputDeviceWithMediaType("vide")
	
	if(device)
			success = device.open(error)
			if(!success)
				puts "Not success 1"
			end
			capture_device_input = QTCaptureDeviceInput.alloc().initWithDevice(device)
			success = capture_session.addInput(capture_device_input, error:error)
			if(!success)
				puts "Not success 2"
			end
			@capture_movie_file_output = QTCaptureMovieFileOutput.new()
			success = capture_session.addOutput(capture_movie_file_output, error:error);
			capture_movie_file_output.setDelegate(self)
			
			
			connection_enumerator = capture_movie_file_output.connections.objectEnumerator

 

        while (connection = connection_enumerator.nextObject) 

            mediaType = connection.mediaType;

            compressionOptions = nil;

            if (mediaType.isEqualToString("vide")) 

                compressionOptions = QTCompressionOptions.compressionOptionsWithIdentifier("QTCompressionOptions240SizeH264Video")

             end
 

			capture_movie_file_output.setCompressionOptions(compressionOptions, forConnection:connection);
			qt_capture_view.setCaptureSession(capture_session);
		
		end
		    capture_session.startRunning

	end
				
	
	puts "Awake from nib!"
  end
  
  def clicked(sender)
    puts "Button clicked!"
  end
  
  def start_recording(sender)
	@ind = 0
	capture_movie_file_output.recordToOutputFileURL(NSURL.fileURLWithPath(FileNamePrefix +  ind.to_s + ".mov"), bufferDestination:1);
	@capture_session_started = true;
	Thread.new do
		while(@capture_session_started == true)
			sleep 3
			@ind = ind+1
			capture_movie_file_output.recordToOutputFileURL(NSURL.fileURLWithPath(FileNamePrefix +  ind.to_s + ".mov"));
		end
	end
  end
  
  
  def stop_recording(sender)
	capture_movie_file_output.recordToOutputFileURL(nil);
	
	@capture_session_started = false;
	file.close()
  end
  
  def captureOutput(captureOutput, didFinishRecordingToOutputFileAtURL:outputFileURL, forConnections:connections, dueToError:error)
	puts QTKit.QTStringFromTime(captureOutput.recordedDuration)
	fname = outputFileURL.lastPathComponent()
	fname = fname.split(".mov")[0]
	pdirname = ProcessedDirPath + fname
	FileUtils.mkdir(pdirname)
	puts "mediafilesegmenter -f #{pdirname} #{outputFileURL.path}"
	out = `mediafilesegmenter -f #{pdirname} #{outputFileURL.path}`
	pfile = "seg" + ProcessedStreams.size.to_s + ".ts"
	puts "mv " + pdirname + "/" + "fileSequence0.ts, " + ProcessedDirPath + pfile
	FileUtils.mv pdirname + "/" + "fileSequence0.ts", ProcessedDirPath + pfile
	puts `cat #{pdirname}/prog_index.m3u8`
	puts "rm -r pdirname"
	FileUtils.rm_r pdirname
	
	ProcessedStreams << [pfile, 4, ProcessedStreams.size]
	puts out
	pp ProcessedStreams
	write_playlist_file
	
	
	puts "Created file: " + ProcessedDirPath + pfile
	
  #  NSWorkspace.sharedWorkspace.openURL(outputFileURL);
  end
  
  def write_playlist_file
	fileHeader = "#EXTM3U
#EXT-X-TARGETDURATION:5"
	fileString = fileHeader + "\n"
	streams = nil
	if ProcessedStreams.size > 3 
		streams = ProcessedStreams[-3..-1]
	else
		streams = ProcessedStreams
	end
	streams.each_with_index do |s, i|
		fileString += "#EXT-X-MEDIA-SEQUENCE:#{s[2]}\n" + "#EXTINF:#{s[1]}, \n" + "#{s[0]}\n"
	end
	File.open(ProcessedDirPath + "prog_index.m3u8", "w") do |f|
		f.write(fileString)
	end
  end
  
  #def captureOutput(captureOutput, didOutputSampleBuffer:sampleBuffer, fromConnection:connection)
	#puts sampleBuffer.bytesForAllSamples()[10]
#	(0..(sampleBuffer.lengthForAllSamples() - 1)).each {|i| file.write sampleBuffer.bytesForAllSamples()[i] }
#	puts sampleBuffer.lengthForAllSamples()
	
	
	
  #end
end
