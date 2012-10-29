//
//  Utilities.m
//  ITM_v0
//
//  Created by Lauren Bonnet on 10/4/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities



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

@end
