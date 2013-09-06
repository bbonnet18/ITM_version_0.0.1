//
//  ProfileViewController.m
//  ITM_version_0.0.1
//
//  Created by Ben Bonnet on 6/10/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

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
    
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];

    self.fName.text = [userInfo valueForKey:@"firstName"];
    self.lName.text = [userInfo valueForKey:@"lastName"];
    self.email.text = [userInfo valueForKey:@"email"];

    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)ok:(id)sender {
    [self.delegate doneEditing];
}



-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
