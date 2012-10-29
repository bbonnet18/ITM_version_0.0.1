//
//  PreviewImageTest.m
//  ITM_v0
//
//  Created by Lauren Bonnet on 10/7/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import "PreviewImageTest.h"

@implementation PreviewImageTest

-(void) setUp{
    
    
    [super setUp];
    self.testImage = [UIImage imageWithContentsOfFile:@"ITM_v0.jpg"];
    
}

- (void) testInit{
    
    PreviewImage *p = [[PreviewImage alloc] initWithFrame:CGRectMake(0,0,320,320) andImage:self.testImage];
    
    STAssertNotNil(p, @" Could not create the greeting");
    
}

-(void) tearDown{
    
    
}



@end
