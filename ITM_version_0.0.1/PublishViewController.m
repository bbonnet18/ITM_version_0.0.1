//
//  PublishViewController.m
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 10/29/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import "PublishViewController.h"

@interface PublishViewController ()

@end

@implementation PublishViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)publish:(id)sender{
    [self.delegate userDidPublish];
    
}

- (IBAction)cancel:(id)sender{
    [self.delegate userDidCancel];
}

@end
