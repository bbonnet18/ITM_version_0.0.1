//
//  ITMServiceClient.m
//  TestJSONURLRequest
//
//  Created by Ben Bonnet on 2/3/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

#import "ITMServiceClient.h"
#import "AFJSONRequestOperation.h"

#define kITMServiceBaseURLString @"http://itmmobile.net"// the base service string
#define kITMServicePath @"api/Build/" // path to services
#define kITMItemPath @"api/Item/"

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
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];// register the JSONRequestOperation Class
    
    [self setDefaultHeader:@"Accept" value:@"application/json"];// set the default accept header to accept json
    
    return self;
}

-(BOOL)isAuthorized{
    //return [[user objectForKey:@"userID"] intValue] > 0;
    // for testing -
    return YES;
}

- (void) cancelOps{
    
    NSLog(@"total ops: %d",[self.operationQueue operationCount]);
    
    
//    [self cancelAllHTTPOperationsWithMethod:nil path:kITMItemPath];
//    [self cancelAllHTTPOperationsWithMethod:nil path:kITMServicePath];
//    [self.operationQueue cancelAllOperations];
    
    [self.currentRequest cancel];
    
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
    
   [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
       NSLog(@"key: %@ val%@",key,obj);
   }];
    // create the request as multipart to send the file data, this can be configured to send both image and video requests
    NSMutableURLRequest *apiRequest = [self multipartFormRequestWithMethod:@"POST" path:kITMItemPath  parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
		if (uploadFile) {
            
			[formData appendPartWithFileData:uploadFile name:@"file" fileName:fileName mimeType:mimeType];
		}
	}];
    
    NSLog(@"url : %@",apiRequest.URL);
   [apiRequest.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
       NSLog(@"%@ -:- %@",key,obj);
   }];
    
    // create the JSON Operation
    AFJSONRequestOperation* operation = [[AFJSONRequestOperation alloc] initWithRequest: apiRequest];
    operation.JSONReadingOptions = NSJSONReadingAllowFragments;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //success!
       if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUploading"] == YES){
       
             completionBlock(responseObject);// this means that the block will receive the responseObject as it's attribute
       }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //failure :(
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUploading"] == YES){
        NSLog(@"errorNewHTTPOP: %@ - %@ - %@ - %@",[error localizedDescription],[error localizedFailureReason],[error localizedRecoverySuggestion],[error localizedRecoveryOptions]);
            completionBlock([NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"error"]);
        }
    }];
    //[self.operationQueue addOperation:operation];
    self.currentRequest = operation;
    
    [self.currentRequest start];
    

}

- (void) JSONCommandWithParameters:(NSMutableDictionary *)params onCompletion:(JSONResponseBlock)completionBlock{
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSLog(@"%@ - %@",key,obj);
        
    }];
    
    
    NSMutableURLRequest  *req = [self requestWithMethod:@"POST" path:kITMServicePath parameters:params];
    [req setValue:[NSString stringWithFormat:@"application/json"] forHTTPHeaderField:@"Accept"];
    
    NSLog(@"url : %@",req.URL);
    
    
    
    AFJSONRequestOperation* operation = [[AFJSONRequestOperation alloc] initWithRequest: req];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //success!
       if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUploading"] == YES){
        
            completionBlock(responseObject);// this means that the block will receive the responseObject as it's attribute
       }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //failure :(
        
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUploading"] == YES){
            NSLog(@"errorJSONOP: %@ - %@ - %@",[error localizedDescription],[error localizedFailureReason],[error localizedRecoverySuggestion]);
            completionBlock([NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"error"]);
        }
        
        
        
    }];
    
    self.currentRequest = operation;
    
    [self.currentRequest start];
    //[self.operationQueue addOperation:operation];
    

}


@end
