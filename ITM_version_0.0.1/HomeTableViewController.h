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

@interface HomeTableViewController : UITableViewController <NSFetchedResultsControllerDelegate,TitleInfoProtocol>{
    NSFetchedResultsController *_fetched;
    NSManagedObjectContext *_context;
    NSIndexPath* _currentSelection;// reserved for the currently selected item indexPath
}

@property (strong, nonatomic) NSFetchedResultsController *fetched;
@property (strong, nonatomic) NSManagedObjectContext* context;// reference to the moc
@property (strong, nonatomic) IBOutlet HomeTableCell* tblCell;// the custom cell


@end
