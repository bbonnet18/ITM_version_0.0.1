//
//  YammerLoginViewController.m
//  ITM_version_0.0.1
//
//  Created by Ben Bonnet on 9/2/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

#import "YammerLoginViewController.h"
#import "YMConstants.h"
#import "YMHTTPClient.h"
@interface YammerLoginViewController ()

@end

@implementation YammerLoginViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCompleteLogin:) name:YMYammerSDKLoginDidCompleteNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailLogin:) name:YMYammerSDKLoginDidFailNotification object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) loginWithYammer:(id)sender{
    [[YMLoginController sharedInstance] setDelegate:self];
    
    [[YMLoginController sharedInstance] startLogin];
    

}
// show failure message
- (void) loginController:(YMLoginController *)loginController didFailWithError:(NSError *)error{
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Failed to login with Yammer - Make sure your credentials are correct and try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [av show];
    
}

-(void) loginController:(YMLoginController *)loginController didCompleteWithAuthToken:(NSString *)authToken{
    // get the user and check to see if the password is temporary, if so
    // send out the notification
    NSDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    NSString* password = [user valueForKey:@"password"];
    if([password isEqualToString:@"TEMPPASSWORD"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RegisterUser" object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginUser" object:nil];
    }
}


-(void) didCompleteLogin:(NSNotification *)notification{
    
      
}

-(void) didFailLogin:(NSNotification *)notification{
    // show failure message
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Failed to login with Yammer - Make sure your credentials are correct and try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [av show];
}

-(void) storeUserInfo:(YMLoginController *)loginController withYammerUserInfo:(NSDictionary *)userDic{
    // - need to check if the user is already here. If the user is here, then make sure the emails are the same, if they are, do not replace anything (same user)
    // if for some reason the emails don't match up, replace all user info and force new password
    NSDictionary *user = userDic[@"user"];
    
    NSDictionary *contact = user[@"contact"];
    NSString *primaryEmail = nil;
    NSDictionary *emailAddresses = contact[@"email_addresses"];
    for (NSDictionary* email in emailAddresses) {
        if([email[@"type"] isEqualToString:@"primary"]){
            primaryEmail = email[@"address"];
        }
    }
    
    NSString *firstName = user[@"first_name"];
    NSString *lastName = user[@"last_name"];
    NSString *password = @"TEMPPASSWORD";// set the temp password, will be changed later
    NSDictionary *allUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:primaryEmail,@"email",firstName,@"firstName",lastName,@"lastName",password,@"password", nil];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:allUserInfo forKey:@"user"];

}


@end
