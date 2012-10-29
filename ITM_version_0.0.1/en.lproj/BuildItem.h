//
//  BuildItem.h
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 10/23/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Build;

@interface BuildItem : NSManagedObject

@property (nonatomic, retain) NSString * buildItemID;
@property (nonatomic, retain) NSString * mediaPath;
@property (nonatomic, retain) NSNumber * orderNumber;
@property (nonatomic, retain) NSString * thumbnailPath;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSString * timeStamp;
@property (nonatomic, retain) Build *build;

@end
