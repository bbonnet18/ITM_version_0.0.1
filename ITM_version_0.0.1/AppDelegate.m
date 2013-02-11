//
//  AppDelegate.m
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 10/8/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"


#define kITMServiceBaseURLString @"http://192.168.1.8/service"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize isReachable = _isReachable;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(published:) name:@"UserDidUpload" object:nil];// handle uploads from the publish screen

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];

    self.uploadQueue = [[NSOperationQueue alloc] init];// set the background queue
    
        // reachability blocks and initialization
    Reachability * reach = [Reachability reachabilityWithHostname:kITMServiceBaseURLString];
    
    reach.reachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"--- BLOCK --- is Reachable");
            self.isReachable = YES;
        });
    };
    
    reach.unreachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"--- BLOCK --- is NOT  Reachable");
            self.isReachable = NO;
        });
    };
    
    [reach startNotifier];
    
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUploading"]  && [[NSUserDefaults standardUserDefaults] boolForKey:@"isUploading"] == YES){
        NSString* uploadingBuildID = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastUploadingBuildID"];
        
        NSArray * emails =  [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUploadingEmails"];
        // set emails to contain at least one object
        
        // this should be encapsulated in another method, so it can be called from here and from the published function
        
        Build * newBuild = [self getBuild:uploadingBuildID];
        
        if(newBuild != nil){
            [self startUploadProcessWithBuild:newBuild withDistroEmails:emails];

        }
                
    }
    
        // This will call the login screen if the user isn't logged in
    if(![[ITMServiceClient sharedInstance] isAuthorized]){
        // enter login script
        LoginViewController *lv = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        self.window.rootViewController = lv;
        
    }else{
        HomeTableViewController *hc = [[HomeTableViewController alloc] initWithNibName:@"HomeTableViewController" bundle:[NSBundle mainBundle]];
        hc.context = self.managedObjectContext;
        hc.delegate = self;
        
        // subclassed main nave controller from nav controller to override autorotation
        MainNavViewController *nav = [[MainNavViewController alloc] initWithRootViewController:hc];
        UIImage* bgImg = [UIImage imageNamed:@"mysteriousblue-300x45p.png"];// get the header background image
        [nav.navigationBar setBackgroundImage:bgImg forBarMetrics:UIBarMetricsDefault];// set the background image of the nav bar
        self.navController = nav;
        
        self.window.rootViewController = self.navController;// setting the root view controller is the right way, instead of making the homeview's view a subview of the window - maybe because it then releases the view controller and simply holds onto the subview (in this case that's a button
    }
    
    return YES;

}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
        self.isReachable = YES;
    }
    else
    {
        self.isReachable = NO;
    }
}



- (void) startUploadProcessWithBuild: (Build*) newBuild withDistroEmails:(NSArray*) distroEmails{
    
    if(newBuild != nil){
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"BuildItem" inManagedObjectContext:self.managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"build == %@",newBuild];
        [request setPredicate:predicate];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderNumber" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        NSError *error = nil;
        
        // each of these is actually a buildItem rather than a media item
        NSArray *mediaItems = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:request error:&error]];// go get all the mediaItems
      
        NSMutableArray *mediaItemsToUpload = [[NSMutableArray alloc] initWithCapacity:[mediaItems count]];// inititate the mediaItemsToUpload array that will be passed to the uploader
        if(error == nil){
            
            // create array to hold the objects to pass to the uploader
            
            for (BuildItem * b in mediaItems) {
                                
                NSMutableDictionary *mediaObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:b.type,@"type",b.mediaPath,@"path",b.status,@"status",b.imageRotation,@"imageRotation", b.caption,@"caption",b.title,@"title", b.orderNumber,@"orderNumber", nil];
                [mediaItemsToUpload addObject:mediaObject];// add it to the array to be passed
                
                
                // create a dictionary of objects that have types and media paths and send those to the uploader
            }
            
            // get the JSON data from the build
            NSData * jsonData = [self generateJSONFromBuild:newBuild withItems:mediaItems andEmails:distroEmails];
            // create an instance of uploader and assign it to the uploader instance variable so it can be acted on and tracked
            self.uploader = [[Uploader alloc] initWithBuildItems:mediaItemsToUpload buildID:newBuild.buildID];
            self.uploader.emailsToDistribute = distroEmails;
            self.uploader.delegate = self;// should probably set this before calling the method above, or set it with it.
            [self.uploader createJSONDataRequest:jsonData];// start the upload process
        }else{
            
            NSLog(@"PROBLEM RETRIEVING mediaItems: %@",[error localizedDescription]);
        }
    }
    
    
}
// notification can be delivered multiple times to be sure not to allow the trigger multiple times
- (void) published:(NSNotification*) buildID{
    
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUploading"] != YES){
    NSDictionary *myDictionary = [buildID userInfo];
    NSString * idForBuild = [myDictionary valueForKey:@"buildID"];
    NSArray *emails = [myDictionary valueForKey:@"emails"];
       
    // save this a reference to the last uploaded buildID so it can be re-launched the next time if it quits
    [[NSUserDefaults standardUserDefaults] setValue:idForBuild forKey:@"lastUploadingBuildID"];
    [[NSUserDefaults standardUserDefaults] setValue:emails forKey:@"lastUploadingEmails"];
    
    self.uploader = nil;
    Build * newBuild = [self getBuild:idForBuild];
    
        
    //if(self.isReachable){
        if(newBuild != nil){
            [newBuild setStatus:@"uploading"];// set the status to uploading
            NSError *err = nil;
            [self.managedObjectContext save:&err];
            if(!err){
                [self startUploadProcessWithBuild:newBuild withDistroEmails:emails];
            }else{
                [newBuild setStatus:@"edit"];// set the status to edit
                NSError *err2 = nil;
                [self.managedObjectContext save:&err2];
                if(!err2){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable to retrieve your event" message:[err2 localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }
            
        }else{
            NSLog(@"problem retrieving build");
        }
//        }else{
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Unavailable" message:@"Unable to upload, no network available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alertView show];
//        
//       
//        }
    }

    
}
// get a build with the id provided
-(Build*) getBuild:(NSString*) buildID{
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Build" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"buildID == %@",buildID];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    // each of these is actually a buildItem rather than a media item, but the media items are part of each BuildItem so they can be brought in
    
    NSArray *builds = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:request error:&error]];
    
    if(error == nil){
        
        
        return ([builds count] >0) ? [builds objectAtIndex:0]:nil;
    }else{
        return nil;
    }
}
// creates a dictionary and adds an array of items to the dictionary to create the JSON data
- (NSData*) generateJSONFromBuild:(Build*)b withItems:(NSArray*)buildItems andEmails:(NSArray*)emails{
    // get the date
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    NSString *creationDateString = [formatter stringFromDate:b.dateCreated];
    // this builds a hierarchy with the main node being the build and the items string data making up the rest
    NSDictionary *metaDataDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:creationDateString, @"buildCreationDate",nil];
    
    // initialize the dictionary that we'll use to add the items to
    NSMutableDictionary *buildDictionary = [[NSMutableDictionary alloc] initWithDictionary:metaDataDictionary];
    // create an array to store the items
    NSMutableArray * itemArray = [[NSMutableArray alloc] init];
    // roll through the items and extract what's needed and add each to the array
    for (BuildItem * b in buildItems) {
        NSString * screenTitle = b.title;
        NSString * screenID = b.buildItemID;
        NSString * itemType = b.type;
        NSString * screenText = b.caption;
        NSDictionary *itemDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:screenTitle,@"screenTitle",screenID,@"screenID",itemType,@"itemType",screenText,@"screenText", nil];
        [itemArray addObject:itemDictionary];
        
    }
    // add the item array to the buildDictionary
    b.applicationID = (b.applicationID != nil) ? b.applicationID : 0;
    NSLog(@"%@",b.applicationID);
    [buildDictionary setObject:b.applicationID forKey:@"applicationID"];
    [buildDictionary setObject:itemArray forKey:@"buildItems"];
    [buildDictionary setObject:emails forKey:@"distroEmails"];
    [buildDictionary setObject:b.buildID forKey:@"buildID"];
    [buildDictionary setObject:b.buildDescription forKey:@"buildDescription"];
    [buildDictionary setObject:b.title forKey:@"buildTitle"];
    NSError *error;
    // create json data
    NSData *buildData = [NSJSONSerialization dataWithJSONObject:buildDictionary options:0 error:&error];
    
    NSString *stringData = [[NSString alloc] initWithData:buildData encoding:NSUTF8StringEncoding];
    
    if(!error){
        NSLog(@"jsonData: %@",stringData );
        return buildData;
    }else {
        return nil;
    }
    
}
// incomplete - finish
#pragma mark - uploads
- (void) addItemsToUploadObjects:(NSMutableArray *)mediaItems{
    
    [self.uploadObjects addObject:mediaItems];
    
}

- (NSArray*) getUploadObjectsAtIndex:(NSUInteger)uploadIndex{
    return [self.uploadObjects objectAtIndex:uploadIndex];
}

-(void)uploadDidCompleWithBuildInfo:(NSDictionary *)buildDictionary{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.uploader = nil;
    
    Build *b = [self getBuild:[buildDictionary objectForKey:@"buildID"]];
    
    b.status = @"edit";
    b.publishDate = [NSDate date];// this is set to the device's date and time, in the long run, this should be set and returned from the server
    
    NSError *err = nil;
    
    [self.managedObjectContext save:&err];

    if(!err){
        
         [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadComplete" object:nil userInfo:[NSDictionary dictionaryWithObject:[buildDictionary objectForKey:@"buildID"] forKey:@"buildID"]];
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error saving" message:@"Could not save your upload session" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
   
    [[NSUserDefaults standardUserDefaults] setValue:@"NO" forKey:@"isUploading"];// set defaults to no
    [[NSUserDefaults standardUserDefaults] setValue:0 forKey:@"uploadIndex"];// set upload indext to 0
    // kill the values for the emails and buildID
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"lastUploadingBuildID"];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"lastUploadingEmails"];

}

-(void)uploadDidFailWithReason:(NSString *)reason andID:(NSString*)buildID{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.uploader stopUpload];
    self.uploader = nil;
    
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Upload Error" message:[NSString stringWithFormat:@"An error occured while uploading your files. Try again? Error:%@",reason] delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [errorAlert show];
    
}

-(void) uploadWasCancelledForID:(NSString *)buildID{
  
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.uploader = nil;
    
    Build *b = [self getBuild:buildID];
    
    b.status = @"edit";
    
    NSError *err = nil;
    
    [self.managedObjectContext save:&err];
    
    if(!err){
          [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadAborted" object:nil userInfo:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Stopping your upload" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }

    
    
    
    
    
}

// UploadControl delegate
- (void) stopUpload{
    [self.uploader cancelUpload];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{

}

- (void) alertViewCancel:(UIAlertView *)alertView{
    
}


#pragma mark - Application lifecycle methods

- (void)applicationWillResignActive:(UIApplication *)application
{
    // if an upload is currently active, pause the upload
    
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUploading"] == YES){
        if(self.uploader){
            [self.uploader stopUpload];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUploading"] == YES){
        if(self.uploader){
            [self.uploader stopUpload];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // same as for active status
    
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUploading"] == YES){
        if(self.uploader){
            [self.uploader resumeUpload];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // if there is an upload to complete, make sure you can get it and then resume the upload
    
    
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUploading"] == YES){
        if(self.uploader){
            [self.uploader resumeUpload];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // stop the upload process and clean up. Make sure to store all relevant user settings
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUploading"] == YES){
        [self.uploader stopUpload];// stop the upload process
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ITM_version_0_0_1" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ITM_version_0_0_1.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
