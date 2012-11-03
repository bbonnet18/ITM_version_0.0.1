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

@protocol UploadProtocol

@required
// notifies the delegate that the upload is done and provides it with the original buildID provided to it
- (void) uploadDidCompleWithBuildID:(NSString*) buildID;
- (void) uploadDidFailWithReason:(NSString*) reason andID:(NSString*)buildID;

@end


@interface Uploader : NSObject

{
    
    id <UploadProtocol> _delegate;// the delegate must adhere to the protocol
    NSString * _buildID;
    NSTimer *_updateTimer;
    NSOperationQueue *_mediaQueue;// will hold all the upload operations
    NSArray *_mediaItems;// array of the items
    BOOL isUploading;// indicates whether an upload is in progress, this value will always be true once initiated and will move to false when stopped because of application events, including loss of network connection
    NSInteger currentItemUploadIndex;// the index within the mediaItems array for the lastUploaded item
    NSData *_mediaData;// will be used to hold the data
    ALAssetsLibrary *_lib;
    AVAssetExportSession *_export;
    NSString * _mediaPathString;// path to the current media objecta
    NSMutableArray *_errors;// holds an array of errors, we will show these to the user if we encounter any errors
    NSURLConnection *_mainConn;// the main url connection object to handle the uploads and downloads
    NSData *_jsonData;// this will be used to hold the JSON that we get from the init function
    BOOL _uploadComplete;// used to track whether completely done uploading, initially set to NO
}

@property (strong, nonatomic) id <UploadProtocol> delegate;
@property (strong, nonatomic) NSString * buildID;


@property (assign, nonatomic) BOOL isUploading;
@property (strong, nonatomic) NSOperationQueue *mediaQueue;
@property (strong, nonatomic) NSData *mediaData;
@property (strong, nonatomic) NSArray *mediaItems;
@property (strong, nonatomic) NSTimer *updateTimer;
@property (strong, nonatomic) ALAssetsLibrary *lib;
@property (strong, nonatomic) AVAssetExportSession *export;

@property (strong, nonatomic) NSString *mediaPathString;
@property (strong, nonatomic) NSMutableArray *errors;
@property (strong, nonatomic) NSURLConnection *mainConn;
@property (strong, nonatomic) NSData *jsonData;
@property (assign, nonatomic) BOOL uploadComplete;


// this method takes in an array of dictionary objects and a JSONData object and starts the process of uploading
- (id) initWithBuildItems:(NSArray*) buildItemVals andJSONData:(NSData*) jsonData buildID:(NSString*) idNum;

// stops the uploads from happening
- (void) stopUpload;

// resumes the upload process from the current point
- (void) resumeUpload;

@end
