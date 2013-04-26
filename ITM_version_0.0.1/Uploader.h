//
//  Uploader.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 9/6/12.
//
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "UIImage+Resize.h"

@protocol UploadProtocol

@required
// notifies the delegate that the upload is done and provides it with the original buildID provided to it
- (void) uploadDidCompleWithBuildInfo:(NSDictionary*) buildDictionary;
- (void) uploadDidFailWithReason:(NSString*) reason andID:(NSString*)buildID;
- (void) uploadWasCancelledForID:(NSString*) buildID;
- (void) progressForBuild:(NSDictionary*) progressDictionary;// this will handle updating the upload

@end


@interface Uploader : NSObject 

{
    
    id <UploadProtocol> _delegate;// the delegate must adhere to the protocol
    NSString * _buildID;
    NSTimer *_updateTimer;
    //NSOperationQueue *_mediaQueue;// will hold all the upload operations
    NSArray *_mediaItems;// array of the items
    BOOL isUploading;// indicates whether an upload is in progress, this value will always be true once initiated and will move to false when stopped because of application events, including loss of network connection
    NSInteger currentItemUploadIndex;// the index within the mediaItems array for the lastUploaded item
    NSData *_mediaData;// will be used to hold the data
    ALAssetsLibrary *_lib;
    AVAssetExportSession *_export;
    NSInteger _application_id;// the app id returned from the server when new and held here anyway if already there
    NSString * _mediaPathString;// path to the current media objecta
    NSMutableArray *_errors;// holds an array of errors, we will show these to the user if we encounter any errors
    NSURLConnection *_mainConn;// the main url connection object to handle the uploads and downloads
    NSData *_jsonData;// this will be used to hold the JSON that we get from the init function
    BOOL _uploadComplete;// used to track whether completely done uploading, initially set to NO

    NSArray *_emailsToDistribute;// holds all the distribution emails if the user provided any
}

@property (strong, nonatomic) id <UploadProtocol> delegate;
@property (strong, nonatomic) NSString * buildID;


@property (assign, nonatomic) BOOL isUploading;
//@property (strong, nonatomic) NSOperationQueue *mediaQueue;
@property (strong, nonatomic) NSData *mediaData;
@property (strong, nonatomic) NSArray *mediaItems;
@property (strong, nonatomic) NSTimer *updateTimer;
@property (strong, nonatomic) ALAssetsLibrary *lib;
@property (strong, nonatomic) AVAssetExportSession *export;
@property (nonatomic, assign) NSInteger application_id;
@property (strong, nonatomic) NSString *mediaPathString;
@property (strong, nonatomic) NSMutableArray *errors;
@property (strong, nonatomic) NSURLConnection *mainConn;
@property (strong, nonatomic) NSData *jsonData;
@property (assign, nonatomic) BOOL uploadComplete;
@property (strong, nonatomic) NSArray *emailsToDistribute;// handles all the emails from the user when there are emails to distribute this to

// this method takes in an array of dictionary objects and a JSONData object and starts the process of uploading
- (id) initWithBuildItems:(NSArray*) buildItemVals buildID:(NSString*) idNum;

// stops the uploads from happening
- (void) stopUpload;

// resumes the upload process from the current point
- (void) resumeUpload;

- (void) cancelUpload;// cancels an upload for good

//- (void) buildRequestAndUpload;// starts the process to upload

- (void) createJSONDataRequest:(NSData*)jsonData;// starts the upload process and sends the JSON to the server
@end
