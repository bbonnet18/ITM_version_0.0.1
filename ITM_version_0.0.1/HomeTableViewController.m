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

-(void) unlockBuild:(id)sender;// unlocks the build so it can be edited
-(void) setStatusForItems:(Build*)b;// sets the status for each BuildItem to edit
-(void) handleTap:(UITapGestureRecognizer*) recognize;// handles removing the info img
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
    hv.contentView.backgroundColor = [UIColor lightGrayColor];
    UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.tableView.frame.size.width/2, 30)];
    l.text = @"Get Started";
    [hv.contentView addSubview:l];
    // add observer for uploaded item
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadComplete:) name:@"UploadComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:@"UploadProgress" object:nil];
    UIImage* addNewBtnImg = [UIImage imageNamed:@"addcontactpressed.png"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadCancelled) name:@"UploadAborted" object:nil];

    
    
    UIButton* newBuild = [UIButton buttonWithType:UIButtonTypeCustom];
   
//    newBuild.layer.borderColor = [[UIColor grayColor] CGColor];
//    newBuild.layer.borderWidth = 2.0f;
//    newBuild.layer.cornerRadius = 5.0f;
    newBuild.frame = CGRectMake(0, 0, 29.0,29.0);
    [newBuild setImage: addNewBtnImg forState:UIControlStateNormal];
    
    [newBuild addTarget:self action:@selector(addNewBuild:) forControlEvents:UIControlEventTouchUpInside];
    [newBuild setTitle:@"Create" forState:UIControlStateNormal];
    
    
    UIBarButtonItem *addNew = [[UIBarButtonItem alloc] initWithCustomView:newBuild];// add the new button itself
    
    self.navigationItem.rightBarButtonItem = addNew;
    // register the nib so we can load our custom tableviewcell
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeTableCell" bundle:nil] forCellReuseIdentifier:@"HomeCell"];
    
    //UIImage *bgimage = [UIImage imageNamed:@"iosBG.jpg"];
    //UIImageView *bgView = [[UIImageView alloc] initWithImage:bgimage];
    
    //self.tableView.backgroundView = bgView;
    
//    self.tableView.backgroundColor = [UIColor colorWithRed:0.33 green:0.33 blue:0.33 alpha:1.0];
    // set the bar appearance
    UIImage *bgImg = [UIImage imageNamed:@"bg_for_app.png"];
    UIImageView *bgImgView = [[UIImageView alloc] initWithImage:bgImg];
    [self.tableView setBackgroundView:bgImgView];
    UIOffset shadowOff = UIOffsetMake(0.5, 0.5);
    NSValue *shadowValue = [NSValue valueWithBytes:&shadowOff objCType:@encode(UIOffset)];
    
   
    NSArray *vals = [NSArray arrayWithObjects:[UIColor blackColor],[UIColor blackColor],shadowValue,nil];
    NSArray *keys = [NSArray arrayWithObjects:UITextAttributeTextColor,UITextAttributeTextShadowColor,UITextAttributeTextShadowOffset, nil];
    NSDictionary *appearanceDic = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
    
    [self.navigationController.navigationBar setTitleTextAttributes:appearanceDic];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.99 green:0.93 blue:0.79 alpha:1.0];
    [self.navigationController.navigationBar.backItem.backBarButtonItem setTintColor:[UIColor blueColor]];
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:0.09 green:0.49 blue:0.56 alpha:1.0]];
    NSError *error;
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"hasSeen"];
    // check to see if the user has seen the message yet
    if(![[[NSUserDefaults standardUserDefaults] valueForKey:@"hasSeenHome"] isEqualToString:@"YES"]){

        NSLog(@"height = %f",[[UIScreen mainScreen] bounds].size.height);
        NSString*imgName = ([[UIScreen mainScreen] bounds].size.height <= 480.0) ? @"home" : @"home-568h";
        UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
        img.userInteractionEnabled = YES;
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tgr.delegate = self;
        [img addGestureRecognizer:tgr];
        self.infoImgView = img;
        [self.infoImgView setAlpha:0.5f];
        [self.tableView addSubview:img];
    }
    
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

-(void) handleTap:(UITapGestureRecognizer *)recognize{
    [self.infoImgView removeFromSuperview];
    self.infoImgView = nil;
    [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"hasSeenHome"];
}

- (void) uploadComplete:(NSNotification*) note{
    
    NSDictionary * d = note.userInfo;// get the userInfoDictionary

    
    for (Build*b in self.fetched.fetchedObjects) {
        
        NSIndexPath *iP = [self.fetched indexPathForObject:b];
        if([[d valueForKey:@"buildID"] isEqualToString:b.buildID]){
            HomeTableCell * h = (HomeTableCell*)[self.tableView cellForRowAtIndexPath:iP];
            
            
            h.pubDateLabel.text = [NSString stringWithFormat:@"published: %@",[d valueForKey:@"publishDate"]];
            [h.pubDateLabel setHidden:NO];

        }
    }

    
    [self.tableView reloadData];
}

- (void) updateProgress:(NSNotification*) note{
    NSDictionary * d = note.userInfo;// get the userInfoDictionary
    
    for (Build*b in self.fetched.fetchedObjects) {
        
        NSIndexPath *iP = [self.fetched indexPathForObject:b];
        if([[d valueForKey:@"buildID"] isEqualToString:b.buildID]){
            HomeTableCell * h = (HomeTableCell*)[self.tableView cellForRowAtIndexPath:iP];
            if([h.uploadingProgress isHidden]){
                [h.uploadingProgress setHidden:NO];
            }
            
            if([h.uploadingLabel isHidden]){
                [h.uploadingLabel setHidden:NO];
            }
            
            if(![h.pubDateLabel isHidden]){
                [h.pubDateLabel setHidden:YES];
            }
            float f =  [[d valueForKey:@"uploadProgress"] floatValue]; //[d valueForKey:@"progress"];
            [h.uploadingProgress setProgress:f animated:YES];
        }
    }
    
}

- (void) uploadCancelled{
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
        [self setStatusForItems:b];// sets the status to edit for all items
        MainEditorViewController *bv = [[MainEditorViewController alloc] initWithNibName:@"MainEditorViewController" bundle:[NSBundle mainBundle]];
        [bv setBuildID:b.buildID];
        
        bv.title = @"Edit";
        bv.context = self.context;// assign the context
        
        
        
        [self.navigationController pushViewController:bv animated:YES];
    }
}
// adds a new build with no info because it's new
- (void) addNewBuild:(id)sender{
    
    if(![[[NSUserDefaults standardUserDefaults] valueForKey:@"hasSeen"] isEqualToString:@"YES"]){
        [self.infoImgView removeFromSuperview];
        self.infoImgView = nil;
        [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"hasSeen"];

    }

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
        ti.isEditable = ([b.status isEqualToString:@"edit"]) ? YES : NO;
        ti.status = b.status;
        ti.buildID = b.buildID;
        ti.preview = [self getBuildItemPreview:b withSize:100 andCorner:8];
        ti.datePublished = (b.publishDate != nil) ? [[Utilities sharedInstance] getTimeStamp:b.publishDate] : @"Not yet published";
        NSLog(@"datePublished :%@",ti.datePublished);
        
        
        [self presentViewController:ti animated:YES completion:^{
            
        }];
    }

    
}


// allows the user to unlock a build that is currently locked for uploading purposes
-(void) unlockBuild:(id)sender{
    
   UIAlertView *av =  [[UIAlertView alloc] initWithTitle:@"Stop Upload?" message:@"Tap stop upload to stop the upload so you can edit your items. Tap cancel to allow the upload to continue" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"stop upload",nil, nil];
    [av show];
}

// simply sets the status to edit for all items
-(void) setStatusForItems:(Build *)b{
    
    //retrieve the build items
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
        //[self showError:[error localizedDescription]];
    }else{
        for(BuildItem *bI in results){
            bI.status = @"edit";
        }
        NSError *saveErr = nil;
        [self.context save:&saveErr];
        if(saveErr){
            NSLog(@"error saving %@",[saveErr localizedDescription]);
        }
    }

}

- (void) addNewBuildWithTitle:(NSString*)title andDescription:(NSString*)description {
    Build *newBuild = (Build*) [NSEntityDescription insertNewObjectForEntityForName:@"Build" inManagedObjectContext:self.context];
    
    
    NSDate *today = [NSDate date];
    newBuild.dateCreated = today;
    newBuild.buildDescription = description;
    NSString *newBuildID = [[Utilities sharedInstance] GetUUIDString];
    newBuild.buildID = newBuildID;
    newBuild.status = @"edit";
    newBuild.title = title;
    newBuild.publishDate = nil;
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

#pragma AlertViewDelegate Methods

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            [self.delegate stopUpload];
            break;
        default:
            break;
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
    
    cell.layer.borderColor = [[UIColor grayColor] CGColor];  //colorWithRed:0.99 green:0.92 blue:0.79 alpha:1.0] CGColor]; // this is the tan color
    cell.contentView.layer.cornerRadius = 8.0f;
    cell.contentView.layer.borderWidth = 2.0f;
    [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.09 green:0.48 blue:0.56 alpha:1.0]];
    [cell.uploadingProgress setProgress:0];
    [cell.uploadingProgress setHidden:YES];
    [cell.uploadingLabel setHidden:YES];
    [cell.pubDateLabel setHidden:NO];
    Build *b = [self.fetched objectAtIndexPath:indexPath];// get the group that corresponds with this index
    // add the features of the cell
    cell.titleTxt.text = b.title;
       //cell.bgImg = [UIImage imageNamed:@"ambientlightblue-320x90.png"];//the background image
    
    //cell.backgroundView = [[UIImageView alloc] initWithImage:cell.bgImg];
    //cell.textLabel.text = b.title;
    //cell.detailTextLabel.text = b.buildDescription;
    UIImage* infoBtnImg = [UIImage imageNamed:@"file-info.png"];// get the info image
//    UIImage* stretchedImg = [UIImage imageNamed:@"uiglassbutton-template.png"];
//    UIImage* stretchedBtnImg = [stretchedImg stretchableImageWithLeftCapWidth:12.0 topCapHeight:0];
    
    UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    actionBtn.layer.backgroundColor = [[UIColor colorWithRed:0.99 green:0.92 blue:0.79 alpha:1.0] CGColor];
    actionBtn.layer.cornerRadius = 8.0f;
    [actionBtn setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
    //[actionBtn setBackgroundImage:stretchedBtnImg forState:UIControlStateNormal];
    UIImage* btnImg = nil;
    NSLog(@"status - %@",b.status);
    if([b.status isEqualToString:@"edit"]){
        btnImg = [UIImage imageNamed:@"pencil.png"];
        [actionBtn addTarget:self action:@selector(showBuild:event:) forControlEvents:UIControlEventTouchUpInside];
        [actionBtn setTitle:b.status forState:UIControlStateNormal];
    }
//    else if([b.status isEqualToString:@"view"]){
//        btnImg = [UIImage imageNamed:@"eye-open.png"];
//    }
    else{// if it's uploading
        btnImg = [UIImage imageNamed:@"eye-close.png"];
        [actionBtn addTarget:self action:@selector(unlockBuild:) forControlEvents:UIControlEventTouchUpInside];
        [actionBtn setTitle:@"" forState:UIControlStateNormal];
    }
    [actionBtn setImage:btnImg forState:UIControlStateNormal];
    //[actionBtn setTitle:b.status forState:UIControlStateNormal];
    [actionBtn sizeToFit];
    
    actionBtn.frame = cell.statusBtn.frame;
    //cell.accessoryView = actionBtn;
    [cell.statusBtn removeFromSuperview];
    cell.statusBtn = nil;
    cell.statusBtn = actionBtn;
    [cell addSubview:actionBtn];
    
    
    UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //[infoBtn setBackgroundImage:stretchedBtnImg forState:UIControlStateNormal];
    infoBtn.layer.backgroundColor = [[UIColor colorWithRed:0.99 green:0.92 blue:0.79 alpha:1.0] CGColor];
    infoBtn.layer.cornerRadius = 8.0f;
    [infoBtn setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
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
    NSDateFormatter *pubDateFormatter = [[NSDateFormatter alloc] init];
    [pubDateFormatter setDateStyle:NSDateFormatterShortStyle];
    if(b.publishDate != nil){
        NSString *formattedDate = [pubDateFormatter stringFromDate:b.publishDate];
        cell.pubDateLabel.text = [NSString stringWithFormat:@"published: %@",formattedDate];
    }else{
        cell.pubDateLabel.text = @"Not Published";
    }
    
    cell.imageView.image = [self getBuildItemPreview:b withSize:50 andCorner:5]; // get the preview image
    
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
