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
#import "HomeViewController.h"
#import "Utilities.h"
#import "Build.h"
#import "MainNavViewController.h" 
#import "ImageTestsViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;
// Core data 
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (NSString*) createTestData;// creates a Build if it's not already created, this will be removed in the final, returns the UUID string for the build ID so it can be passed

@end
