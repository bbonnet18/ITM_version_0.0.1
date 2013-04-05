//
//  AppDelegate.h
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 10/8/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainEditorViewController.h"
#import "PreviewImage.h"
#import "Utilities.h"
#import "Build.h"
#import "MainNavViewController.h" 
#import "Uploader.h"
#import "HomeTableViewController.h"
#import "ITMServiceClient.h"
#import "LoginViewController.h"
#import "TestFlight.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate,UploadProtocol, UIAlertViewDelegate,UploadControl>{
    BOOL _isReachable;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) Uploader *uploader;// used to reference the uploader
@property (strong, nonatomic) NSOperationQueue *uploadQueue;// the upload queue will be responsible for all upload operations and we will check the status of this to determine whether all build items have uploaded for a specific build or if any uploads are going on at the moment
@property (nonatomic, assign) BOOL isReachable;// this will be toggled on and off based on the reachability

@property (strong, nonatomic) NSMutableArray *uploadObjects;// this would be a holder for the media items that need to be uploaded to the server, i.e text, video, audio, images
// Core data
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


- (void) addItemsToUploadObjects:(NSMutableArray *)mediaItems;// for uploading items

- (NSArray*) getUploadObjectsAtIndex:(NSUInteger)uploadIndex;
-(void)reachabilityChanged:(NSNotification*)note;
@end
