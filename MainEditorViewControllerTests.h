//
//  MainEditorViewControllerTests.h
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 10/8/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MainEditorViewController.h"
#import "Build.h"
#import "AppDelegate.h"

@interface MainEditorViewControllerTests : SenTestCase{
    
}

@property (strong, nonatomic) NSString * testBuildID;
@property (strong, nonatomic) AppDelegate *appDel;
-(void) testGetBuild;// this will test whether we can get a build based on an id
-(void) testGetBuildItems;// this will test whether we can return an array of items for a build

@end
