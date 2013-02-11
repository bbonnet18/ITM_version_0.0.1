//
//  ITMServiceClient.m
//  TestJSONURLRequest
//
//  Created by Ben Bonnet on 2/3/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

#import "ITMServiceClient.h"
#import "AFJSONRequestOperation.h"

#define kITMServiceBaseURLString @"http://192.168.1.8/service"// the base service string
#define kITMServicePath @"tester.php" // path to services


@implementation ITMServiceClient

@synthesize user;
// setup the static shared client - common approach
+(ITMServiceClient*) sharedInstance{
    static ITMServiceClient *_sharedClient = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedClient = [[ITMServiceClient alloc] initWithBaseURL:[NSURL URLWithString:kITMServiceBaseURLString]];
    });
    return _sharedClient;
}

- (id) initWithBaseURL:(NSURL *)url{
    self = [super initWithBaseURL:url];
    if(!self){
        return nil;
    }
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

-(BOOL)isAuthorized{
    //return [[user objectForKey:@"userID"] intValue] > 0;
    // for testing -
    return YES;
}


// this will upload the file if the file is included with the 
- (void) commandWithParameters:(NSMutableDictionary *)params onCompletion:(JSONResponseBlock)completionBlock{// using the block from the header file and that will receive a JSON dictionary
    NSData* uploadFile = nil;
	if ([params objectForKey:@"file"]) {
		uploadFile = (NSData*)[params objectForKey:@"file"];
		[params removeObjectForKey:@"file"];
	}
    
    NSString *type = [params valueForKey:@"type"];
    
    NSString *fileName = nil;
    
    NSString *mimeType = nil;
    
    if([type isEqualToString:@"image"]){
        
        fileName = [NSString stringWithFormat:@"%@_%@.jpg",[params objectForKey:@"application_id"],[params objectForKey:@"orderNumber"]];
        mimeType = @"image/jpg";
    }else{
        fileName = [NSString stringWithFormat:@"%@_%@.mov",[params objectForKey:@"application_id"],[params objectForKey:@"orderNumber"]];
        mimeType = @"video/quicktime";
    }
    
   
    // create the request as multipart to send the file data, this can be configured to send both image and video requests
    NSMutableURLRequest *apiRequest = [self multipartFormRequestWithMethod:@"POST" path:kITMServicePath  parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
		if (uploadFile) {
            
			[formData appendPartWithFileData:uploadFile name:@"file" fileName:fileName mimeType:mimeType];
		}
	}];
    
    // create the JSON Operation
    AFJSONRequestOperation* operation = [[AFJSONRequestOperation alloc] initWithRequest: apiRequest];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //success!
        completionBlock(responseObject);// this means that the block will receive the responseObject as it's attribute
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //failure :(
        completionBlock([NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"error"]);
    }];
    [operation start];

}

- (void) JSONCommandWithParameters:(NSMutableDictionary *)params onCompletion:(JSONResponseBlock)completionBlock{
    
    NSMutableURLRequest  *req = [self requestWithMethod:@"POST" path:kITMServicePath parameters:params];
    [req setValue:[NSString stringWithFormat:@"application/json"] forHTTPHeaderField:@"Accept"];
    
    AFJSONRequestOperation* operation = [[AFJSONRequestOperation alloc] initWithRequest: req];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //success!
        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //failure :(
        completionBlock([NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"error"]);
    }];
    [operation start];
}


@end
