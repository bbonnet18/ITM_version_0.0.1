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
    NSString *fName = [userInfo valueForKey:@"firstname"];
    NSString *lName = [userInfo valueForKey:@"lastname"];
//    NSString *email = [[NSUserDefaults standardUserDefaults] valueForKey:@"email"];
//    NSString *userName = [[NSUserDefaults standardUserDefaults] valueForKey:@"userName"];
//    NSString *password = [[NSUserDefaults standardUserDefaults] valueForKey:@"password"];
    
    self.fName.text = fName;
    self.lName.text = lName;
//    self.email.text = email;
//    self.userName.text = userName;
//    self.password.text = password;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showPassword:(id)sender {
    if(self.password.isSecureTextEntry){
        [self.password setSecureTextEntry:NO];
    }else{
        [self.password setSecureTextEntry:YES];
    }
}

- (IBAction)save:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setValue:self.password.text forKey:@"password"];
    [self.delegate doneEditing];
}

- (IBAction)cancel:(id)sender {
    [self.delegate doneEditing];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
