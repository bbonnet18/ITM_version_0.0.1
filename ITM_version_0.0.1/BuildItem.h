//
//  BuildItem.h
//  ITM_version_0.0.1
//
//  Created by Ben Bonnet on 3/24/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Build;

@interface BuildItem : NSManagedObject

@property (nonatomic, retain) NSString * buildItemIDString;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSNumber * imageRotation;
@property (nonatomic, retain) NSString * mediaPath;
@property (nonatomic, retain) NSNumber * orderNumber;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * thumbnailPath;
@property (nonatomic, retain) NSString * timeStamp;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * buildItemID;
@property (nonatomic, retain) Build *build;

@end
