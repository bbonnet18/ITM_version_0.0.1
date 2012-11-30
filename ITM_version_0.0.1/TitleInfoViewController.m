//
//  TitleInfoViewController.m
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 11/15/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import "TitleInfoViewController.h"
#import "Utilities.h"
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
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [deleteBtn addTarget:self action:@selector(deleteBuild:) forControlEvents:UIControlEventTouchUpInside];
        [deleteBtn setTitle:@"Delete" forState:UIControlStateNormal];
        [deleteBtn sizeToFit];
        
        CGRect deleteBtnFrame = CGRectMake(self.view.frame.size.width/2 - deleteBtn.frame.size.width/2, self.cancelBtn.frame.origin.y, deleteBtn.frame.size.width, deleteBtn.frame.size.height);
        deleteBtn.frame = deleteBtnFrame;
        [self.view addSubview:deleteBtn];
    }
    
    [self.continueBtn setTitle:actionBtnTitle forState:UIControlStateNormal];

    
    
    
    self.titleTxt.text = self.titleForBuild;
    self.descriptionTxt.text = self.descriptionForBuild;
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
    return YES;
}

-(BOOL) textViewShouldEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
}

-(void) textViewDidBeginEditing:(UITextView *)textView{
    self.activeView = textView;
    [self setupDoneBtn];
    
}

- (void) setupDoneBtn{
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    [doneBtn sizeToFit];
    CGRect descRec = self.descriptionTxt.frame;
    descRec.origin.x = descRec.origin.x + descRec.size.width - doneBtn.frame.size.width;
    descRec.origin.y = descRec.origin.y - doneBtn.frame.size.height;
    descRec.size.width = doneBtn.frame.size.width;
    descRec.size.height = doneBtn.frame.size.height;
    doneBtn.frame = descRec;
    [doneBtn addTarget:self action:@selector(doneEditingAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneBtn];
}

- (void)doneEditingAction:(id)sender
{
	// finish typing text/dismiss the keyboard by removing it as the first responder
    [self.activeView resignFirstResponder];
	self.activeView = nil;
    UIButton *b =  (UIButton*) sender;
    [b removeFromSuperview];
}
// cancels the build process and dismissess the view controller
- (IBAction)cancelBuild:(id)sender{
    [self.delegate userDidCancel];
}

- (IBAction)continueToEdit:(id)sender{
    Utilities *u = [[Utilities alloc] init];
    
    if([u checkValidString:self.titleTxt.text]  && [u checkValidString:self.descriptionTxt.text]){
        [self.delegate userDidAddBuildWithTitle:self.titleTxt.text andDescription:self.descriptionTxt.text isNew:self.isNew];
    }
    
}

- (IBAction)deleteBuild:(id)sender{
    [self.delegate userDidDeleteBuildWithID:self.buildID];
}


@end
