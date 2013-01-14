//
//  LoginViewController.m
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 1/12/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

#import "LoginViewController.h"
#import "API.h"
#include <CommonCrypto/CommonDigest.h>
#define kSalt @"adlfu3489tyh2jnkLIUGI&%EV(&0982cbgrykxjnk8855" // salt for the password

@interface LoginViewController ()

@end

@implementation LoginViewController
// once synthisized, you can refer to the names without "self."
@synthesize userName, password, loginBtn, registerBtn;

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
   
    [userName becomeFirstResponder];
    // Do any additional setup after loading the view from its nib.
}

-(IBAction)btnLoginRegisterTapped:(id)sender{
    if(userName.text.length < 4 || password.text.length <4){
        // too short so present an error
      UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error - username or password is incorrect" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [av show];
        return;
        
    }
    // salted password
    NSString *saltedPassword = [NSString stringWithFormat:@"%@%@", password.text, kSalt];
    // prepare the hashed storage
    NSString *hashedPassword = nil;
    unsigned char hashedPasswordData[CC_SHA1_DIGEST_LENGTH];
    NSData *data = [saltedPassword dataUsingEncoding:NSUTF8StringEncoding];
    if(CC_SHA1([data bytes],[data length],hashedPasswordData)){
        hashedPassword = [[NSString alloc] initWithBytes:hashedPasswordData length:sizeof(hashedPasswordData)  encoding:NSASCIIStringEncoding];// this creates the actual password data
    }else{
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error - Password can't be sent" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [av show];

    }
    // cast sender as a button and check the tag to see if it's a register
    NSString *command = (((UIButton*)sender).tag == 1) ? @"register":@"login";// register button has a tag of 1
    
    // create the commands dictionary
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:command,@"command",userName.text,@"username",hashedPassword,@"password", nil];
    
    // make the call to the server with the parameters
    [[API sharedInstance] commandWithParams:params onCompletion:^(NSDictionary *json) {
        NSDictionary* res = [[json objectForKey:@"result"] objectAtIndex:0];
        
        if ([json objectForKey:@"error"]==nil && [[res objectForKey:@"IdUser"] intValue]>0) {
            //success
            [[API sharedInstance] setUser:res];// setting the user information
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];// remove this screen
            // show the logged in message
            [[[UIAlertView alloc] initWithTitle:@"Logged in!" message:[NSString stringWithFormat:@"Welcome %@",[res objectForKey:@"username"]] delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
            
            
        } else {
            //error
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error - Server Error" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [av show];
        }
        
        
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
