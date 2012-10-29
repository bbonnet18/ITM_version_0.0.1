//
//  BuildItem.h
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 10/12/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Build;

@interface BuildItem : NSManagedObject

@property (nonatomic, retain) NSString * buildItemID;
@property (nonatomic, retain) NSNumber * orderNumber;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * thumbnailPath;
@property (nonatomic, retain) NSString * mediaPath;
@property (nonatomic, retain) Build *build;

@end
