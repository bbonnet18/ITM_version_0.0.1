//
//  PublishViewController.h
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 10/29/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  PublishProtocol
@required
-(void) userDidPublishWithEmails:(NSArray*) emails;// simply verifies to the delegate that the user wants to publish
-(void) userDidCancel;// cancel, don't publish

@end

@interface PublishViewController : UIViewController <UITextViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) id <PublishProtocol> delegate;// so the delegate can be set to enforce these methods
@property (nonatomic, strong) IBOutlet UIButton * publishBtn;
@property (nonatomic, strong) IBOutlet UIButton * cancelBtn;
@property (nonatomic,strong) IBOutlet UITextView * infoTxt;
@property (nonatomic, strong) UITextView *activeView;// used to keep track 
@property (nonatomic, strong) IBOutlet UITextView *emailsTxt;// holds emails for people to send to
@property (strong, nonatomic) IBOutlet UIButton *doneBtn; // used when editing the emails
@property (nonatomic, strong) NSString *titleLabelStr;// actual title label
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;// used to show whether this is a publish or a republish
@property (nonatomic, strong) NSString *publishDateStr;// actual publish date string
@property (nonatomic, strong) IBOutlet UILabel *publishDateLabel;// used to show the last published date if there is one

- (IBAction)cancel:(id)sender;
- (IBAction)publish:(id)sender;
@end
