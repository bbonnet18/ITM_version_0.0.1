//
//  YammerLoginViewController.h
//  ITM_version_0.0.1
//
//  Created by Ben Bonnet on 9/2/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMLoginController.h"

@interface YammerLoginViewController : UIViewController <YMLoginControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton* loginBtn;
-(IBAction)loginWithYammer:(id)sender;// logs the user in
-(void) didCompleteLogin:(NSNotification*) notification;// completed the login
-(void) didFailLogin:(NSNotification*) notification;// failed the login


@end
