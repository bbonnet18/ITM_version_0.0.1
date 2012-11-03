//
//  HomeTableViewController.m
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 10/30/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import "HomeTableViewController.h"

@interface HomeTableViewController ()

@end

@implementation HomeTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // add observer for uploaded item
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadComplete:) name:@"UploadComplete" object:nil];
    
    UIBarButtonItem* addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewBuildAndPopulate:)];
    self.navigationItem.rightBarButtonItem = addItem;
    
    NSError *error;
    if(![self.fetched performFetch:&error]){
        NSLog(@"ERROR: %@", error);
    }

}

- (void) viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];// reload to refresh all the data in the list
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) uploadComplete:(NSNotification*) note{
    [self.tableView reloadData];
}

// shows the build that was selected in the table
- (void) showBuild:(id)sender event:(id) event{
    UIButton *thisBtn = (UIButton*)sender;//reference to the button
    NSIndexPath *indexPath = nil;// instantiate the indexPath
    UIView *parent = [thisBtn superview]; // get the parent
    if([parent isKindOfClass:[UITableViewCell class]]){// check to see if the parent is a UITableViewCell
        UITableViewCell *cell = (UITableViewCell*)parent;// if so, get the cell
        indexPath = [self.tableView indexPathForCell:cell];// else get the index path
    }
    if(indexPath != nil){
        Build *b = [self.fetched objectAtIndexPath:indexPath];// get the build
        MainEditorViewController *bv = [[MainEditorViewController alloc] initWithNibName:@"MainEditorViewController" bundle:[NSBundle mainBundle]];
        [bv setBuildID:b.buildID];
        bv.context = self.context;// assign the context
        [self.navigationController pushViewController:bv animated:YES];
    }
}

- (void) addNewBuildAndPopulate:(id)sender{
    Build *newBuild = (Build*) [NSEntityDescription insertNewObjectForEntityForName:@"Build" inManagedObjectContext:self.context];
    
    Utilities *u = [[Utilities alloc] init];
    
    NSDate *today = [NSDate date];
    newBuild.dateCreated = today;
    newBuild.buildDescription = @"Type in your description";
    NSString *newBuildID = [u GetUUIDString];
    newBuild.buildID = newBuildID;
    newBuild.status = @"edit";
    newBuild.title = @"New Event";
    
    NSError *err = nil;
    
    if(![self.context save:&err]){
        NSLog(@"error creating the test build object: %@", [err localizedFailureReason]);
    }else{
        
        MainEditorViewController *bv = [[MainEditorViewController alloc] initWithNibName:@"MainEditorViewController" bundle:[NSBundle mainBundle]];
        [bv setBuildID:newBuild.buildID];
        bv.context = self.context;// assign the context
        [self.navigationController pushViewController:bv animated:YES];
    }

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
     return [self.fetched.sections count];// should always be 1
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetched sections] objectAtIndex:section];// get the number of objects in the section from the sectionInfo data
    
    return [sectionInfo numberOfObjects];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Build *b = [self.fetched objectAtIndexPath:indexPath];// get the group that corresponds with this index
    
    cell.textLabel.text = b.title;
    
    UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [actionBtn setTitle:b.status forState:UIControlStateNormal];
    [actionBtn addTarget:self action:@selector(showBuild:event:) forControlEvents:UIControlEventTouchUpInside];
    actionBtn.frame = CGRectMake(0.0, 0.0, 60.0, 25.0);
    cell.accessoryView = actionBtn;
    
    return cell;

    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     
     MainEditorViewController *me = [[MainEditorViewController alloc] initWithNibName:@"MainEditorViewController" bundle:nil];
     me.context = self.managedObjectContext;
     
     NSString* newBuildID = [self createTestData];
     [me setBuildID:newBuildID];

     
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - NSFetchedResultsController delegate methods
// this is very important, because it instantiates the fetched object and performs the initial fetch
- (NSFetchedResultsController*) fetched{
    
    if(_fetched != nil){
        return _fetched;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Build" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:YES];

    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    self.fetched = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    self.fetched.delegate = self;
    return _fetched;
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView cellForRowAtIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

- (void)dealloc{
    self.fetched = nil;// have to call this here because you are passing around the same context to multiple controllers. Other controllers that add data will attempt to update data on this object because the fetechedResultsControllers are all tied to the same context. If this view has been deallocated, it will cause an error if the fetchedResultsController receives a message to update it's data
}


@end
