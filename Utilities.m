//
//  Utilities.m
//  ITM_v0
//
//  Created by Lauren Bonnet on 10/4/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>

@implementation Utilities

// creation of singleton
+(Utilities*)sharedInstance{
    static Utilities *sharedInstance = nil;
    static dispatch_once_t oncePredicate;// use the one time dispatch queue to initialize the shared instance// this will only run one time
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];//
    });
    
    return sharedInstance;
}

- (NSString*) GetUUIDString{
    CFUUIDRef uid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uid);
    CFRelease(uid);

    return (__bridge NSString*)string;
}

-(BOOL) checkValidString:(NSString*) str{
    BOOL isValid = YES;// will change to no if any part is invalid
    if(![str isKindOfClass:[NSString class]]){
        isValid = NO;
        return isValid;
    }
    if([str isEqual:[NSNull null]]){
        isValid = NO;
        return isValid;
    }
    if([str isEqualToString:@""]){
        isValid = NO;
        return isValid;
    }
    
    return isValid;
}

- (NSString*) getTimeStamp:(NSDate*)dateForString{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];// want short time
    [formatter setDateStyle:NSDateFormatterMediumStyle];// just want the months and the day
    NSString* dateString = [formatter stringFromDate:dateForString];
    return dateString;
    //    self.timeStampTxt.text = dateString;
    //    [self.buildItemVals setValue:creationDateString forKey:@"timeStamp"];
    
}

+(void) storeUserInformation:(NSDictionary *)userInfo{
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"user"] == nil){
        NSDictionary *user = userInfo[@"user"];
        
        NSDictionary *contact = user[@"contact"];
        NSString *primaryEmail = nil;
        NSDictionary *emailAddresses = contact[@"email_addresses"];
        for (NSDictionary* email in emailAddresses) {
            if([email[@"type"] isEqualToString:@"primary"]){
                primaryEmail = email[@"address"];
            }
        }
        
        NSString *firstName = user[@"first_name"];
        NSString *lastName = user[@"last_name"];
        
        NSDictionary *allUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:primaryEmail,@"email",firstName,@"firstName",lastName,@"lastName",user,@"fullUserInfo", nil];
        
        [[NSUserDefaults standardUserDefaults] setObject:allUserInfo forKey:@"user"];

    }
        
}

//-(UIButton*) createRoundedCustomBtnWithImage:(UIImage *)btnImg{
//    UIColor *btnTintColor = [UIColor colorWithRed:1.0 green:0.93 blue:0.79 alpha:1.0];
//
//    
//    UIButton *newBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    newBtn.backgroundColor = btnTintColor;
//    [newBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
//    [newBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
//   newBtn.layer.borderColor = [[UIColor blackColor] CGColor];
//    newBtn.layer.borderWidth = 0.5f;
//    newBtn.layer.cornerRadius = 10.0f;
//    [newBtn setImage:btnImg forState:UIControlStateNormal];
//    [newBtn sizeToFit];
//    newBtn.tintColor = btnTintColor;
//    newBtn.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
//    
//    return newBtn;
//}

@end
