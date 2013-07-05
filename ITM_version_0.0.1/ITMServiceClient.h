//
//  ITMServiceClient.h
//  TestJSONURLRequest
//
//  Created by Ben Bonnet on 2/3/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

/*
 This class will be used to intract with the In The Moment Service
 */

#import "AFHTTPClient.h"
#import "AFNetworking.h"
#import <Foundation/Foundation.h>

// first part is the name of the block, second is the parameter it will receive
typedef void (^JSONResponseBlock)(NSDictionary*json); // define the response block to call when receiving a callback from the service - this will be a JSON json dictionary

@interface ITMServiceClient : AFHTTPClient


@property(nonatomic,strong) NSDictionary* user;// used to hold all the user's information 

@property(nonatomic, strong) AFHTTPRequestOperation *currentRequest;// used to track the current request so it can be cancelled

-(BOOL) isAuthorized;// this will be called to determine whether the current user is authorized to access the service
-(void) cancelOps;
-(void)commandWithParameters:(NSMutableDictionary*)params onCompletion:(JSONResponseBlock)completionBlock;// this will be used to create a response block to call when the user gets a response
-(void)JSONCommandWithParameters:(NSMutableDictionary*)params onCompletion:(JSONResponseBlock)completionBlock;// this will be used to send the JSON data only, provide the JSON as a dictionary
-(void)JSONUSERCommandWithParameters:(NSMutableDictionary*)params onCompletion:(JSONResponseBlock)completionBlock;// this will be used to send the JSON user data only, provide the JSON as a dictionary
+(ITMServiceClient*)sharedInstance;// this will return the shared client anywhere in the app

@end
