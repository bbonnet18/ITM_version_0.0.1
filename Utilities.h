//
//  Utilities.h
//  ITM_v0
//
//  Created by Lauren Bonnet on 10/4/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject

- (NSString*) GetUUIDString;// returns a UUID string for use in screen and image ids
- (BOOL) checkValidString:(NSString*)str;// checks to see if a string is not null, not empty and is an actual string
@end