//
//  AudioEncode.m
//
//  By Lyle Pratt, September 2011.
//    Updated Oct 2012 by Keenan Wyrobek for Cordova 2.1.0
//    Updated Nov 2014 by Tushar Kanvinde for Cordova 3.5.0
//  MIT licensed
//

#import "AudioEncode.h"

@implementation AudioEncode

@synthesize callbackId;

- (void)encodeAudio:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
	NSString* audioPath = [command.arguments objectAtIndex:0];
    
	NSURL* audioURL = [NSURL fileURLWithPath:audioPath];
	AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL:audioURL options:nil];
    AVAssetExportSession* exportSession = [[AVAssetExportSession alloc] initWithAsset:audioAsset presetName:AVAssetExportPresetAppleM4A];
	
	NSURL* exportURL = [NSURL fileURLWithPath:[[audioPath componentsSeparatedByString:@".wav"] objectAtIndex:0]];
	NSURL* destinationURL = [exportURL URLByAppendingPathExtension:@"m4a"];
    
    exportSession.outputURL = destinationURL;
	exportSession.outputFileType = AVFileTypeAppleM4A;
	
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            NSLog(@"AVAssetExportSessionStatusCompleted");
            [self performSelectorOnMainThread:@selector(doSuccessCallback:) withObject:[exportSession.outputURL path] waitUntilDone:NO];
        } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
            // a failure may happen because of an event out of your control
            // for example, an interruption like a phone call comming in
            // make sure and handle this case appropriately
            NSLog(@"AVAssetExportSessionStatusFailed");
            NSLog(@"   error: %@", exportSession.error);
            
            [self performSelectorOnMainThread:@selector(doFailCallback:) withObject:[NSString stringWithFormat:@"%i", exportSession.status] waitUntilDone:NO];
            
        } else {
            NSLog(@"Export Session Status: %d", exportSession.status);
        }


// ARC no longer accepts this        
//        [exportSession release];
        
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSError *error = noErr;
        if ([fileMgr removeItemAtPath:audioPath error:&error] != YES) {
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
        }
    }];
}

-(void) doSuccessCallback:(NSString*)path {
    NSLog(@"doing success callback");

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:path];
    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackId]];
    
}

-(void) doFailCallback:(NSString*)status {
    NSLog(@"doing fail callback");
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self writeJavascript:[pluginResult toErrorCallbackString:self.callbackId]];
}

@end
