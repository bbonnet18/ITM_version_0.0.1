//
//  API.h
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 1/12/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFNetworking.h"
typedef void (^JSONResponseBlock)(NSDictionary* json);// json callback block, this can ben used for all the block callbacks from the api

@interface API : AFHTTPClient

@property (strong,nonatomic) NSDictionary *user;// holds the user information when returned from the server
+(API*) sharedInstance;// will be used to access the class as a singleton
-(BOOL) isAuthorized;// will check for authorization
-(void) commandWithParams:(NSMutableDictionary*)params onCompletion:(JSONResponseBlock)completionBlock;// this will be called to send out the commands to the server and to handle the responses in the completionBlock



@end
