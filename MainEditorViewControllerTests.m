//
//  MainEditorViewControllerTests.m
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 10/8/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import "MainEditorViewControllerTests.h"

@implementation MainEditorViewControllerTests

-(void) setUp{
    self.appDel = [[AppDelegate alloc] init];
    self.testBuildID = @"E8368005-620C-4B8D-993D-BE745939E41D";// sets the testBuildID 
    
}

-(void) testGetBuild{
    MainEditorViewController *mv = [[MainEditorViewController alloc] initWithNibName:@"MainEditorViewController" bundle:nil];
    mv.context = self.appDel.managedObjectContext;
    [mv setBuildID:self.testBuildID];
    // need to place a context here if you want to test this
    // also need to create a build first most likely because this is a different target
    Build* b = [mv getBuild];
    
    STAssertNil(b,@"the attempt to get the build failed");
    
}

-(void) testGetBuildItems{
    
//    MainEditorViewController *mv = [[MainEditorViewController alloc] initWithNibName:@"MainEditorViewController" bundle:nil];
//    [mv setBuildID:self.testBuildID];
//    Build* b = [mv getBuild];
    
    
}

-(void) tearDown{
    self.appDel = nil;
    self.testBuildID = nil;
}
@end
