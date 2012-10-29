//
//  ITM_v0Tests.h
//  ITM_v0Tests
//
//  Created by Lauren Bonnet on 10/2/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ImageEditorViewController.h"

@interface ITM_v0Tests : SenTestCase
@property (nonatomic, strong) UIImage * imgToTest;// used to hold a reference
@property (nonatomic, strong) ImageEditorViewController *editor;// reference to the class with the methods
@end
