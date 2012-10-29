//
//  ITM_v0Tests.m
//  ITM_v0Tests
//
//  Created by Lauren Bonnet on 10/2/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import "ITM_v0Tests.h"

@implementation ITM_v0Tests

- (void)setUp
{
    [super setUp];
    self.imgToTest = [UIImage imageWithContentsOfFile:@"ITM_v0.jpg"];
    self.editor = [[ImageEditorViewController alloc] init];
    
    // Set-up code here.
}

- (void) testResize{
    
    UIImage *newImage = [self.editor resizeImage:self.imgToTest newSize:CGSizeMake(160, 120)];
    NSLog(@"new stuff to report - image is testing for nil");
    STAssertNotNil(newImage, @" Could not create the greeting");

}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}



@end
