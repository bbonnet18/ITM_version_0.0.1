//
//  ITMServiceClient.m
//  TestJSONURLRequest
//
//  Created by Ben Bonnet on 2/3/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

#import "ITMServiceClient.h"
#import "AFJSONRequestOperation.h"

#define kITMServiceBaseURLString @"https://itmgo.com"// the base service string
#define kITMServicePath @"api/Build/" // path to services
#define kITMItemPath @"api/Item/"
#define kITMPreviewPath @"api/Item/preview"
#define kITMUserPath @"api/User/register"

@interface ITMServiceClient ()

-(void) setAuth;

@end

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
    [self setAuth];
    
    return self;
}

-(BOOL)isAuthorized{
    //return [[user objectForKey:@"userID"] intValue] > 0;
    // for testing -
    return YES;
}
// sets the authorization headers to the credentials for this individual
-(void) setAuth{
    
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
//
    NSString *userName = [userInfo objectForKey:@"email"];
    NSString *password = [userInfo objectForKey:@"password"];

    [self setAuthorizationHeaderWithUsername:userName password:password];
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
    
    [self setAuth];// make sure you're using the most up to date password
    
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
        fileName = [NSString stringWithFormat:@"%@_%@.mp4",[params objectForKey:@"application_id"],[params objectForKey:@"orderNumber"]];
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

- (void) uploadPreviewItem:(NSMutableDictionary *)params onCompletion:(JSONResponseBlock)completionBlock{// using the block from the header file and that will receive a JSON dictionary
    
    [self setAuth];// make sure you're using the most up to date password
    
    NSData* uploadFile = nil;
	if ([params objectForKey:@"file"]) {
		uploadFile = (NSData*)[params objectForKey:@"file"];
		[params removeObjectForKey:@"file"];
	}
    
    NSString *fileName = [NSString stringWithFormat:@"previewItem.jpg"];
    
    NSString *mimeType = @"image/jpg";
    NSString *itemPath = [NSString stringWithFormat:@"%@/%@",kITMPreviewPath,[params valueForKey:@"id"]];
    // create the request as multipart to send the file data, this can be configured to send both image and video requests
    NSMutableURLRequest *apiRequest = [self multipartFormRequestWithMethod:@"POST" path:itemPath parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
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
    
    [self setAuth];
    
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

- (void) JSONUSERCommandWithParameters:(NSMutableDictionary *)params onCompletion:(JSONResponseBlock)completionBlock{

    //no need to [self setAuth] because it only gets called once
    [self setAuthorizationHeaderWithUsername:@"tempuser" password:@"temppassword"];
    NSMutableURLRequest  *req = [self requestWithMethod:@"POST" path:kITMUserPath parameters:params];
    [req setValue:[NSString stringWithFormat:@"application/json"] forHTTPHeaderField:@"Accept"];
    
    NSLog(@"url : %@",req.URL);
    
    NSDictionary *requestDic = [req allHTTPHeaderFields];
    [requestDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSLog(@"key: %@   -    value: %@",key,obj);
    }];
    
    AFJSONRequestOperation* operation = [[AFJSONRequestOperation alloc] initWithRequest: req];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //success!
                    
            completionBlock(responseObject);// this means that the block will receive the responseObject as it's attribute

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //failure :(
        
        
            completionBlock([NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"error"]);
    }];
    
    self.currentRequest = operation;
    
    [self.currentRequest start];
    
}




@end
