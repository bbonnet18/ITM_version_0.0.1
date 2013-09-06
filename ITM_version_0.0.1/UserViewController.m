//
//  UserViewController.m
//  ITM_version_0.0.1
//
//  Created by Ben Bonnet on 5/15/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

#import "UserViewController.h"
#import "ITMServiceClient.h"

@interface UserViewController ()
-(BOOL) isValidEmail:(NSString *)emailAdd;// checks for valid emails
-(BOOL) isValidPassword:(NSString*)password;
-(NSData*) jsonDataForUser:(NSDictionary*)userData;// gets data from the user's info
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
    NSDictionary *userDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    
    self.firstName.text = [userDic valueForKey:@"firstName"];
    self.lastName.text = [userDic valueForKey:@"lastName"];
    self.email.text = [userDic valueForKey:@"email"];
    

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
    
    if(![self.firstName.text isEqualToString:@""] && ![self.lastName.text isEqualToString:@""] && [self isValidEmail:self.email.text] && [self isValidPassword:self.password.text]){
        
        NSMutableDictionary *userDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.firstName.text,@"fName",self.lastName.text, @"lName",self.email.text,@"email",self.email.text,@"userName",self.password.text,@"password", nil];

            
            [[ITMServiceClient sharedInstance] setParameterEncoding:AFJSONParameterEncoding];
            [[ITMServiceClient sharedInstance] JSONUSERCommandWithParameters: userDic onCompletion:^(NSDictionary *json) {
                // completed successfully
                if([[json valueForKey:@"email"] isEqualToString:self.email.text]){
                    

                    [self.delegate userDidGetStarted:userDic];
                    
                }else{
                    UIAlertView *alertNoUser = [[UIAlertView alloc] initWithTitle:@"No user created, please try again. If this persists, contact bonnet_ben@bah.com" message:@"unable to create user" delegate:nil cancelButtonTitle:@"try again" otherButtonTitles: nil];
                    [alertNoUser show];
                }

                
            }];
       
        
    }else{
        UIAlertView *check = [[UIAlertView alloc] initWithTitle:@"Missing some data" message:@"Enter a valid value for each." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [check show];
    }
        
        
        
        
        
        
        

    
}

-(BOOL) isValidEmail:(NSString *)emailAdd{
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    
    NSRange r = [emailAdd rangeOfString:@"bah.com"];
    if(r.length == 0){
        return NO;
    }
    
    if (![emailTest evaluateWithObject:emailAdd] == NO){
        return YES;
    }
    return NO;
}

-(BOOL) isValidPassword:(NSString *)password{
    if([password length] >= 8 && [password length] < 16)
        return YES;
    return NO;

}

-(BOOL) isValidUserName:(NSString *)userName{
    if([userName length] >= 8 && [userName length] < 16)
        return YES;
    return NO;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(NSData*)jsonDataForUser:(NSDictionary *)userData{
    
}

@end




