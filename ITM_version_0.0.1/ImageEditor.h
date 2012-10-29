//
//  ImageEditor.h
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 10/15/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageEditor
// provides the delegate with the changes dictionary when user is done editing
- (void) didEditItemWithDictionary:(NSDictionary*) changes;
- (void) didCancelEditProcess;// cancels the editing process with no changes
@end
