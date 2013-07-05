//
//  RegisterViewController.m
//  ITM_version_0.0.1
//
//  Created by Ben Bonnet on 6/29/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

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

-(void) registerAction:(id)sender{
    NSURL *url = [NSURL URLWithString:@"https://itmgo.com/Login.html"];
    
    [[UIApplication sharedApplication] openURL:url];
}

@end
