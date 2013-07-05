//
//  ProfileViewController.h
//  ITM_version_0.0.1
//
//  Created by Ben Bonnet on 6/10/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ProfileProtocol
@required

-(void) doneEditing;

@end


@interface ProfileViewController : UIViewController <UITextFieldDelegate>{
    
    id <ProfileProtocol> _delegate;
}
@property (strong, nonatomic) IBOutlet UILabel *fName;
@property (strong, nonatomic) IBOutlet UILabel *lName;
@property (strong, nonatomic) IBOutlet UILabel *email;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) IBOutlet UIButton *showPasswordBtn;
@property (strong, nonatomic) id <ProfileProtocol> delegate;
- (IBAction)showPassword:(id)sender;


- (IBAction)save:(id)sender;

- (IBAction)cancel:(id)sender;

@end
