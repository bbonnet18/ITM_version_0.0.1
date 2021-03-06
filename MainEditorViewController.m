//
//  MainEditorViewController.m
//  ITM_v0
//
//  Created by Lauren Bonnet on 10/5/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import "MainEditorViewController.h"
#import "ImageEditorViewController.h"

@interface MainEditorViewController ()
-(void) handleTap:(UITapGestureRecognizer*)recognizer;

-(BOOL) checkItemsHaveValues;// used to make sure all items have values
-(void) reorderBuildItemsWithBuild:(Build*)build andOrderNum:(NSNumber*)orderNumber;// this will re-order after the new one is added, this has to happen so they will show up right in the sequence
-(void) resetBuildItemsAfterItemDeleted:(NSNumber*)orderNumber;//resets the builditem orderNumbers after one has been deleted
@end

@implementation MainEditorViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.previewImageArray = [[NSMutableArray alloc] init];
        self.orderArray = [[NSMutableArray alloc] init];

        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setBuildItems];// set the items by getting the build and it's items
    self->_previewImageIndex = 0;
    
    if(![[[NSUserDefaults standardUserDefaults] valueForKey:@"hasSeenEdit"] isEqualToString:@"YES"]){
        NSString*imgName = ([[UIScreen mainScreen] bounds].size.height <= 480.0) ? @"main_edit" : @"main_edit-568";
        UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
        img.userInteractionEnabled = YES;
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tgr.delegate = self;
        [img addGestureRecognizer:tgr];
        self.infoImgView = img;
        [self.infoImgView setAlpha:0.5f];
        [self.view addSubview:img];
    }

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self->_previewImageIndex = 0;
    // Dispose of any resources that can be recreated.
}

-(void) handleTap:(UITapGestureRecognizer *)recognize{
    [self.infoImgView removeFromSuperview];
    self.infoImgView = nil;
    [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"hasSeenEdit"];
}


// set the build ID so it can be used to retrieve the build
-(void) setBuildID:(NSString *)buildID{
    
    self->_buildID = buildID; 
}

#pragma mark - private method to get the build

// this is a convenience method that returns the build that this editor populates. Will return nil if there's an error.
- (Build*) getBuild{
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Build" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"buildID == %@",self->_buildID];
    [request setPredicate:predicate];
    NSError *error = nil;
    
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    if(error){
        NSLog(@"Exception : %@",[error localizedFailureReason]);
        return nil;
    }
    
    return [results objectAtIndex:0];
    
    
}

// returns a single buildItem by using the item id (GUUID string) of the buildItem. Returns nil if there's an error
- (BuildItem*) getBuildItem:(NSString*)buildItemIDString{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"BuildItem" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"buildItemIDString == %@",buildItemIDString];
    [request setPredicate:predicate];
    NSError *error = nil;
    
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    if(error){
        NSLog(@"Exception : %@",[error localizedFailureReason]);
        return nil;
    }
    return [results objectAtIndex:0];
}

// PreviewImageProtocol

-(void) editItem:(NSInteger)itemNumber{
    NSDictionary *buildIDDic = [self.orderArray objectAtIndex:itemNumber];
    NSString* buildItemIDString = [buildIDDic valueForKey:@"buildItemIDString"];
    BuildItem *bi = [self getBuildItem:buildItemIDString];
    
    CaptureViewController *cv = [[CaptureViewController alloc] initWithNibName:@"CaptureViewController" bundle:nil];
    cv.delegate = self;
    // set up the keys for the dictionary to provide to the 
    NSArray *keys = [NSArray arrayWithObjects:@"buildItemIDString",@"thumbnailPath",@"mediaPath",@"type",@"title",@"caption",@"timeStamp",@"imageRotation", nil];
    // get all the values from the build object
    NSDictionary * dic = [bi dictionaryWithValuesForKeys:keys];
    
    NSLog(@"dic: itemID: %@ thumbnailPath: %@ mediaPath: %@ type: %@ imageRotation: %d",[dic valueForKey:@"buildItemIDString"],[dic valueForKey:@"thumbnailPath"],[dic valueForKey:@"mediaPath"],[dic valueForKey:@"type"], (int)[dic valueForKey:@"imageRotation"]);
    cv.buildItemVals = [NSMutableDictionary dictionaryWithDictionary:dic];
    [self presentViewController:cv animated:YES completion:^{
        
    }];
    
    
}
// make sure we can create a buildItem and then call the setBuildItems function to reset everything
- (void) addAfter:(NSInteger)afterIndex{
    if([self createBuildItemWithOrderNumber:[NSNumber numberWithInt:afterIndex]] != nil){
        [self setBuildItems];
        CGRect newRect = CGRectMake(self.scroller.contentOffset.x+self.scroller.frame.size.width, self.scroller.contentOffset.y, self.scroller.frame.size.width, self.scroller.frame.size.height);
        [self.scroller scrollRectToVisible:newRect animated:YES];
    }
}
// make sure we can create a buildItem and then call the setBuildItems function to reset everything, also need to make sure we are not trying to add before 0
- (void) addBefore:(NSInteger)beforeIndex{
    //if(beforeIndex >= 1){
    if(beforeIndex ==0){
        beforeIndex = 1;// only if it comes from number 1, so you don't put it behind the first one
    }
        if([self createBuildItemWithOrderNumber:[NSNumber numberWithInt:beforeIndex]] != nil){
            [self setBuildItems];
                CGRect newRect = CGRectMake(self.scroller.contentOffset.x+self.scroller.frame.size.width*-1, self.scroller.contentOffset.y, self.scroller.frame.size.width, self.scroller.frame.size.height);
            
            
            [self.scroller scrollRectToVisible:newRect animated:YES];
        }
    //}
}



- (void) deleteItem:(NSInteger)itemNumber{
    
    [self deleteBuildItemInOrder:itemNumber];
    
    Build *build = [self getBuild];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"BuildItem" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"build == %@",build];
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderNumber" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    
    if(error){
        NSLog(@"ERROR GETTING BUILD ITEMS: %@",[error localizedFailureReason]);
    }
    
    // increment all old ones by 1 if their orderNumber is greater than or equal to proposed orderNumber
    for (BuildItem *bi in results) {
        NSLog(@"orderInt: %i , deletedVal: %i",[bi.orderNumber intValue],itemNumber);
        if([bi.orderNumber intValue] >= itemNumber){
            NSInteger orderIt = [bi.orderNumber intValue];
            NSInteger newOrder = orderIt - 1;
            bi.orderNumber = [NSNumber numberWithInt:newOrder];
        }
    }
    NSError *orderErr = nil;
    
    if(![self.context save:&orderErr]){
        NSLog(@"%@", [orderErr localizedFailureReason]);
    }
    for (BuildItem *bi in results) {
        NSLog(@"orderInt: %i , deletedVal: %i",[bi.orderNumber intValue],itemNumber);
    }
}

// returns the itemArray. Returns an empty array if there's nothing in it. Returns nil if  there's an error when attempting to execute the fetch request
-(NSArray*) getBuildItems:(Build*)b{
    
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
    for (BuildItem * bi in results) {
        NSLog(@"buildItem orderNumber: %@", bi.orderNumber);
    };
    
    if(error){
        NSLog(@"ERROR GETTING BUILD ITEMS: %@",[error localizedFailureReason]);
        [self showError:[error localizedDescription]];
        return nil;
    }
    
    // creaete an array to hold the values of the buildItemIDs
//    NSMutableArray *idsToReturn = [[NSMutableArray alloc] initWithCapacity:results.count];
//    // add the id for each one
//    for (BuildItem *bi in results) {
//        NSLog(@"build item id: %@",bi.buildItemID);
//        // create a dictionary to hold the value of the thumbnailPath and the buildItemID
//        NSDictionary* itemVals = [NSDictionary dictionaryWithObjectsAndKeys:bi.buildItemID,@"buildItemID",bi.thumbnailPath,@"thumbnailPath", nil];
//        NSLog(@"buildItemID: %@  , %@",[itemVals objectForKey:@"buildItemID"],[itemVals objectForKey:@"thumbnailPath"]);
//        [idsToReturn addObject:itemVals];
//    }
    
    NSArray* returnArray = [self getBuildItemValues:results];
    return returnArray;

}
// gets an array of buildItems and returns the results as an array, populating the results
// with the values from the build items
- (NSArray*) getBuildItemValues:(NSArray*)buildItemArray{
    NSMutableArray *idsToReturn = [[NSMutableArray alloc] initWithCapacity:buildItemArray.count];
    // add the id for each one
    for (BuildItem *bi in buildItemArray) {
        // create a dictionary to hold the value of the thumbnailPath and the buildItemIDString
        NSDictionary* itemVals = [NSDictionary dictionaryWithObjectsAndKeys:bi.buildItemIDString,@"buildItemIDString",bi.thumbnailPath,@"thumbnailPath",bi.title,@"title",bi.caption,@"caption", nil];
        [idsToReturn addObject:itemVals];
    }

    return [NSArray arrayWithArray:idsToReturn];
}

// this will create, save and return a build item. It will return nil if there's an error when creating and saving the buildItem
-(BuildItem*) createBuildItemWithOrderNumber:(NSNumber*) orderNum{
    Build *b = [self getBuild];
    
    if([orderNum intValue] < 0){
        orderNum = [NSNumber numberWithInt:0];
    }

    
    [self reorderBuildItemsWithBuild:b andOrderNum:orderNum];
    
    BuildItem* bi = [NSEntityDescription insertNewObjectForEntityForName:@"BuildItem" inManagedObjectContext:self.context];
    bi.orderNumber = orderNum;
    bi.buildItemIDString = [[Utilities sharedInstance] GetUUIDString];
    bi.status = @"EDIT"; // this will set the upload status to NO since it hasn't been uploaded
    [bi setBuild:b];
    NSError* err;
    if(![self.context save:&err]){
        NSLog(@"ERROR saving the BUILD ITEM: %@",[err localizedFailureReason]);
        return nil;
    }
    return bi;
    
}

-(void) reorderBuildItemsWithBuild:(Build *)build andOrderNum:(NSNumber *)orderNumber{
    
  
    
    // get all the current items
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"BuildItem" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"build == %@",build];
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderNumber" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    
    NSArray *results = [self.context executeFetchRequest:request error:&error];

    if(error){
        NSLog(@"ERROR GETTING BUILD ITEMS: %@",[error localizedFailureReason]);
    }

    // increment all old ones by 1 if their orderNumber is greater than or equal to proposed orderNumber
    for (BuildItem *bi in results) {
        NSLog(@"orderInt: %i  proposedInt: %i",[bi.orderNumber intValue], [orderNumber intValue]);
        if([bi.orderNumber intValue] >= [orderNumber intValue]){
            NSInteger orderIt = [bi.orderNumber intValue];
            NSInteger newOrder = orderIt + 1;
            bi.orderNumber = [NSNumber numberWithInt:newOrder];
        }
    }
    NSError *orderErr = nil;
    
    if(![self.context save:&orderErr]){
         NSLog(@"%@", [orderErr localizedFailureReason]);
    }
    
    
    for (BuildItem *bi in results) {
        NSLog(@" --- orderNumber: %@",bi.orderNumber);
    }
    
}

// delete the build item, also calls the function to delete the build's thumbnail
- (void) deleteBuildItemInOrder:(NSInteger) index{
   // remove the build item by getting it and then removing it from the context and the build relationship
    NSDictionary *buildIDDic = [self.orderArray objectAtIndex:index];
    NSString* buildItemIDString = [buildIDDic valueForKey:@"buildItemIDString"];
    
    NSDictionary *buildItemVals = [self.orderArray objectAtIndex:index];
    
    NSString* thumbnailPath = [buildItemVals valueForKey:@"thumbnailPath"];
    //if(thumbnailPath == @"" || thumbnailPath == nil || [thumbnailPath isEqual:[NSNull null]]){
    BOOL boolVal = [self deleteBuildItemThumbnailAtPath:thumbnailPath];
    NSLog(@"BOOL = %@\n", (boolVal ? @"YES" : @"NO"));
    //}
    BuildItem* b = [self getBuildItem:buildItemIDString];
    
    [self.context deleteObject:b];
    NSError *error;
    if(![self.context save:&error]){
        NSLog(@"%@", [error localizedFailureReason]);
    }
    [self setBuildItems];
}

// delete the build item thumbnail if it can find it. Returns YES if there was an item there and NO if there was not and it couldn't delete it
- (BOOL) deleteBuildItemThumbnailAtPath:(NSString*)path{
    
    if([path isEqual:[NSNull null]] || [path isEqualToString:@""]){
        return NO;
    }
    
    NSError *error;// set the error reference for the method
    NSFileManager *mgr = [NSFileManager defaultManager];
    if ([mgr removeItemAtPath:path error:&error] != YES){
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
        [self showError:[error localizedDescription]];
        return NO;
    }else{
        return YES;
    }

}

-(void) showError:(NSString*) errStr{
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"ERROR" message:errStr delegate:self cancelButtonTitle:@"cancel" otherButtonTitles: nil];
    [av show];
    
    
}

// this should be called every time there is a change so it repopulate arrays and views
-(void) setBuildItems{
    
    Build *b = [self getBuild];
    if(b != nil){
    NSArray* itemsToLoad = [self getBuildItems:b];// gets all the build items
    [self resetArraysAndViews];// reset everything
    if(itemsToLoad.count >0){
        // create a previewImage instance and assign it's value for itemNumber
        
        for (int i=0; i<itemsToLoad.count; i++) {
            
            NSDictionary* dic = [itemsToLoad objectAtIndex:i];// get the build item so you can get its' id
            
            NSString* thumbnailPath = [dic valueForKey:@"thumbnailPath"];
            UIImage *img = [self loadPreviewImageFromThumbnailPath:thumbnailPath];
            PreviewImage *p = [[PreviewImage alloc] initWithFrame:self.scroller.frame andImage:img];
            p.itemNumber = i; // set the item number to the number in the array
            p.delegate = self;
            [self.orderArray addObject:dic];// add the id so we can retrieve it based on the passed item number from the preview image objects
            [self.previewImageArray addObject:[NSNull null]];// used as a placeholder for lazy loading purposes
            NSLog(@"count: %u - itemID: %@",[self.previewImageArray count], [dic valueForKey:@"buildItemIDString"]);
        }

    }else{
        // create a buildItem to get started
        BuildItem *b = [self createBuildItemWithOrderNumber:[NSNumber numberWithInt:0]];
        
        UIImage* img = [UIImage imageNamed:@"rounded_placeholderNew.png"];// get an image to send to the preview image instance when initiating
        CGRect frame = self.scroller.bounds;
        frame.origin.x = 0.0f;// set it to the first item
        frame.origin.y = 0.0f;
        
        PreviewImage *p = [[PreviewImage alloc] initWithFrame:frame andImage:img];
        p.itemNumber = 0; // set the item number to the number in the array
        p.delegate = self;// set self as delegate because the methods from the PreviewImage will come here
        NSString *buildItemIDString = b.buildItemIDString;
        NSDictionary *buildItemDic = [NSDictionary dictionaryWithObject:buildItemIDString forKey:@"buildItemIDString"];
        [self.orderArray addObject:buildItemDic];// add the id so we can retrieve it based on the passed item number from the preview image objects
        [self.previewImageArray addObject:p];
        [self.scroller addSubview:p];
    }
    
        [self resetScroller];
        [self loadVisiblePages];
    }
  

}
// take the path and return the image or a placeholder if the path is no good
- (UIImage*)loadPreviewImageFromThumbnailPath:(NSString*) thumbnailPath{
    UIImage* img = [UIImage imageNamed:@"rounded_placeholderNew.png"];
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

// just resets everything when we make changes
- (void) resetArraysAndViews{
    // make sure to reset everything for each array
    [self.orderArray removeAllObjects];// remove all objects from the array
    [self.previewImageArray removeAllObjects];
    
    // remove all the current subviews
    if([[self.scroller subviews] count] > 0){
        [[self.scroller subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
}
// just resets the scroller, and scrolls it to the current previewImage
- (void) resetScroller{
    CGSize pagesScrollSize = self.scroller.frame.size;
    self.scroller.contentSize = CGSizeMake(pagesScrollSize.width * self.previewImageArray.count, pagesScrollSize.height);
    
    CGRect scrollTo = self.scroller.bounds;
    // this is 0
    scrollTo.origin.x = scrollTo.size.width * self->_previewImageIndex;
    scrollTo.origin.y = 0.0f;
    [self.scroller scrollRectToVisible:scrollTo animated:YES];
    
}

// set scroller actions

- (void) loadVisiblePages{
    
    CGFloat pageWidth = self.scroller.frame.size.width;
    
//    CGFloat x = self.scroller.contentOffset.x;
//    NSLog(@"pageWidth: %f",pageWidth);
//    NSLog(@"x : %f",x);
//    NSLog(@"offsetX *2: %f",x*2);
//    NSLog(@"pageWidth*2 %f",pageWidth*2);
    
    NSInteger page = (NSInteger)floor((self.scroller.contentOffset.x * 2.0f + pageWidth)/(pageWidth * 2.0f));
    
    self.title = [NSString stringWithFormat:@"Editing %i of %i",page+1,self.previewImageArray.count];
    //update the page control
    self->_previewImageIndex = page;
    // work out which pages to load
    NSInteger firstPage = page - 1;
    NSInteger lastPage = page + 1;
    
    for(NSInteger i = 0; i <firstPage; i++){
        [self purgePage:i];// get rid of those that aren't before the first
    }
    
    for(NSInteger i=firstPage; i<= lastPage; i++){
        [self loadPage:i];// load the visible pages
    }
    
    for(NSInteger i=lastPage +1; i<self.previewImageArray.count; i++){
        [self purgePage:i];// get rid of those that are after the last page
    }
    
}


- (void) loadPage:(NSInteger)page{
    if(page < 0 || page >= self.previewImageArray.count){
        return;
    }
    
    PreviewImage *previewImg = [self.previewImageArray objectAtIndex:page];
    if((NSNull*) previewImg == [NSNull null]){// if it's null, then initialize and create the button and add it to the pageViews array
        CGRect frame = self.scroller.bounds;
        frame.origin.x = frame.size.width * page;// set the starting x point to the location on the scroller view, where it will reside
        frame.origin.y = 0.0f;
        // need to get the build item here
        
        NSDictionary *buildIDDic = [self.orderArray objectAtIndex:page];
        NSString* thumbnailPath = [buildIDDic valueForKey:@"thumbnailPath"];
        //BuildItem *bi = [self getBuildItem:buildItemIDString];
        
        //NSString *iconPath = bi.thumbnailPath;// get the path to the thumbnail
        UIImage *img = [self loadPreviewImageFromThumbnailPath:thumbnailPath];
        
        PreviewImage *pImg = [[PreviewImage alloc] initWithFrame:frame andImage:img];// set the frame size of the button to the frame size of the screen, but offset to account for the page we're on
        //pImg.contentMode = UIViewContentModeCenter;//UIViewContentModeScaleAspectFit;
        pImg.delegate = self;
        pImg.itemNumber = page;
        [pImg updateTitleLabel:[buildIDDic valueForKey:@"title"]];
        [pImg updateCaptionLabel:[buildIDDic valueForKey:@"caption"]];
        [pImg updateCounterLabel:[NSString stringWithFormat:@"%@ of %@",[NSNumber numberWithInt:page+1],[NSNumber numberWithInt:[self.orderArray count]]]];
        [self.scroller addSubview:pImg];
        [self.previewImageArray replaceObjectAtIndex:page withObject:pImg];
    }
    
}

- (void) purgePage:(NSInteger)page{// remove by replacing it with a null value
    if(page <0 || page >= self.previewImageArray.count){
        return;
        
    }
    
    PreviewImage *pImg = [self.previewImageArray objectAtIndex:page];
    if((NSNull *) pImg != [NSNull null]){
        [pImg removeFromSuperview];
        [self.previewImageArray replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}


#pragma mark - scrollview delegate methods

- (void) scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    [self loadVisiblePages];// on scroll load visible images
}

// helper method, just get's the image for the path and returns it. If it's nil, returns nil
//-(UIImage*)getPreviewImage:(NSString*)path{
//    
//    UIImage *returnImage = [UIImage imageWithContentsOfFile:path];
//    if(returnImage == nil){
//        return nil;
//    }
//    return returnImage;
//}


#pragma mark PreviewImage protocol methods
// get all the values from the changes dictionary and set them on the buildItem
- (void) didEditItemWithDictionary:(NSDictionary *)changes{
    NSString *buildItemIDString = [changes valueForKey:@"buildItemIDString"];
    NSString *thumbnailPath = [changes valueForKey:@"thumbnailPath"];
    NSString *type = [changes valueForKey:@"type"];
    NSString *mediaPath = [changes valueForKey:@"mediaPath"];
    NSString *caption = [changes valueForKey:@"caption"];
    NSString *timeStamp = [changes valueForKey:@"timeStamp"];
    NSString *title = [changes valueForKey:@"title"];
    NSNumber* imageRotation = [changes valueForKey:@"imageRotation"];
    
    //make sure none of these are null and if they are, substitute an empty string
    
    BuildItem * bi = [self getBuildItem:buildItemIDString];
    bi.thumbnailPath = ([thumbnailPath isEqual:[NSNull null]] ? @"":thumbnailPath);
    bi.type = ([type isEqual:[NSNull null]] ? @"":type);
    bi.mediaPath = ([mediaPath isEqual:[NSNull null]] ? @"":mediaPath);
    bi.caption = ([caption isEqual:[NSNull null]] ? @"":caption);
    bi.timeStamp = ([timeStamp isEqual:[NSNull null]] ? @"":timeStamp);
    bi.title = ([title isEqualToString:@""] ? @"":title);
    bi.imageRotation = imageRotation;
    NSError *err = nil;
    if(![self.context save:&err]){
        NSLog(@"error creating the test build object: %@", [err localizedFailureReason]);
        [self showError:[err localizedDescription]];
    }

    [self dismissViewControllerAnimated:YES completion:^{
        [self setBuildItems];
    }];
}

- (void) didCancelEditProcess{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }]; 
}
// only need the cancel for the error screens, not providing any other buttons
-(void) alertViewCancel:(UIAlertView *)alertView{
   
}

-(BOOL) checkItemsHaveValues{
    
    NSArray* items = [self getBuildItems:[self getBuild]];
    BOOL isClear = YES;
    for(NSDictionary *item in items){
        
        NSString *title = [item objectForKey:@"title"];
        NSString *caption = [item objectForKey:@"caption"];
        if([title length] < 1  || [caption length] < 1){
            isClear = NO;
            break;
        }
    }
    return isClear;
}

-(IBAction)publish:(id)sender{
    
    if([self checkItemsHaveValues]){
        
        PublishViewController *pv = [[PublishViewController alloc] initWithNibName:@"PublishViewController" bundle:[NSBundle mainBundle]];
        pv.delegate = self;
        NSDate *d = ([self getBuild].publishDate != nil) ? [self getBuild].publishDate : nil;
    
        NSLog(@"date: %@", [d description]);
        pv.titleLabelStr = (d != nil) ? @"Re-Publish" : @"Publish";
        pv.publishDateStr = (d != nil) ? [NSString stringWithFormat:@"last published: %@",[[Utilities sharedInstance] getTimeStamp:d]] : @"";
        [self presentViewController:pv animated:YES completion:^{
        
    }];
    }else{
        UIAlertView *fixEmptiesAlert = [[UIAlertView alloc] initWithTitle:@"Empty Items" message:@"You have empty items. Enter content in empty items or delete them before publishing" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [fixEmptiesAlert show];
    }
}

#pragma Publish Protocol methods

-(void) userDidPublishWithEmails:(NSArray *)emails{
    
    // create a build dicitionary with the buildID and send it off
     NSDictionary *holder = [NSDictionary dictionaryWithObjectsAndKeys:self->_buildID,@"buildID",emails,@"emails", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidUpload" object:nil userInfo:holder];
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismissed the publish screen");
    }];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void) userDidCancel{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end


/*
 
 // This method needs to account for the id's of the items as they are added and subtracted.
  
 
 -(Boolean)saveNewImage:(UIImage*)img{
 // don't delete here, just delete in the rotate
 //    if(self.buildItem.imagePath != @""){//check to see if we already stored an earlier image, if so, delete that one because we're going to save a new one
 //        NSError *error;
 //        NSFileManager *mgr = [NSFileManager defaultManager];
 //        NSString* str = self.buildItem.imagePath;
 //        if ([mgr removeItemAtPath:self.buildItem.imagePath error:&error] != YES)
 //            NSLog(@"Unable to delete file: %@ : %@ : %@ : %@", [error localizedDescription],[error localizedFailureReason], [error localizedRecoverySuggestion],  [error localizedRecoveryOptions]);
 //    }
 
 // create the filename and save the image to the documents directory
 NSString *imageName = [NSString stringWithFormat:@"image_%@",  [self GetUUID]];
 NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.jpg",imageName]];
 NSURL *url = [NSURL fileURLWithPath:path];
 
 NSLog(@"build image name: %@",imageName);
 
 [UIImageJPEGRepresentation(img, 0.75f) writeToURL:url atomically:YES];
 self.buildItem.imagePath = path;
 
 NSLog(@"videoPath: %@",self.buildItem.imagePath);
 
 return YES;
 
 // NSLog(@"THERE WAS A PROBLEM SAVING THE IMAGE");
 // return NO;
 }

 
  */
