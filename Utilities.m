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

-(UIButton*) createRoundedCustomBtnWithImage:(UIImage *)btnImg{
    UIColor *btnTintColor = [UIColor colorWithRed:1.0 green:0.93 blue:0.79 alpha:1.0];

    
    UIButton *newBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    newBtn.backgroundColor = btnTintColor;
    [newBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [newBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
   newBtn.layer.borderColor = [[UIColor blackColor] CGColor];
    newBtn.layer.borderWidth = 0.5f;
    newBtn.layer.cornerRadius = 10.0f;
    [newBtn setImage:btnImg forState:UIControlStateNormal];
    [newBtn sizeToFit];
    newBtn.tintColor = btnTintColor;
    newBtn.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
    
    return newBtn;
}

@end
