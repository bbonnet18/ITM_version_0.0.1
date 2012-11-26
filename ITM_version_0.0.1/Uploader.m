//
//  Uploader.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 9/6/12.
//
//

// define several constants to be used when uploading data
#define DATA(STRING)	[STRING dataUsingEncoding:NSUTF8StringEncoding]

#define VIDEO_CONTENT @"Content-Disposition: form-data; name=\"%@\"; filename=\"video.mov\"\r\nContent-Type: video/quicktime\r\n\r\n"
#define IMAGE_CONTENT @"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"
#define STRING_CONTENT @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n"
#define MULTIPART @"multipart/form-data; boundary=------------0x0x0x0x0x0x0x0x"


#import "Uploader.h"


@implementation Uploader

@synthesize isUploading = _isUploading;

@synthesize buildID = _buildID;
@synthesize updateTimer = _updateTimer;
@synthesize mediaItems = _mediaItems;
@synthesize mediaData = _mediaData;
@synthesize mediaQueue = _mediaQueue;
@synthesize lib = _lib;
@synthesize export = _export;
@synthesize mediaPathString = _mediaPathString;
@synthesize errors = _errors;
@synthesize mainConn = _mainConn;
@synthesize jsonData = _jsonData;
@synthesize uploadComplete = _uploadComplete;

// class methods

- (id) initWithBuildItems:(NSArray *)buildItemVals andJSONData:(NSData *)jsonData buildID:(NSString*) idNum{
    
     if ( self = [super init] ) {
         self->currentItemUploadIndex = 0;// set to zero to get things started
         
         // check the user defaults to see if it was already uploading, get the last index if it was
         if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUploading"]){
             NSInteger lastUploadIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"uploadIndex"];
             self->currentItemUploadIndex = lastUploadIndex;
         }else{// set it to uploading now
             [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isUploading"];
         }
         

         
         
         self.buildID = idNum;// set this so we can store it and return it
         // initialize the library that we'll use to get assets
         self.lib = [[ALAssetsLibrary alloc] init];
         self.isUploading = YES;// set this to yes to indicate that the class is curently uploading
         self.mediaItems = buildItemVals;
         self.mediaQueue = [[NSOperationQueue alloc] init]; //initialize the mediaQueue
         self.uploadComplete = NO;
         self->_jsonSent = NO;
     }
    
    return self;
    
}




- (void) stopUpload{
    if(self.isUploading){
        self.isUploading = NO;
        // make sure to capture the upload index in user defaults so you can come back to it
        [[NSUserDefaults standardUserDefaults] setInteger:self->currentItemUploadIndex forKey:@"uploadIndex"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isUploading"];// set it to isUploading because we were uploading until now
        [self.mediaQueue cancelAllOperations];// cancel anything that's currently uploading in the queue
        // stop the queue and do any necessary cleanup
    }
    
    
    
}


- (void) resumeUpload{
    // check if uploadComplete
    // check to see if the user defaults contain an index for a previously started upload, if so start at that number
    // and begin creating requests
    
    //check to see if we were uploading
    // if so, set this to uploading,
    // then check to see if the media is uploaded
    // then, if not uploaded, then set the currentItemUploadIndex to the uploadIndex from userDefaults and call buildRequestAndUpload
    // if the media is uploaded, then upload JSON
    if(!self.uploadComplete){
        self.isUploading = YES;
        self->currentItemUploadIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"uploadIndex"];
        
        if(![self checkMediaComplete]){
            [self buildRequestAndUpload];//
        }else{
            self->_jsonSent = YES;
            [self createJSONDataRequest];
        }
        
    }else{// caught it just when it was done, so now make sure to run the delegate actions
        [self.delegate uploadDidCompleWithBuildID:self.buildID];
    }
    
    
    
}

// end class methods

// private methods

// kicks off the process to build the upload request for video, image and audio data by checking each media type and calling the createMediaDataFromPath method
-  (void) buildRequestAndUpload{
    
    NSDictionary *itemToUpload = [self.mediaItems objectAtIndex:self->currentItemUploadIndex];
    
    NSString *typeForMedia = [itemToUpload valueForKey:@"type"];
    NSString *mediaPath = [itemToUpload valueForKey:@"path"];
    if([typeForMedia isEqualToString: @"image"]){
        [self createImageDataFromPath:mediaPath];
    }else{
        [self createVideoDataFromPath:mediaPath];
    }
}

- (void) createVideoDataFromPath:(NSString*) path{
    
       // intiialize the asset to get a reference to it
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:path]];
    // these path components can be tricky and you need to store the file in the right place. The place below works better than all others to store larger files temporarily.
    //setup all the file path components
//    NSString *basePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/temp"];
//    NSString *filePath = [basePath stringByAppendingString:@"tempMov"];
//    NSString *fullPath = [filePath stringByAppendingPathExtension:@"mov"];
    
    
    NSString *movName = @"tempUploadMov";
    NSString *movPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.mov",movName]];
    //NSURL *url = [NSURL fileURLWithPath:path];
    
    
    self.mediaPathString = movPath;

    NSLog(@"######## _____------- videoDataFromPath: %@",movPath);
    
    // remove the file if for some reason it's in the directory already
    if([[NSFileManager defaultManager] fileExistsAtPath:self.mediaPathString]){
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:self.mediaPathString] error:nil];
    }
    // used to set up presets if there are many to choose from
    
    
    
    // set up the export session with the preset for medium quality videos
    self.export = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    // set up the export url to export the video to the temporary directory
    self.export.outputURL = [NSURL fileURLWithPath:self.mediaPathString];
    self.export.shouldOptimizeForNetworkUse = YES;// optimize for the networks
    //    NSArray *supportedFileTypes = [self.export supportedFileTypes];
    //
    //    for (int i = 0; i<[supportedFileTypes count]; i++) {
    //        NSLog(@"supported file: %@",[supportedFileTypes objectAtIndex:i]);
    //
    //    }
    //
    // export the movie as a quicktime video
    self.export.outputFileType = AVFileTypeQuickTimeMovie;//@"com.apple.quicktime-movie"; also works
    // start the export and respond when the export completes, regardless of the completion type (i.e. completed, failure, etc.)
    [self.export exportAsynchronouslyWithCompletionHandler:^{
        // check the status report problems or start a media request with the newly exported movie
        switch ([self.export status]) {
            case AVAssetExportSessionStatusCompleted:
                [self showMessage];
                [self performSelectorOnMainThread:@selector(createMediaRequestFromBuildItem) withObject:nil waitUntilDone:YES];
                break;
            case AVAssetExportSessionStatusFailed:
                [self showMessage];
            default:
                [self showMessage];
                break;
        }
    }];
    
}


// get the image and save it to a temp directory
- (void) createImageDataFromPath:(NSString*) path{
    
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    
    [lib assetForURL:[NSURL URLWithString:path] resultBlock:^(ALAsset *asset) {
         UIImage *preview = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage] scale:0.5 orientation:UIImageOrientationUp];
        [self performSelectorOnMainThread:@selector(saveTempImage:) withObject:preview waitUntilDone:NO];
    } failureBlock:^(NSError *error) {
        NSLog(@"error: %@",[error localizedDescription]);
    }];

}
// save a temporary image to the docs folder
- (void) saveTempImage:(UIImage*)tempImg{
    
    NSString *imageName = @"tempUploadImg";
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.jpg",imageName]];
    NSURL *url = [NSURL fileURLWithPath:path];

    
    self.mediaPathString = path;
    
    // remove the file if for some reason it's in the directory already
    if([[NSFileManager defaultManager] fileExistsAtPath:self.mediaPathString]){
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:self.mediaPathString] error:nil];
    }
    // used to set up presets if there are many to choose from
    
    [UIImageJPEGRepresentation(tempImg, 0.75f) writeToURL:url   atomically:YES];

    [self createMediaRequestFromBuildItem];

}

-(void) showMessage{
    // check to see if the export object is currently exporting
    if([self.export status] == AVAssetExportSessionStatusExporting){
        NSLog(@" STATUS: exporting");
    }
    if([self.export status] == AVAssetExportSessionStatusFailed){
        // add the error to the error array
        [self.errors addObject:[NSString stringWithFormat:@"Error exporting video - %@",[self.export.error localizedDescription]]];
        NSLog(@" STATUS: Failed - error: %@ - %@ - %@ ", [self.export.error localizedDescription], [self.export.error localizedRecoverySuggestion], [self.export.error localizedFailureReason]);
    }
    if([self.export status] == AVAssetExportSessionStatusWaiting){
        NSLog(@" STATUS: Waiting");
    }
    if([self.export status] == AVAssetExportSessionStatusCompleted){
        NSLog(@" STATUS: completed");
    }
    if([self.export status] == AVAssetExportSessionStatusUnknown){
        NSLog(@" STATUS: UNKNOWN");
    }
    if([self.export status] == AVAssetExportSessionStatusCancelled){
        NSLog(@" STATUS: CANCELLED");
    }
}


-(void) postRequest: (NSURLRequest*)request{
    
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:self.mediaQueue completionHandler:^(NSURLResponse *r, NSData *d, NSError *e){
        NSString *str = [[NSString alloc] initWithData: d encoding:NSUTF8StringEncoding];// make sure the response returned by the server is
        // going to contain the id number of the screen that was uploaded, so we can check it off
        
        // we were either successful or unsuccessful, in either event, we need to
        // set the network activity indicator to off
        NSString *result = [NSString stringWithFormat:@"%@",d];
        if(![result isEqualToString:@"error"]){
            [self performSelectorOnMainThread:@selector(doneUploading:) withObject:str waitUntilDone:NO];
        }else{
            NSString *errorStr = [NSString stringWithFormat:@"error from server"];
            [self.errors addObject:errorStr];// add the error to the errors array
            
        }
        
    }];
    
    
    
    
}



// called when the item is done uploading, set's the currently uploading item's uploaded property to YES
- (void) doneUploading:(NSString*)message{
    
  
    self.mediaData = nil;// release the data now that the upload has taken place
    // remove temporary file if it exists
    if([[NSFileManager defaultManager] fileExistsAtPath:self.mediaPathString]){
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:self.mediaPathString] error:nil];
        self.mediaPathString = nil;
    }
    // set the status of the object to uploaded
    NSDictionary *uploadedObject = [self.mediaItems objectAtIndex:self->currentItemUploadIndex];
    NSLog(@"uploadObject -- path:%@ type:%@ status:%@",[uploadedObject valueForKey:@"path"],[uploadedObject valueForKey:@"type"],[uploadedObject valueForKey:@"status"]);
    // check the message and set the status to YES if upload worked for this item
    if([message isEqualToString:@"file is valid"]){
        [[self.mediaItems objectAtIndex:self->currentItemUploadIndex] setValue:@"YES" forKey:@"status"];
        if(![self checkMediaComplete]){// if the media items are all done, then move on to the JSON
            NSLog(@"currentItemUploadIndex: %d buildItems%d",self->currentItemUploadIndex, [self.mediaItems count]);
            self->currentItemUploadIndex ++;
            [self buildRequestAndUpload];// takes the next one and starts the upload process
        }else{// if no message received from the server, then we are done and we need to either send the json or end the upload process
        // they have all been uploaded
        // close out the item uploading process
        // create an uploading post request for the json data
        // end everything and change status
        NSLog(@"N_O_T r-e-t-u-r-n-e-d");
            if(!self->_jsonSent){// temporary way to check whether JSON has been sent
                [self createJSONDataRequest];// send the json to complete the upload
                self->_jsonSent = YES;//
            }
        }
    }else if([message isEqualToString:@"JSON"]){
        self.isUploading = NO;
        self.uploadComplete = YES;
        [[NSUserDefaults standardUserDefaults] setValue:@"NO" forKey:@"isUploading"];// set defaults to no
        [[NSUserDefaults standardUserDefaults] setValue:0 forKey:@"uploadIndex"];// set upload indext to 0
        [self.delegate uploadDidCompleWithBuildID:self.buildID];
    }


}
// check to see if all the media is uploaded, if so, upload the text content as JSON
- (BOOL) checkMediaComplete{
    // check to see if each one of the objects in self.mediaItems are uploaded
    float i = 0.0;
    BOOL allUploaded = YES;
    // the count to advance to get the ultimate number of completed uploads
    for(NSObject *b in self.mediaItems){
        NSString *status = [b valueForKey: @"status"];
        if(![status isEqualToString: @"YES"]){
            allUploaded = NO;
            break;
        }else{
            i++;
        }
    }

    if(allUploaded){
        return YES;
    }else {
        return NO;
    }
    
}
// gets the JSON data and creates a request, appending the data to the request and uploading it
- (void) createJSONDataRequest{
    NSData *buildData = self.jsonData;
    
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSString *baseurl =  @"http://192.168.1.2/Revolt/upload_media.php";
    NSURL *url = [NSURL URLWithString:baseurl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    if (!urlRequest) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    }
    //-- probably need to change the content type and/or the encoding of the data, most likely the content type to reflect JSON string data
    [urlRequest setHTTPMethod: @"POST"];
    [urlRequest setValue:MULTIPART forHTTPHeaderField: @"Content-Type"];
    // set a post variable that uniquely indicates this object, may need to include that in the dictionary to begin with for each item uploaded and for the JSON upload
    [urlRequest setHTTPBody:buildData];
    // post the request to the server
    [self postRequest:urlRequest];
    
    
}

- (void) createMediaRequestFromBuildItem{
    // data from the file in the directory
    // get the current buildItem's values
    NSDictionary *b = [self.mediaItems objectAtIndex:self->currentItemUploadIndex];
    NSError *err = nil;
    self.mediaData = [NSData dataWithContentsOfFile:self.mediaPathString options:NSDataReadingMappedAlways error:&err]; // option indicates that it should map the file
    
    if(err != nil){
        NSLog(@"reason: %@ other: %@ suggestions: %@",[err localizedFailureReason], [err localizedDescription], [err localizedRecoverySuggestion]);
        [self.delegate uploadDidFailWithReason:[err localizedDescription] andID:self.buildID];
    }
    // removing all the credential stuff for demo
    // create the dictionary
    //    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:HOST port:0 protocol:@"http" realm:nil authenticationMethod:nil];
    //
    //    NSURLCredential *credential = [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:protectionSpace];
    //    if (!credential){
    //        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //
    //    }
    //    NSString *uname = credential.user;
    //    NSString *pword = credential.password;
    //
    //	if (!uname || !pword || (!uname.length) || (!pword.length)){
    //		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //    }
	NSMutableDictionary* post_dict = [[NSMutableDictionary alloc] init];
    //	[post_dict setObject:uname forKey:@"username"];
    //	[post_dict setObject:pword forKey:@"password"];
	[post_dict setObject:@"Posted to localhost" forKey:@"message"];
	[post_dict setObject:self.mediaData forKey:@"mediaBen"];
    
    // need to set this so it appears as the file and not underneath the media key when showing up on the server
    
	NSData *postData = [self generateFormDataFromPostDictionary:post_dict withType:[b valueForKey:@"type"]];
    
    
	NSString *baseurl =  @"http://192.168.1.2/Revolt/upload_media.php";
    NSURL *url = [NSURL URLWithString:baseurl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    if (!urlRequest) {
        [self.delegate uploadDidFailWithReason:@"Could not create the request" andID:self.buildID];
        
    }
    [urlRequest setHTTPMethod: @"POST"];
	[urlRequest setValue:MULTIPART forHTTPHeaderField: @"Content-Type"];
    [urlRequest setHTTPBody:postData];
    
    [self postRequest:urlRequest];
    
}

// generatePostData

- (NSData*)generateFormDataFromPostDictionary:(NSDictionary*)dict withType:(NSString*) type
{
    id boundary = @"------------0x0x0x0x0x0x0x0x";// set the boundry
    NSArray* keys = [dict allKeys];// get the keys
    NSMutableData* result = [NSMutableData data];// initialize the data object
    NSObject *b = [self.mediaItems objectAtIndex:self->currentItemUploadIndex];
    NSString *mediaType =  [b valueForKey:@"type"];// get the media type
    
    
    for (int i = 0; i < [keys count]; i++)
    {
        id value = [dict valueForKey: [keys objectAtIndex:i]];
        [result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		
		if ([value isKindOfClass:[NSData class]])
		{
			// handle video data
            NSString* formstring = nil;
            if([mediaType isEqualToString:@"video"]){
                formstring = [NSString stringWithFormat:VIDEO_CONTENT, [keys objectAtIndex:i]];
                NSLog(@"formstring-video: %@",formstring);
            }else{
                formstring = [NSString stringWithFormat:IMAGE_CONTENT, [keys objectAtIndex:i]];
                NSLog(@"formstring-image: %@",formstring);
            }
			
			[result appendData: DATA(formstring)];
			[result appendData:value];// appends the data itself
		}
		else
		{
			// all non-image fields assumed to be strings
			NSString *formstring = [NSString stringWithFormat:STRING_CONTENT, [keys objectAtIndex:i]];
			[result appendData: DATA(formstring)];
			[result appendData:DATA(value)];
            
            NSLog(@"formstring non-image: %@",formstring);
            
		}
		
		NSString *formstring = @"\r\n";
        [result appendData:DATA(formstring)];
    }
	
	NSString *formstring =[NSString stringWithFormat:@"--%@--\r\n", boundary];
    [result appendData:DATA(formstring)];
    
    
    return result;
}


// end private methods


@end
