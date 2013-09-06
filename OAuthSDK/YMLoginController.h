//
// Created by Jerry Destremps on 6/26/13.
// Copyright (c) 2013 Yammer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utilities.h"

@protocol YMLoginControllerDelegate;

@interface YMLoginController : NSObject

@property (nonatomic, weak) id<YMLoginControllerDelegate> delegate;

+ (YMLoginController *)sharedInstance;

- (void)startLogin;
- (BOOL)handleLoginRedirectFromUrl:(NSURL *)url sourceApplication:(NSString *)sourceApplication;
- (NSString *)storedAuthToken;
- (void)clearAuthToken;

@end

@protocol YMLoginControllerDelegate

- (void)loginController:(YMLoginController *)loginController didCompleteWithAuthToken:(NSString *)authToken;
- (void)loginController:(YMLoginController *)loginController didFailWithError:(NSError *)error;
- (void) storeUserInfo:(YMLoginController*) loginController withYammerUserInfo:(NSDictionary*)userDic;// stores the user's information as the user variable in user defaults

@end
