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
-(BOOL) isValidUserName:(NSString*)userName;
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
    
    self.firstName.text = [userDic valueForKey:@"firstname"];
    self.lastName.text = [userDic valueForKey:@"lastname"];
    

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
    
    if(![self.firstName.text isEqualToString:@""] && ![self.lastName.text isEqualToString:@""] && [self isValidEmail:self.email.text] && [self isValidUserName:self.userName.text] && [self isValidPassword:self.password.text]){
        
        NSMutableDictionary *userDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.firstName.text,@"fName",self.lastName.text, @"lName",self.email.text,@"email",self.userName.text,@"userName",self.password.text,@"password", nil];

            
            [[ITMServiceClient sharedInstance] setParameterEncoding:AFJSONParameterEncoding];
            [[ITMServiceClient sharedInstance] JSONUSERCommandWithParameters: userDic onCompletion:^(NSDictionary *json) {
                
                if([[json valueForKey:@"userName"] isEqualToString:self.userName.text]){
                    
                    [[NSUserDefaults standardUserDefaults] setValue:[json valueForKey:@"fName"] forKey:@"firstName"];
                    [[NSUserDefaults standardUserDefaults] setValue:[json valueForKey:@"lName"] forKey:@"lastName"];
                    [[NSUserDefaults standardUserDefaults] setValue:[json valueForKey:@"email"] forKey:@"email"];
                                  
//                NSURLProtectionSpace *protection = [[NSURLProtectionSpace alloc] initWithHost:@"itmgo.com" port:0 protocol:@"http" realm:nil authenticationMethod:NSURLAuthenticationMethodHTTPBasic];
//                    
//                    NSURLCredential *newCreds = [NSURLCredential credentialWithUser:self.userName.text password:self.password.text persistence: NSURLCredentialPersistencePermanent];
//                    
//               [[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:newCreds forProtectionSpace:protection];
                    [[NSUserDefaults standardUserDefaults] setValue:self.userName.text forKey:@"userName"];
                    [[NSUserDefaults standardUserDefaults] setValue:self.password.text forKey:@"password"];

                [self.delegate userDidGetStarted:[NSDictionary dictionaryWithObjectsAndKeys:self.firstName.text,@"firstName",self.lastName.text,@"lastName",self.email.text,@"email", nil]];
                    
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

/*
 - (NSData*) generateJSONFromBuild:(Build*)b withItems:(NSArray*)buildItems andEmails:(NSArray*)emails{
 // get the date
 NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
 [formatter setDateStyle:NSDateFormatterMediumStyle];
 [formatter setTimeStyle:NSDateFormatterNoStyle];
 [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
 NSString *creationDateString = [formatter stringFromDate:b.dateCreated];
 // this builds a hierarchy with the main node being the build and the items string data making up the rest
 NSDictionary *metaDataDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:creationDateString, @"buildCreationDate",nil];
 
 // initialize the dictionary that we'll use to add the items to
 NSMutableDictionary *buildDictionary = [[NSMutableDictionary alloc] initWithDictionary:metaDataDictionary];
 // create an array to store the items
 NSMutableArray * itemArray = [[NSMutableArray alloc] init];
 // roll through the items and extract what's needed and add each to the array
 for (BuildItem * b in buildItems) {
 NSString * screenTitle = b.title;
 NSString * screenID = b.buildItemIDString;
 NSString * itemType = b.type;
 NSString * screenText = b.caption;
 NSDictionary *itemDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:screenTitle,@"screenTitle",screenID,@"screenID",itemType,@"itemType",screenText,@"screenText", nil];
 [itemArray addObject:itemDictionary];
 
 }
 // add the item array to the buildDictionary
 b.applicationID = (b.applicationID != nil) ? b.applicationID : 0;
 
 if(b.applicationID == nil){
 b.applicationID = [NSNumber numberWithInt:0];
 }
 NSLog(@"APP ID IS: %@",b.applicationID);
 [buildDictionary setObject:b.applicationID forKey:@"applicationID"];
 [buildDictionary setObject:@"" forKey:@"manifestPath"];
 [buildDictionary setObject:itemArray forKey:@"buildItems"];
 //[buildDictionary setObject:emails forKey:@"distroEmails"];
 [buildDictionary setObject:b.buildID forKey:@"buildID"];
 [buildDictionary setObject:b.buildDescription forKey:@"tags"];
 [buildDictionary setObject:b.title forKey:@"title"];
 NSString *email = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] valueForKey:@"email"];
 [buildDictionary setObject:email forKey:@"email"];
 NSError *error;
 // create json data
 NSData *buildData = [NSJSONSerialization dataWithJSONObject:buildDictionary options:0 error:&error];
 
 NSString *stringData = [[NSString alloc] initWithData:buildData encoding:NSUTF8StringEncoding];
 
 if(!error){
 NSLog(@"jsonData: %@",stringData );
 return buildData;
 }else {
 return nil;
 }
 
 }

 */


