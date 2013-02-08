//
//  MainEditorViewController.h
//  ITM_v0
//
//  Created by Lauren Bonnet on 10/5/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Utilities.h"
#import "Build.h"
#import "BuildItem.h"
#import "PreviewImage.h"
#import "ImageEditor.h"
#import "CaptureViewController.h"
#import "PublishViewController.h"


@interface MainEditorViewController : UIViewController <PreviewImageProtocol, UIScrollViewDelegate, ImageEditor, UIAlertViewDelegate,PublishProtocol>{
    
    NSManagedObjectContext *_context;
    NSMutableArray *_orderArray;
    NSString *_buildID;
    NSMutableArray * _previewImageArray;
    NSInteger _previewImageIndex;// used to hold the active item's index in the previewImageArray
}

@property (strong, nonatomic) IBOutlet UIScrollView *scroller;
@property (strong, nonatomic) IBOutlet UIButton *publishBtn;
@property (strong, nonatomic) NSManagedObjectContext* context;// reference to the moc
@property (strong, nonatomic) NSMutableArray *orderArray;// array of build item ids (GUUID), used to populate everything
@property (strong, nonatomic) NSMutableArray* previewImageArray;// holds all our PreviewImage objects
- (void) setBuildItems;// sets all the items in the build so they can be manipulated 
- (void) loadVisiblePages;// loads the pages into the scroll view
- (void) setBuildID:(NSString*)buildID;// provided when the screen is initialized so we can get the build
- (Build*) getBuild;// gets the build based on the build id and returns it
-(BuildItem*) getBuildItem:(NSString*)buildItemID;// gets and returns a build item with buildItemID
-(BuildItem*) createBuildItemWithOrderNumber:(NSNumber*) orderNum;// creates a build item and inserts it into the
// context, returns the build item
//-(UIImage*)getPreviewImage:(NSString*)path;// gets and returns an image for a path
-(IBAction)publish:(id)sender;// attempts to publish the build

@end


