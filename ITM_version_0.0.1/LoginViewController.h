//
//  LoginViewController.h
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 1/12/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

/*
 If it is loaded at app startup, make sure to present this modally so the user can login
 
 */

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UIAlertViewDelegate,UITextFieldDelegate>

@property (strong,nonatomic) IBOutlet UITextField *userName;
@property (strong,nonatomic) IBOutlet UITextField *password;
@property (strong,nonatomic) IBOutlet UIButton *loginBtn;
@property (strong,nonatomic) IBOutlet UIButton *registerBtn;

-(IBAction)btnLoginRegisterTapped:(id)sender;// used to handle both logins and registrations



@end
