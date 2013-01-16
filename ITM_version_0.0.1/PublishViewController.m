//
//  PublishViewController.m
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 10/29/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import "PublishViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface PublishViewController ()

-(NSArray*) emailsToShare;// gets the email addresses that were entered and sends them with the publish message
-(BOOL)isValidEmail:(NSString*) emailAdd;// validates whether a string is a valid email address
@end

@implementation PublishViewController

@synthesize doneBtn, emailsTxt, infoTxt, publishBtn, cancelBtn;
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
    
    self.emailsTxt.layer.borderColor = [[UIColor colorWithRed:0.09 green:0.49 blue:0.57 alpha:1.0] CGColor];
    self.emailsTxt.layer.borderWidth = 2.0f;
    self.emailsTxt.layer.cornerRadius = 5.0f;
    
    UIButton *canelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    canelBtn.layer.backgroundColor = [[UIColor colorWithRed:0.89 green:0.01 blue:0.25 alpha:1.0] CGColor];
    [canelBtn setTitle:@" Cancel " forState:UIControlStateNormal];
    canelBtn.layer.borderWidth = 0.5f;
    canelBtn.layer.cornerRadius = 8.0f;
    canelBtn.tintColor = [UIColor colorWithRed:0.89 green:0.01 blue:0.25 alpha:1.0];
    [canelBtn sizeToFit];
    
    CGRect cancelBtnRect = CGRectMake(self.view.frame.size.width/2, self.cancelBtn.frame.origin.y, canelBtn.frame.size.width + 20.0, canelBtn.frame.size.height + 20.0);
    canelBtn.frame = cancelBtnRect;
    cancelBtnRect = CGRectMake(cancelBtnRect.origin.x - (canelBtn.frame.size.width / 2), cancelBtnRect.origin.y, cancelBtnRect.size.width, cancelBtnRect.size.height);
    canelBtn.frame = cancelBtnRect;
    [canelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn removeFromSuperview];
    self.cancelBtn = canelBtn;
    [self.view addSubview:self.cancelBtn];
    //self.infoTxt.backgroundColor = [UIColor blueColor];
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

- (IBAction)publish:(id)sender{
    NSArray *emailsToShare = [self emailsToShare];
    [emailsToShare enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"email: %@ - index: %i",obj,idx);
    }];
    
    [self.delegate userDidPublishWithEmails:[self emailsToShare]];
    
}

- (IBAction)cancel:(id)sender{
    [self.delegate userDidCancel];
}
// process the strings to make sure they are valid email strings, etc. return an array of them
-(NSArray*) emailsToShare{
    NSMutableArray* emails = nil;
    
    if(![self.emailsTxt.text isEqualToString:@""]){
        NSArray * emailEntries = [self.emailsTxt.text componentsSeparatedByString:@"," ];
        emails = [[NSMutableArray alloc] initWithCapacity:[emailEntries count]];
        for (NSString *email in emailEntries) {
            NSString *trimmed = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];// trim the string
            if([self isValidEmail:trimmed]){
                [emails addObject:trimmed];// add it if it's valid
            }else{
                [[[UIAlertView alloc] initWithTitle:@"Error - Emails" message:@"There is an error in one or more of your email addresses" delegate: nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                return nil;
            }
        }
    }
    return [NSArray arrayWithArray:emails];
}

-(BOOL) isValidEmail:(NSString *)emailAdd{
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    
    if (![emailTest evaluateWithObject:emailAdd] == NO){
        return YES;
    }
    return NO;
}


#pragma uitextviewelegate methods

-(void)textViewDidBeginEditing:(UITextView *)textView{
    self.activeView = textView;
    [self setupDoneBtn];
}

-(void) textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}
#pragma to handle when user is done entering emails

- (void) setupDoneBtn{
    // set it up so it has an image and
    self.doneBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage * doneBtnIcon = [UIImage imageNamed:@"TrustedCheckmark.png"];
    [self.doneBtn setImage:doneBtnIcon forState:UIControlStateNormal];
    [self.doneBtn setTitle:@" Done" forState:UIControlStateNormal];
    [self.doneBtn sizeToFit];
    
    CGRect btnRec = CGRectMake(self.emailsTxt.frame.origin.x + self.emailsTxt.frame.size.width - self.doneBtn.frame.size.width, self.emailsTxt.frame.origin.y - self.doneBtn.frame.size.height + 10.0, self.doneBtn.frame.size.width, self.doneBtn.frame.size.height - 10.0);
    
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


@end
