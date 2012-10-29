//
//  ImageTestsViewController.m
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 10/18/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import "ImageTestsViewController.h"

@interface ImageTestsViewController ()

@end

@implementation ImageTestsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *mainImg = [UIImage imageNamed:@"ITM_v0.jpg"];
    self.img = mainImg;
    self.imgView.image =  mainImg;
    [self rotateImg];
    
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    [lib writeImageToSavedPhotosAlbum:mainImg.CGImage orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
        
    }];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) rotateImg{
    NSLog(@"bounds  %f : %f imgView bounds %f:%f orientation: %d",self.view.bounds.origin.x,self.view.bounds.origin.y,self.imgView.bounds.origin.x,self.imgView.bounds.origin.y,self.img.imageOrientation);
}




@end
