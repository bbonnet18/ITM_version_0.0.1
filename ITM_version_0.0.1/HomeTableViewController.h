//
//  HomeTableViewController.h
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 10/30/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Build.h"
#import "MainEditorViewController.h"
#import "Utilities.h"
#import "TitleInfoViewController.h"
#import "UIImage+Resize.h"
#import "HomeTableCell.h"

@protocol UploadControl
@required

-(void) stopUpload;// stops the current upload

@end

@interface HomeTableViewController : UITableViewController <NSFetchedResultsControllerDelegate,TitleInfoProtocol, UIAlertViewDelegate, UIGestureRecognizerDelegate>{
    NSFetchedResultsController *_fetched;
    NSManagedObjectContext *_context;
    NSIndexPath* _currentSelection;// reserved for the currently selected item indexPath
    id<UploadControl> _delegate;
}

@property (strong, nonatomic) NSFetchedResultsController *fetched;
@property (strong, nonatomic) NSManagedObjectContext* context;// reference to the moc
@property (strong, nonatomic) IBOutlet HomeTableCell* tblCell;// the custom cell
@property (strong, nonatomic) id<UploadControl> delegate;// delegate to stop uploads
@property (strong, nonatomic) IBOutlet UIImageView *infoImgView;// used to show the overlay
@end
