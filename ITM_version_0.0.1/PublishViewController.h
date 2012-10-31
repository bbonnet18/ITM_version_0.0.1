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
-(void) userDidPublish;// simply verifies to the delegate that the user wants to publish
-(void) userDidCancel;// cancel, don't publish

@end

@interface PublishViewController : UIViewController

@property (nonatomic, strong) id <PublishProtocol> delegate;// so the delegate can be set to enforce these methods
@property (nonatomic, strong) IBOutlet UIButton * publishBtn;
@property (nonatomic, strong) IBOutlet UIButton * cancelBtn;

- (IBAction)cancel:(id)sender;
- (IBAction)publish:(id)sender;
@end
