//
//  ImageTestsViewController.h
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 10/18/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ImageTestsViewController : UIViewController
@property (nonatomic, strong) IBOutlet UIImageView *imgView;
@property (nonatomic, strong) UIImage *img;
@end
