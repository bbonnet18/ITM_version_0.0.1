//
//  RegisterViewController.h
//  ITM_version_0.0.1
//
//  Created by Ben Bonnet on 6/29/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

/* This class will register the user with the service by getting the information from Yammer and adding it to this application, then setting the user information. 
 */

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController
@property (nonatomic, strong) IBOutlet UIButton *registerBtn; // register btn

-(IBAction)registerAction:(id)sender;// this will get the information from Yammer and then Yammer will load this screen again.
@end
