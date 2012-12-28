//
//  Build.h
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 12/17/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BuildItem;

@interface Build : NSManagedObject

@property (nonatomic, retain) NSString * buildDescription;
@property (nonatomic, retain) NSString * buildID;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * context;
@property (nonatomic, retain) NSSet *buildItems;
@end

@interface Build (CoreDataGeneratedAccessors)

- (void)addBuildItemsObject:(BuildItem *)value;
- (void)removeBuildItemsObject:(BuildItem *)value;
- (void)addBuildItems:(NSSet *)values;
- (void)removeBuildItems:(NSSet *)values;

@end
