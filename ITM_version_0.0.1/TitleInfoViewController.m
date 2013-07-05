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

-(void) handleTap:(UITapGestureRecognizer*)recognizer;//
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
        
        [self.deleteBtn setHidden:NO];
        if(self->_applicationID !=nil){
            [self.viewButton setHidden:NO];
        }else{
            [self.viewButton setHidden:YES];
        }
        
                       // NSLog(@"%f height %f %f",deleteBtn.frame.size.height,self.view.frame.size.height,self.cancelBtn.frame.origin.y );
//        CGRect deleteBtnFrame = CGRectMake(self.view.frame.size.width/2 - deleteBtn.frame.size.width/2, self.view.frame.origin.y, deleteBtn.frame.size.width+20, self.cancelBtn.frame.size.height);
//        deleteBtn.frame = deleteBtnFrame;
//        [self.view addSubview:deleteBtn];
        
       [self.previewImg setImage:self.preview];
        [self.previewImg sizeToFit];
        self.titleTxt.text = self.titleForBuild;
        self.descriptionTxt.text = self.descriptionForBuild;
        self.datePublishedLabel.text = self.datePublished;
        
    }else{
        [self.deleteBtn setHidden:YES];
        [self.previewImg setHidden:YES];
        [self.previewLabel setHidden:YES];
        [self.viewButton setHidden:YES];
        [self.datePublishedTitle setHidden:YES];
        
    }
    
    self.view.backgroundColor = [UIColor colorWithRed:1.0f green:0.93f blue:0.79f alpha:1.0f];
    
    
    
    [self.continueBtn setTitle:actionBtnTitle forState:UIControlStateNormal];
    
    // check to see if the user has seen the message yet
    if(![[[NSUserDefaults standardUserDefaults] valueForKey:@"hasSeenTitle"] isEqualToString:@"YES"]){
        
        NSString*imgName = ([[UIScreen mainScreen] bounds].size.height <= 480.0) ? @"title" : @"title-568";
        UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
        NSLog(@"img name: %f",img.bounds.size.height);
        img.userInteractionEnabled = YES;
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tgr.delegate = self;
       [img addGestureRecognizer:tgr];
        self.infoImgView = img;
        [self.infoImgView setAlpha:0.5f];
        [self.view addSubview:img];
   }
    
    // Do any additional setup after loading the view from its nib.
}

- (void) viewDidLayoutSubviews{
    UIImage *deleteImg = [UIImage imageNamed:@"delete.png"];
    UIImage *deleteStretchedImg = [deleteImg resizableImageWithCapInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)];
    UIButton *newDeleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    newDeleteBtn.layer.cornerRadius = 8.0f;
    [newDeleteBtn setTitle:@"Delete" forState:UIControlStateNormal];
    [newDeleteBtn setImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateNormal];
    [newDeleteBtn setBackgroundImage:deleteStretchedImg forState:UIControlStateNormal];
    [newDeleteBtn setTintColor:[UIColor colorWithRed:0.89 green:0.01 blue:0.25 alpha:1.0]];
    newDeleteBtn.layer.backgroundColor = [[UIColor colorWithRed:0.89 green:0.01 blue:0.25 alpha:1.0] CGColor];
    [newDeleteBtn sizeToFit];
    
    CGRect newDelRec = self.deleteBtn.frame;
    newDeleteBtn.frame= newDelRec;
    [newDeleteBtn addTarget:self action:@selector(deleteBuild:) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteBtn removeFromSuperview];
    self.deleteBtn = nil;
    
    [self.view addSubview:newDeleteBtn];
    self.deleteBtn = newDeleteBtn;
    
    if(self.isNew){
        [self.deleteBtn setHidden:YES];
    }else{
        [self.deleteBtn setHidden:NO];
    }
   
    
    [self.view layoutSubviews];

}

-(void) handleTap:(UITapGestureRecognizer *)recognize{
    [self.infoImgView removeFromSuperview];
    self.infoImgView = nil;
    [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"hasSeenTitle"];
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
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if(textView.text.length < 150 || range.length > 0){
        [textView setBackgroundColor:[UIColor whiteColor]];
        
        return YES;
    }
    [textView setBackgroundColor:[UIColor redColor]];
    return NO;
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

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(textField.text.length < 50 || range.length > 0){
        [textField setBackgroundColor:[UIColor whiteColor]];
        return YES;
    }
    [textField setBackgroundColor:[UIColor redColor]];
    return NO;
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
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"Delete Item?" message:@"This will delete the item from your device, but it will remain on the server" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"delete", nil];
    [deleteAlert show];
}

- (IBAction)viewBuild:(id)sender{
    
    if(self->_applicationID != nil ){
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itmgo.com/ItemViewer.html?id=%@",self->_applicationID]];
        
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void) setAppID:(NSNumber*)num{
    self->_applicationID = num;
}

// handles the delete response if the user chooses to delete the item
-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            [self.delegate userDidDeleteBuildWithID:self.buildID];
            break;
        default:
            break;
    }
}


@end
