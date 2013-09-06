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

@property (strong, nonatomic) IBOutlet UIButton *okBtn;
@property (strong, nonatomic) id <ProfileProtocol> delegate;

- (IBAction)ok:(id)sender;



@end
