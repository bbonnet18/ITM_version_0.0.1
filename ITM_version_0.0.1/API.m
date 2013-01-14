//
//  API.m
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 1/12/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

#import "API.h"
#define kAPIHost @"http://localhost"
#define kAPIPath @"iReporter"// !!!! ******** CHANGE THIS TO OUR SERVER PATH 

@implementation API

@synthesize user;

+(API*)sharedInstance{
    static API* sharedInstance = nil;// initialize the instance as a static instance
    static dispatch_once_t oncePredicate;// this will only allow this static instance to be called upone one time, because GCD contains this dispatch
    
    dispatch_once(&oncePredicate, ^{// do the actual dispatch
        sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAPIHost]];// initializes the url to the root of the host
        //FOR TESTING
        sharedInstance.user = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"IdUser",@"Ben Bonnet",@"fullname", nil];
        // END FOR TESTING
    });
    return  sharedInstance;
}

-(BOOL) isAuthorized{
    NSLog(@"ID %@ - %i", [user objectForKey:@"IdUser"],[[user objectForKey:@"IdUser"] intValue]);
    return [[user objectForKey:@"IdUser"] intValue] > 0;// simple check to see if the user object contains a current userID
}

-(void) commandWithParams:(NSMutableDictionary *)params onCompletion:(JSONResponseBlock)completionBlock{
    
    NSData *uploadFile = nil;// initialize the upload file
    if([params objectForKey:@"file"]){
        uploadFile = (NSData*)[params objectForKey:@"file"];// get the file so we can hold it in a separate place since it's going to be uploaded as an attachment to the request rather than in the request header/body
        [params removeObjectForKey:@"file"];// remove it since we won't keep it there anymore
    }
    
    // create the request
    NSMutableURLRequest * apiRequest = [self multipartFormRequestWithMethod:@"POST" path:kAPIPath parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>formData){
        
        if(uploadFile){// if there was a file, it will be included here in data form
            [formData appendPartWithFileData:uploadFile name:@"file" fileName:@"photo.jpg" mimeType:@"image/jpeg"];// append the part with the photo data, mimetype is image/jpeg
        }
    }];
    
    // create the operation with the request
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:apiRequest];// setup the operation with the request
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject);// this will be the dictionary of JSON
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock([NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"error"]);
    }];
    
    [operation start];
}

//custom init to register the operation class
-(API*) init{
    self = [super init];
    
    if(self != nil){
        user = nil;// initialize the object
        
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];//register the class
        
        //make the default header only accept JSON - see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
        [self setDefaultHeader:@"Accept" value:@"application/json"];
    }
    
    return self;
    
}

@end
