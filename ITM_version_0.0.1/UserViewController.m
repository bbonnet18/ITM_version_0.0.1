//
//  UserViewController.m
//  ITM_version_0.0.1
//
//  Created by Ben Bonnet on 5/15/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

#import "UserViewController.h"

@interface UserViewController ()
-(BOOL) isValidEmail:(NSString *)emailAdd;// checks for valid emails
@end

@implementation UserViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (IBAction)getStarted:(id)sender {
    
    if(![self.firstName.text isEqualToString:@""] && ![self.lastName.text isEqualToString:@""] && [self isValidEmail:self.email.text]){
        
        [self.delegate userDidGetStarted:[NSDictionary dictionaryWithObjectsAndKeys:self.firstName.text,@"firstName",self.lastName.text,@"lastName",self.email.text,@"email", nil]];
    }
    
}

-(BOOL) isValidEmail:(NSString *)emailAdd{
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    
    if (![emailTest evaluateWithObject:emailAdd] == NO){
        return YES;
    }
    return NO;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
