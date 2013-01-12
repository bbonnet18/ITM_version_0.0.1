//
//  TitleInfoViewController.m
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 11/15/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import "TitleInfoViewController.h"
#import "Utilities.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>

@interface TitleInfoViewController ()

@end


@implementation TitleInfoViewController
@synthesize titleForBuild = _titleForBuild;
@synthesize descriptionForBuild = _descriptionForBuild;
@synthesize activeView = _activeView;
@synthesize isNew = _isNew;
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
    NSString*actionBtnTitle = (self.isNew) ? @"Continue" : @"OK";
    // add the delete button if it's not new
    if(!self.isNew){
        
        
        UIImage *deleteImg = [UIImage imageNamed:@"delete.png"];
        UIImage *deleteStretchedImg = [deleteImg resizableImageWithCapInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)];
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteBtn addTarget:self action:@selector(deleteBuild:) forControlEvents:UIControlEventTouchUpInside];
        [deleteBtn setTitle:@"Delete" forState:UIControlStateNormal];
        [deleteBtn setImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateNormal];
        [deleteBtn setBackgroundImage:deleteStretchedImg forState:UIControlStateNormal];
        [deleteBtn sizeToFit];
                NSLog(@"%f",deleteBtn.frame.size.height);
        CGRect deleteBtnFrame = CGRectMake(self.view.frame.size.width/2 - deleteBtn.frame.size.width/2, self.cancelBtn.frame.origin.y - 88.0, deleteBtn.frame.size.width+20, deleteBtn.frame.size.height);
        deleteBtn.frame = deleteBtnFrame;
        [self.view addSubview:deleteBtn];
        self.statusTxt.text = [self statusTxtForBuildStatus:self.status];
        [self.statusLabel setTextAlignment:NSTextAlignmentLeft];
        [self.statusImg setImage:[self statusImgForBuildStatus:self.status]];
       [self.previewImg setImage:self.preview];
        [self.previewImg sizeToFit];
        self.titleTxt.text = self.titleForBuild;
        self.descriptionTxt.text = self.descriptionForBuild;
        
    }else{
        [self.statusImg setHidden:YES];
        [self.statusTxt setHidden:YES];
        [self.statusLabel setHidden:YES]; 
        [self.previewImg setHidden:YES];
        [self.previewLabel setHidden:YES];
        
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
    [self.continueBtn setTitle:actionBtnTitle forState:UIControlStateNormal];
    
    // Do any additional setup after loading the view from its nib.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if(self.activeView != nil){// resign the responder if the view is active
        [self.activeView resignFirstResponder];
    }
    return YES;
}

-(BOOL) textViewShouldEndEditing:(UITextView *)textView{
    [self doneEditingAction:textView];
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    [self doneEditingAction:textView];
}

-(void) textViewDidBeginEditing:(UITextView *)textView{
    self.activeView = textView;
    [self setupDoneBtn];
    
}

- (void) setupDoneBtn{
 // set it up so it has an image and 
    self.doneBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage * doneBtnIcon = [UIImage imageNamed:@"TrustedCheckmark.png"];
    [self.doneBtn setImage:doneBtnIcon forState:UIControlStateNormal];
    [self.doneBtn setTitle:@" Done" forState:UIControlStateNormal];
    [self.doneBtn sizeToFit];
        
    CGRect btnRec = CGRectMake(self.descriptionTxt.frame.origin.x + self.descriptionTxt.frame.size.width - self.doneBtn.frame.size.width, self.descriptionTxt.frame.origin.y - self.doneBtn.frame.size.height + 10.0, self.doneBtn.frame.size.width, self.doneBtn.frame.size.height - 10.0);
    
    [self.doneBtn setFrame:btnRec];
    [self.doneBtn addTarget:self action:@selector(doneEditingAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.doneBtn];
    
}

- (void)doneEditingAction:(id)sender
{
	// finish typing text/dismiss the keyboard by removing it as the first responder
    [self.activeView resignFirstResponder];
	self.activeView = nil;
    [self.doneBtn removeFromSuperview];
    
}
// returns the status text to show the user based on the status of the build - edit/view/uploading
-(NSString*) statusTxtForBuildStatus:(NSString*) buildStatus{
    NSString* status = nil;
    
    if([buildStatus isEqualToString:@"edit"]){
        status = @"Editable - you can edit this item and then post it to your users.";
    }else if([buildStatus isEqualToString:@"uploading"]){
        status = @"Uploading - this item is uploading, stop the upload to continue editing.";
    }else{
        status = @"View - this item has been uploaded, you can view the item.";
    }
    return status;
}

-(UIImage*) statusImgForBuildStatus:(NSString*) buildStatus{
    
    UIImage* statusImg = nil;
    
    if([buildStatus isEqualToString:@"edit"]){
        statusImg = [UIImage imageNamed:@"eye-open.png"];
    }else if([buildStatus isEqualToString:@"uploading"]){
        statusImg = [UIImage imageNamed:@"eye-close.png"];
    }else{
        statusImg = [UIImage imageNamed:@"pencil.png"];
    }
    return statusImg;
    
}
// cancels the build process and dismissess the view controller
- (IBAction)cancelBuild:(id)sender{
    [self.delegate userDidCancel];
}

- (IBAction)continueToEdit:(id)sender{
    
    if([[Utilities sharedInstance] checkValidString:self.titleTxt.text]  && [[Utilities sharedInstance] checkValidString:self.descriptionTxt.text]){
        [self.delegate userDidAddBuildWithTitle:self.titleTxt.text andDescription:self.descriptionTxt.text isNew:self.isNew];
    }
    
}

- (IBAction)deleteBuild:(id)sender{
    [self.delegate userDidDeleteBuildWithID:self.buildID];
}





@end
