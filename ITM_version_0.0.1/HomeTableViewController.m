//
//  HomeTableViewController.m
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 10/30/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import "HomeTableViewController.h"
#import "HomeTableCell.h"

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

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.title = @"Captures";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITableViewHeaderFooterView *hv = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
//    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
//    UIImage* bgImg = [UIImage imageNamed:@"mysteriousblue-300x115.jpg"];
//    bgView.image = bgImg;
//    hv.backgroundView = bgView;
    hv.backgroundColor = [UIColor lightGrayColor];
    UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.tableView.frame.size.width/2, 30)];
    l.text = @"Get Started";
    [hv.contentView addSubview:l];
    //self.tableView.tableHeaderView = hv;
   
    // add observer for uploaded item
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadComplete:) name:@"UploadComplete" object:nil];
    UIImage* addNewBtn = [UIImage imageNamed:@"addcontactpressed.png"];
    
    UIButton* newBuild = [UIButton buttonWithType:UIButtonTypeCustom];
    newBuild.frame = CGRectMake(0, 0, 29.0,29.0);
    [newBuild setBackgroundImage:addNewBtn forState:UIControlStateNormal];
    
    [newBuild addTarget:self action:@selector(addNewBuild:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem *addNew = [[UIBarButtonItem alloc] initWithCustomView:newBuild];// add the new button itself
    
    self.navigationItem.rightBarButtonItem = addNew;
    // register the nib so we can load our custom tableviewcell
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeTableCell" bundle:nil] forCellReuseIdentifier:@"HomeCell"];
       
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
        indexPath = [self.tableView indexPathForCell:cell];// get the index path
    }
    if(indexPath != nil){
        Build *b = [self.fetched objectAtIndexPath:indexPath];// get the build
        MainEditorViewController *bv = [[MainEditorViewController alloc] initWithNibName:@"MainEditorViewController" bundle:[NSBundle mainBundle]];
        [bv setBuildID:b.buildID];
        bv.title = @"Edit";
        bv.context = self.context;// assign the context
        [self.navigationController pushViewController:bv animated:YES];
    }
}
// adds a new build with no info because it's new
- (void) addNewBuild:(id)sender{
    TitleInfoViewController *tv = [[TitleInfoViewController alloc] initWithNibName:@"TitleInfoViewController" bundle:[NSBundle mainBundle]];
    tv.delegate = self;
    tv.isNew = YES;
    [self presentViewController:tv animated:YES completion:^{
        
    }];
}
// shows the build info screen populated and allows you to delete it. 
- (void) showBuildInfo:(id)sender{
    UIButton *thisBtn = (UIButton*)sender;//reference to the button
    NSIndexPath *indexPath = nil;// instantiate the indexPath
    UIView *parent = [thisBtn superview]; // get the parent
    if([parent isKindOfClass:[UITableViewCell class]]){// check to see if the parent is a UITableViewCell
        UITableViewCell *cell = (UITableViewCell*)parent;// if so, get the cell
        indexPath = [self.tableView indexPathForCell:cell];// get the index path
        
    }
    if(indexPath != nil){
        self->_currentSelection = indexPath;// set the current selection
        Build *b = [self.fetched objectAtIndexPath:indexPath];// get the build
        
        TitleInfoViewController* ti = [[TitleInfoViewController alloc] initWithNibName:@"TitleInfoViewController" bundle:[NSBundle mainBundle]];
        NSLog(@"title %@",b.title);
        ti.titleForBuild = b.title;
        ti.delegate = self;
        ti.descriptionForBuild = b.buildDescription;
        ti.isNew = NO;
        ti.buildID = b.buildID;
        ti.preview = [self getBuildItemPreview:b withSize:100 andCorner:8];
        [self presentViewController:ti animated:YES completion:^{
            
        }];
    }

    
}

- (void) addNewBuildWithTitle:(NSString*)title andDescription:(NSString*)description {
    Build *newBuild = (Build*) [NSEntityDescription insertNewObjectForEntityForName:@"Build" inManagedObjectContext:self.context];
    
    Utilities *u = [[Utilities alloc] init];
    
    NSDate *today = [NSDate date];
    newBuild.dateCreated = today;
    newBuild.buildDescription = description;
    NSString *newBuildID = [u GetUUIDString];
    newBuild.buildID = newBuildID;
    newBuild.status = @"edit";
    newBuild.title = title;
    
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

- (void) deleteBuild:(id)sender{
    UIButton *thisBtn = (UIButton*)sender;//reference to the button
    NSIndexPath *indexPath = nil;// instantiate the indexPath
    UIView *parent = [thisBtn superview]; // get the parent
    if([parent isKindOfClass:[UITableViewCell class]]){// check to see if the parent is a UITableViewCell
        UITableViewCell *cell = (UITableViewCell*)parent;// if so, get the cell
        indexPath = [self.tableView indexPathForCell:cell];// get the index path
    }
    if(indexPath != nil){
        Build *b = [self.fetched objectAtIndexPath:indexPath];// get the build
        [self.context deleteObject:b];
        NSError *err = nil;
        
        [self.context save:&err];
        if(err!=nil){
            NSLog(@"could not delete the build");
        }else{
            [self.tableView reloadData];
        }
    }
}

- (void) deletBuildWithBuildID:(NSString*)buildID{
    NSEntityDescription *desc = [NSEntityDescription entityForName:@"Build" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:desc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"buildID == %@",buildID];
    [request setPredicate:predicate];
    NSError *error = nil;
    
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    if(!error){
        Build* deleteObj = (Build*)[results objectAtIndex:0];
        [self.context deleteObject:deleteObj];
        NSError* err = nil;
        [self.context save:&err];
        
        if(err){
            NSLog(@"DELETE Failed");
        }
    }else{
        NSLog(@"Exception : %@",[error localizedFailureReason]);
    }
}

#pragma mark - TitleInfoProtocol methods

-(void) userDidAddBuildWithTitle:(NSString *)title andDescription:(NSString *)description isNew:(BOOL) buildIsNew{// if it's new, then add and edit, if it's not, then simply dismiss
    if(buildIsNew){
        [self dismissViewControllerAnimated:YES completion:^{
            [self addNewBuildWithTitle:title andDescription:description];
        }];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            
            Build *b = [self.fetched objectAtIndexPath:self->_currentSelection];// get the build
            b.title = title;
            b.buildDescription = description;
            NSError* err = nil;
            [self.context save:&err];
            if(!err){
                self->_currentSelection = nil;
                [self.tableView reloadData];// reload the data and the table
            }else{
                NSLog(@"ERROR saving: %@",[err localizedDescription]);
            }
            // add functionality to change the build information and reload the data
        }];
    }
    
    
}

-(void) userDidCancel{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)userDidDeleteBuildWithID:(NSString *)buildId{
    [self dismissViewControllerAnimated:YES completion:^{
        [self deletBuildWithBuildID:buildId];
        [self.tableView reloadData];
    }];
}
// get the image preview thumbnail, by getting a list of the build items for this build and selecting the first item's thumbnail and scaling it to return
- (UIImage*)getBuildItemPreview:(Build*)b withSize:(NSInteger) imgSize andCorner:(NSInteger)cornerRadius{
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"BuildItem" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"build == %@",b];
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderNumber" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    
    if(error){
        NSLog(@"ERROR GETTING BUILD ITEMS: %@",[error localizedFailureReason]);
        return nil;
    }
    UIImage *returnImage = [UIImage imageNamed:@"placeholder1.jpg"];
    if([results count] >0){// if we don't have any yet, just push in the placeholder
        BuildItem *b = [results objectAtIndex:0];
        UIImage *previewImage = [self loadPreviewImageFromThumbnailPath:b.thumbnailPath];
        
        returnImage = previewImage;
    }
    
    
    
    return [returnImage thumbnailImage:imgSize transparentBorder:1 cornerRadius:cornerRadius  interpolationQuality:0];
}

// take the path and return the image or a placeholder if the path is no good
- (UIImage*)loadPreviewImageFromThumbnailPath:(NSString*) thumbnailPath{
    UIImage* img = [UIImage imageNamed:@"placeholder1.jpg"];
    if([thumbnailPath isEqualToString:@""] || [thumbnailPath isEqual:[NSNull null]]){
        return img;
    }else{
        UIImage *returnImage = [UIImage imageWithContentsOfFile:thumbnailPath];
        if(returnImage != nil){
            img = returnImage;
        }
        return img;
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
    static NSString *CellIdentifier = @"HomeCell";// name of recently registered cell
  
    HomeTableCell *cell =  (HomeTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
       [[NSBundle mainBundle] loadNibNamed:@"HomeTableCell" owner:self options:nil];
       
   }
    
    Build *b = [self.fetched objectAtIndexPath:indexPath];// get the group that corresponds with this index
    // add the features of the cell
    cell.titleTxt.text = b.title;
    cell.bgImg = [UIImage imageNamed:@"ambientlightblue-320x90.png"];//the background image
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:cell.bgImg];
    //cell.textLabel.text = b.title;
    //cell.detailTextLabel.text = b.buildDescription;
    
    UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //[actionBtn setTitle:b.status forState:UIControlStateNormal];
    UIImage* btnImg = nil;
    if([b.status isEqualToString:@"edit"]){
        btnImg = [UIImage imageNamed:@"pencil.png"];
    }else if([b.status isEqualToString:@"view"]){
        btnImg = [UIImage imageNamed:@"eye-open.png"];
    }else{
        btnImg = [UIImage imageNamed:@"export.png"];
    }
    [actionBtn setImage:btnImg forState:UIControlStateNormal];
    [actionBtn setTitle:b.status forState:UIControlStateNormal];
    [actionBtn sizeToFit];
    
    actionBtn.frame = cell.statusBtn.frame;
    //cell.accessoryView = actionBtn;
    [cell.statusBtn removeFromSuperview];
    [actionBtn addTarget:self action:@selector(showBuild:event:) forControlEvents:UIControlEventTouchUpInside];
    cell.statusBtn = nil;
    cell.statusBtn = actionBtn;
    [cell addSubview:actionBtn];
    
    UIImage* infoBtnImg = [UIImage imageNamed:@"file-info.png"];// get the info image
    UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [infoBtn setImage:infoBtnImg forState:UIControlStateNormal];
    [infoBtn setTitle:@"info" forState:UIControlStateNormal];
    [infoBtn sizeToFit];// size it to fit the title and the image
    infoBtn.frame = cell.infoBtn.frame;
    [cell.infoBtn removeFromSuperview];
    [infoBtn addTarget:self action:@selector(showBuildInfo:) forControlEvents:UIControlEventTouchUpInside];
    cell.infoBtn = nil;
    cell.infoBtn = infoBtn;
    
    [cell addSubview:infoBtn];
//    UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeInfoDark];
//    [infoBtn addTarget:self action:@selector(showBuildInfo:) forControlEvents:UIControlEventTouchUpInside];
//    infoBtn.frame = CGRectMake(200.0,15.0, 35.0,35.0);
//    [cell addSubview:infoBtn];
    
    cell.imageView.image = [self getBuildItemPreview:b withSize:30 andCorner:5]; // get the preview image
    
    return cell;


}
// need this height set explicitely so that it renders correctly in the tableview
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90.0;
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
