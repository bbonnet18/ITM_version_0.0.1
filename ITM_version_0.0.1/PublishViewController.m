//
//  PublishViewController.m
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 10/29/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import "PublishViewController.h"
#import <QuartzCore/QuartzCore.h>

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
    self.infoTxt.layer.borderColor = [[UIColor colorWithRed:0.09 green:0.49 blue:0.57 alpha:1.0] CGColor];
    self.infoTxt.layer.borderWidth = 2.0f;
    
    UIButton *canelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    canelBtn.layer.backgroundColor = [[UIColor colorWithRed:0.89 green:0.01 blue:0.25 alpha:1.0] CGColor];
    [canelBtn setTitle:@" Cancel " forState:UIControlStateNormal];
    canelBtn.layer.borderWidth = 0.5f;
    canelBtn.layer.cornerRadius = 8.0f;
    canelBtn.tintColor = [UIColor colorWithRed:0.89 green:0.01 blue:0.25 alpha:1.0];
    [canelBtn sizeToFit];
    
    CGRect cancelBtnRect = CGRectMake(self.view.frame.size.width/2, self.cancelBtn.frame.origin.y, canelBtn.frame.size.width + 20.0, canelBtn.frame.size.height + 20.0);
    canelBtn.frame = cancelBtnRect;
    cancelBtnRect = CGRectMake(cancelBtnRect.origin.x - (canelBtn.frame.size.width / 2), cancelBtnRect.origin.y, cancelBtnRect.size.width, cancelBtnRect.size.height);
    canelBtn.frame = cancelBtnRect;
    [canelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn removeFromSuperview];
    self.cancelBtn = canelBtn;
    [self.view addSubview:self.cancelBtn];
    //self.infoTxt.backgroundColor = [UIColor blueColor];
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
