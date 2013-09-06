//
//  UserViewController.h
//  ITM_version_0.0.1
//
//  Created by Ben Bonnet on 5/15/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StartScreenProtocol <NSObject>

-(void) userDidGetStarted:(NSDictionary*)userData;

@end

@interface UserViewController : UIViewController <UITextFieldDelegate>{
    id <StartScreenProtocol> _delegate;
    
}
@property (strong, nonatomic) IBOutlet UITextField *firstName;
@property (strong, nonatomic) IBOutlet UITextField *lastName;
@property (strong, nonatomic) IBOutlet UITextField *email;
@property (strong, nonatomic) IBOutlet UIButton *getStartedBtn;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) id <StartScreenProtocol> delegate;
- (IBAction)getStarted:(id)sender;

@end
