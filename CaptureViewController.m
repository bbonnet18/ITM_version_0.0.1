//
//  CaptureViewController.m
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 10/15/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import "CaptureViewController.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)// reference to the bgQueue


@interface CaptureViewController ()
-(NSString*) getOrientation:(UIImage*)img;// helper to check the orientation to determine if it's not up
-(UIImage*) rotateThumbnail;// gets the thumbnail image and rotates it

@end

@implementation CaptureViewController
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // this notification is from the video save process
    UIImage* rotateImg = [UIImage imageNamed:@"rotate-right.png"];
    

    CGRect btnRect = self.rotateBtn.frame;
    [self.rotateBtn removeFromSuperview];
    self.rotateBtn = [UIButton createButtonWithImage:rotateImg color:[UIColor colorWithRed:0.09 green:0.49 blue:0.56 alpha:1.0] title:@"rotate"];
    self.rotateBtn.frame = CGRectMake(btnRect.origin.x+10.0, btnRect.origin.y+10.0, self.rotateBtn.frame.size.width, self.rotateBtn.frame.size.height);
    [self.rotateBtn addTarget:self action:@selector(rotate:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.rotateBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedWritingImage:) name:@"VideoSaved" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    // Do any additional setup after loading the view from its nib.
    [self populate];
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

// populate the values on the screen and load the thumb and preview button
- (void) populate{
    
    if([[Utilities sharedInstance] checkValidString:[self.buildItemVals valueForKey:@"title"]]){
        self.titleTxt.text = [self.buildItemVals valueForKey:@"title"];
    }
    if([[Utilities sharedInstance] checkValidString:[self.buildItemVals valueForKey:@"caption"]]){
        self.captionTxt.text = [self.buildItemVals valueForKey:@"caption"];
    }
    if([[Utilities sharedInstance] checkValidString:[self.buildItemVals valueForKey:@"timeStamp"]]){
        self.timeStampTxt.text = [self.buildItemVals valueForKey:@"timeStamp"];
    }
    UIImage *thumbnailImage = [self getThumbnail:[self.buildItemVals valueForKey:@"thumbnailPath"]];
    if(thumbnailImage == nil){
        [self loadPlaceholderThumb];
    }else{
        [self showImageInThumb:thumbnailImage];
    }// build a preview button if the type is not nil
    if([[Utilities sharedInstance] checkValidString:[self.buildItemVals valueForKey:@"type"]]){
        // if there's a type, then it can be previewed
        [self showPreviewBtn];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

-(IBAction)imageCapture:(id)sender{
    // create the UIImagePickerController and set this ViewController as it's delegate, then declare the source types, media types and editing preferences
    
    // check to see if the camera is on the device
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        // create the UIImagePickerController and set this ViewController as it's delegate, then declare the source types, media types and editing preferences
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage, nil];// including <MobileCoreServices/MobileCoreServices.h> with the header file is what allows us to use kUTTypeImage
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:^{
            
        }];
    }

}

-(IBAction)videoCapture:(id)sender{
    // create the UIImagePickerController and set this ViewController as it's delegate, then declare the source types, media types and editing preferences
    
    // check to see if the camera is on the device
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        // create the UIImagePickerController and set this ViewController as it's delegate, then declare the source types, media types and editing preferences
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.videoMaximumDuration = 60.0;
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeMovie, nil];// including <MobileCoreServices/MobileCoreServices.h> with the header file is what allows us to use kUTTypeImage
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:^{
            
        }];
    }

}



-(IBAction)useLibrary:(id)sender{
    // check to see if the camera roll is available on this device
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        // just like the previous, create the imagePicker, set this as it's delegate and set the sourceType to the camera roll, then allow images as the media type and specify no for editing, and present the new view controller modally
        
//#if TARGET_IPHONE_SIMULATOR
//        
//#else
//        
//#endif
//
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie,kUTTypeImage, nil];
        imagePicker.videoMaximumDuration = 60.0;// set max duration to prevent videos that are too long
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:^{
            
        }];
        
    }
    
    
}


#pragma mark - UIImagePickerControllerDelegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    // setup the activity indicator
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // dismiss the modal picker snatcher view
    // check to see if the media is an image
    
    [self.indicator startAnimating];
    
    // if it's a movie, save the movie
    if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){

        
        NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL]path];
        if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)){
            NSURL *u = [info objectForKey:UIImagePickerControllerMediaURL];
            if(picker.sourceType != UIImagePickerControllerSourceTypePhotoLibrary){
//            // save it to the library if compatible
                [self saveVideoToLibrary:info];
            
            }else{
           // just get the url and save it to the values dictionary
                NSURL *assetURL = [info valueForKey:UIImagePickerControllerReferenceURL];
                NSString *urlStr = [assetURL absoluteString];
                [self.buildItemVals setValue:urlStr forKey:@"mediaPath"];
                [self.buildItemVals setValue:@"video" forKey:@"type"];
                NSLog(@"videoPath: %@",[self.buildItemVals valueForKey:@"mediaPath"]);
           
                [self buildThumb:assetURL];
            }
        }
        
    }
    // if it's an image, save the image
    else if([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
        // from the camera
        if(picker.sourceType != UIImagePickerControllerSourceTypePhotoLibrary){
            
            UIImage *imgToUse = [info objectForKey:UIImagePickerControllerEditedImage];
            if(imgToUse == NULL){
                imgToUse = [info objectForKey:UIImagePickerControllerOriginalImage];
            }
            [self saveImageToLibrary:imgToUse];
        }else{
            NSURL *assetURL = [info valueForKey:UIImagePickerControllerReferenceURL];
            [self.buildItemVals setValue:[assetURL absoluteString] forKey:@"mediaPath"];
            [self.buildItemVals setValue:@"image" forKey:@"type"];
            [self performSelectorOnMainThread:@selector(saveThumb:) withObject:assetURL waitUntilDone:NO];
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}


// save your items to the library
- (void) saveVideoToLibrary:(NSDictionary*)userInfo{

    NSString *moviePath = [[userInfo objectForKey:UIImagePickerControllerMediaURL]path];
    if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)){
        NSURL *u = [userInfo objectForKey:UIImagePickerControllerMediaURL];
        
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        [lib writeVideoAtPathToSavedPhotosAlbum:u completionBlock:^(NSURL *assetURL, NSError *error) {
            NSLog(@"url from lib: %@", assetURL);
            if(error == nil){
                [self.buildItemVals setValue:[assetURL absoluteString] forKey:@"mediaPath"];
                [self.buildItemVals setValue:@"video" forKey:@"type"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoSaved" object:self userInfo:nil];
            }else{
                NSLog(@"there was an saving the item error: %@",[error localizedDescription]);
                [self.indicator stopAnimating];
            }
            
        }];
    }
}
// helper converter method, this is probably not necessary, because I could cast it to an integer, but
// I wasn't able to discern that from the documentation, don't know what type the UIImageOrientation Const is
// takes an image and saves it to the library
- (void) saveImageToLibrary:(UIImage*)imgToUse{
   
    CGImageRef ref = imgToUse.CGImage;
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];

    [lib writeImageToSavedPhotosAlbum:ref orientation:imgToUse.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        
        if(!error){
            [self.buildItemVals setValue:[assetURL absoluteString] forKey:@"mediaPath"];
            [self.buildItemVals setValue:@"image" forKey:@"type"];
            // call the save method to save the actual image to the directory
            [self performSelectorOnMainThread:@selector(saveThumb:) withObject:assetURL waitUntilDone:NO];
        }else{
            UIAlertView *errorSaving = [[UIAlertView alloc] initWithTitle:@"Save Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [errorSaving show];

        }
        
    }];
    
    
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - textField delegate methods

-(BOOL) textFieldShouldEndEditing:(UITextField *)textField{
    if(textField.tag != 8){
        self->_activeField = nil;
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"tag: %i",textField.tag);
    if(textField.tag != 8){
        self->_activeField = textField;
        return YES;
    }else{
        
        [textField resignFirstResponder];// resign it because we are launching the editor
        [self editCaption:textField];
        return NO;
    }
        
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    self->_activeField = nil;
    [textField resignFirstResponder];
    
    return YES;
}

// this is for video only, and it will create and save a thumbnail for the video
- (void) finishedWritingImage:(NSNotification*)notification{
    // saved video is ready to access, so access it
    AVURLAsset *assetToUse = [[AVURLAsset alloc] initWithURL:[self.buildItemVals valueForKey:@"mediaPath"] options:nil];
    NSArray *keys = [NSArray arrayWithObject:@"duration"];
    // as this loads, check the duration. If the duration is there, then it's loaded
    [assetToUse loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        NSError *error  = nil;
        AVKeyValueStatus trackStatus = [assetToUse statusOfValueForKey:@"duration" error:&error];
        if(error != nil){
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error obtaining duration" message:@"Error obtaining the duration of the video" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [errorAlert show];
        }else{
            //             AVURLAsset *newAsset = [[AVURLAsset alloc] initWithURL:[self.buildItemVals valueForKey:@"mediaPath"] options:nil];
            switch (trackStatus) {
                case AVKeyValueStatusLoaded:
                    // make sure the  asset is loaded, if it is, then build the thumb
                    NSLog(@"loaded the duration");
                    if([[NSThread currentThread] isMainThread]){
                        //[self performSelector:@selector(loadPlaceholderThumb) withObject:nil];
                        NSString *str = [self.buildItemVals valueForKey:@"mediaPath"];
                        NSURL *assetURL = [NSURL URLWithString:str];
                        [self performSelector:@selector(buildThumb:) withObject:assetURL];
                    }else{
                        NSString* newURL = [self.buildItemVals valueForKey:@"mediaPath"];
                         NSURL *newassetURL = [NSURL URLWithString:newURL];
                        [self performSelectorOnMainThread:@selector(buildThumb:) withObject:newassetURL waitUntilDone:YES];
                    }
                    break;
                case AVKeyValueStatusFailed:
                    NSLog(@"failed to save");
                    break;
                case AVKeyValueStatusLoading:
                    NSLog(@"still loading...");
                case AVKeyValueStatusCancelled:
                    NSLog(@"the duration operation was cancelled");
                default:
                    break;
            }
            
        }
    }];
}

// this method will build the thumbnail image for the video
- (void) buildThumb:(NSURL*)assetURL{
 
            AVAsset *assetToUse =  (AVAsset*)[[AVURLAsset alloc] initWithURL:assetURL options:nil];
            Float64 durationSeconds = CMTimeGetSeconds([assetToUse duration]);
            CMTime startPoint = CMTimeMake(durationSeconds/2.0,600);
            CMTime actualTime;
            NSError *e = nil;
            // get the date
            NSString* createDate = [self getTimeStamp:[assetToUse.creationDate dateValue] ];
            self.timeStampTxt.text = createDate;
            [self.buildItemVals setValue:createDate forKey:@"timeStamp"];
    
            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:assetToUse];
    
            CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:startPoint actualTime:&actualTime error:&e];
    
            NSString* play  = (assetToUse.playable) ? @"YES":@"NO";
            NSString* read =  (assetToUse.readable) ? @"YES":@"NO";
            
    NSLog(@"playable: %@  readable: %@",play,read);
    
            if(e){
                NSLog(@"%@ - %@ %@ %@",[e localizedDescription], [e localizedFailureReason], [e localizedRecoveryOptions], [e localizedRecoverySuggestion]);
                [self loadPlaceholderThumb];
                
            }
            // if the image was created successfully, then save it 
            if(halfWayImage != NULL){
                //  these variables are for logging the requested vs actual time strings
                NSString *actualTimeString = (__bridge NSString*)CMTimeCopyDescription(NULL, actualTime);
                NSString *requestedTimeString = (__bridge NSString*)CMTimeCopyDescription(NULL, startPoint);
                NSLog(@"requested time %@, actual time%@", requestedTimeString, actualTimeString);
                UIImage* imageToUse = [UIImage imageWithCGImage:halfWayImage];
                
                if(UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])){// done to correct video taken with the image orientation set to portrait, this will automatically assign a rotated orientation 
                    imageToUse = [UIImage imageWithCGImage:halfWayImage scale:1.0 orientation:UIImageOrientationRight];
                }
                
                [self removeOldThumbAndWriteNew:imageToUse];
                NSLog(@" the thing was made");
            }
            
            NSLog(@"created the video thumb");
    
}
// shows the creation timestamp in the timestamp label
- (NSString*) getTimeStamp:(NSDate*)assetCreationDate{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];// want short time
    [formatter setDateStyle:NSDateFormatterMediumStyle];// just want the months and the day
    NSString* dateString = [formatter stringFromDate:assetCreationDate];
    return dateString;
//    self.timeStampTxt.text = dateString;
//    [self.buildItemVals setValue:creationDateString forKey:@"timeStamp"];
   
}

- (void) loadPlaceholderThumb{
    
    UIImage* placeholder = [UIImage imageNamed:@"rounded_placeholderNew.png"];
    self.previewImageView.image = placeholder;
    [self.indicator stopAnimating];
}

// used for images only
-(void) saveThumb:(NSURL *)assetURL{
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    [lib assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        //UIImage *thumb = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];//
        
        NSDate *createDate = (NSDate*)[asset valueForProperty:ALAssetPropertyDate];
        //get this image and make it's orientation up
        NSString *creationDateString = [self getTimeStamp:createDate];
        self.timeStampTxt.text = creationDateString;
        [self.buildItemVals setValue:creationDateString forKey:@"timeStamp"];
        UIImage *preview = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage] scale:1.0 orientation:UIImageOrientationUp];
        
        
        //[self performSelectorOnMainThread:@selector(saveNewImage:) withObject:preview waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(removeOldThumbAndWriteNew:) withObject:preview waitUntilDone:NO];

    } failureBlock:^(NSError *error) {
        NSLog(@"Error on save: %@", [error localizedDescription]);
    }];
    
}

// just show the image in the thumbnail
-(void)showImageInThumb:(UIImage *)img{
    self.previewImageView.image = img;
    [self.indicator stopAnimating];
    
}



// removes the old thumbnail if there was one and creates a new one
- (void) removeOldThumbAndWriteNew:(UIImage*)img{
    
    dispatch_async(kBgQueue, ^{
        //this one has a thumbnail already, so delete it
        
        NSString * pathToThumb = [self.buildItemVals valueForKey:@"thumbnailPath"];
        // make sure it's not null
        if([[Utilities sharedInstance] checkValidString:pathToThumb]){
            NSLog(@"path is not null");
            NSError *error;
            NSFileManager *mgr = [NSFileManager defaultManager];
            if ([mgr removeItemAtPath:[self.buildItemVals valueForKey:@"thumbnailPath"] error:&error] != YES){
                UIAlertView *errorDeleting = [[UIAlertView alloc] initWithTitle:@"Delete Error" message:@"Unable to delete previous thumbnail." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [errorDeleting show];
            }

        }
       
        NSLog(@"--- IMG ORIENTATION %@",[self getOrientation:img]);
        
        // create the path  and URL for the new thumbnail image, then write it to the home directory
        NSString *imageName = [NSString stringWithFormat:@"thumb_%@",[self.buildItemVals valueForKey:@"buildItemID"]];
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.jpg",imageName]];
        NSURL *url = [NSURL fileURLWithPath:path];
        [self.buildItemVals setValue:path forKey:@"thumbnailPath"];
        
        
        UIImage * scaledImage = [img thumbnailImage:280 transparentBorder:1 cornerRadius:15 interpolationQuality:0];
        [UIImageJPEGRepresentation(scaledImage, 0.75f) writeToURL:url atomically:YES];
        // show that image in the imageView
        [self performSelectorOnMainThread:@selector(showImageInThumb:) withObject:scaledImage waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(showPreviewBtn) withObject:nil waitUntilDone:NO];
    });
}
// gets a reference to the thumbnail image stored in the app and returns it or nil
-(UIImage*) getThumbnail:(NSString*) thumbnailPath{
    // get the url
    
    if([[Utilities sharedInstance] checkValidString:thumbnailPath]){
        NSURL *imgURL = [NSURL URLWithString:thumbnailPath];
        if(imgURL != nil){
            UIImage *thumbnailImage = [UIImage imageWithContentsOfFile:[imgURL path]];
            return thumbnailImage;
        }
        return nil;
    }
    return nil;
}
-(void)showPreviewBtn{
    if([[self.buildItemVals valueForKey:@"type"] isEqualToString:@"video"]){// only show the preview if it's a video
    // if it's nil, then show it
        if(self.previewBtn == nil){
            self.previewBtn = [self buildPreviewButton];// build the preview button so the preview can happen
            if(self.previewBtn != nil){
                [self.scroller addSubview:self.previewBtn];
            }
        }
    }else{
        self.previewBtn = nil;
    }
    

}

// creates a preview button so we can preview the media
- (UIButton*) buildPreviewButton{
    UIButton* previewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    //[previewButton setTitle:@"Preview" forState:UIControlStateNormal];
    UIImage *prevImg = [UIImage imageNamed:@"Video-play-button.png"];
    [previewButton setBackgroundImage:prevImg forState:UIControlStateNormal];// use the new background image
    [previewButton sizeToFit];
    
    [previewButton addTarget:self action:@selector(preview) forControlEvents:UIControlEventTouchUpInside];
    
    CGPoint location = CGPointMake(self.scroller.center.x - previewButton.frame.size.width/2, self.scroller.center.y - previewButton.frame.size.height/2);
    CGRect newFrame = CGRectMake(location.x, location.y, previewButton.frame.size.width, previewButton.frame.size.height);
    previewButton.frame = newFrame;
    if(previewButton != nil){
        return previewButton;
    }
    return nil;
}
// check to see if the string is valid
-(BOOL) checkValidString:(NSString*) str{
    BOOL isValid = YES;// will change to no if any part is invalid
    if(![str isEqualToString:@""])
        isValid = NO;
    if(![str isEqual:[NSNull null]])
         isValid = NO;
    if(![str isMemberOfClass:[NSString class]])
         isValid = NO;
         
         return isValid;
}

// this method is used to attach to the button and will launch the preview based on the type and the media path
- (void)preview{
    
    if([[Utilities sharedInstance]  checkValidString:[self.buildItemVals valueForKey:@"type"]]){
        NSString *type = [self.buildItemVals valueForKey:@"type"];
        if([type isEqualToString:@"video"]){
            NSLog(@"buildItem.mediaPath: %@", [self.buildItemVals valueForKey:@"mediaPath"]);
            if([[Utilities sharedInstance]  checkValidString:[self.buildItemVals valueForKey:@"mediaPath"]]){
                NSURL *vidURL = [NSURL URLWithString:[self.buildItemVals valueForKey:@"mediaPath"]];
                MPMoviePlayerViewController *mpvc = [[MPMoviePlayerViewController alloc] initWithContentURL:vidURL];
                [mpvc shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientationPortrait == UIInterfaceOrientationLandscapeLeft)];
                
                [self presentMoviePlayerViewControllerAnimated:mpvc];
                
            }

        }        
    }
}






- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
   
}

- (void) alertViewCancel:(UIAlertView *)alertView{
   
}

#pragma mark - ScreenTextEditor protocol

-(void)didFinishEditingText:(NSString *)editedText{
    [self.buildItemVals setValue:editedText forKey:@"caption"];
    self.captionTxt.text = editedText;
}
-(void) setDidFinishEditing:(BOOL)isFinished{
    
}


#pragma mark - save and cancel methods

- (IBAction)save:(id)sender{
    [self.buildItemVals setValue:self.titleTxt.text forKey:@"title"];
     [self.buildItemVals setValue:self.captionTxt.text forKey:@"caption"];
     [self.buildItemVals setValue:self.timeStampTxt.text forKey:@"timeStamp"];
    
    // NEED to set the values in the buildItemVals dictionary to the values on the screen and in the values
    
    if([[Utilities sharedInstance] checkValidString:[self.buildItemVals valueForKey:@"title"]] && [[Utilities sharedInstance]  checkValidString:[self.buildItemVals valueForKey:@"caption"]] && [[Utilities sharedInstance]  checkValidString:[self.buildItemVals valueForKey:@"timeStamp"]] && [[Utilities sharedInstance]  checkValidString:[self.buildItemVals valueForKey:@"mediaPath"]] && [[Utilities sharedInstance]  checkValidString:[self.buildItemVals valueForKey:@"type"]] && [[Utilities sharedInstance]  checkValidString:[self.buildItemVals valueForKey:@"thumbnailPath"]] ){
        [self.delegate didEditItemWithDictionary:self.buildItemVals];
        
    }else{
        UIAlertView *errorSaving = [[UIAlertView alloc] initWithTitle:@"Save Error" message:@"Make sure to enter all information" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [errorSaving show];
    }
}




- (IBAction)cancel:(id)sender{
    [self.delegate didCancelEditProcess];
}


#pragma mark - keyboard methods

- (void)showKeyboard:(NSNotification*)note
{
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scroller.contentInset = contentInsets;
    self.scroller.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self->_activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self->_activeField.frame.origin.y-kbSize.height);
        [self.scroller setContentOffset:scrollPoint animated:YES];
    }
}



// Called when the UIKeyboardWillHideNotification is sent
- (void)hideKeyboard:(NSNotification*)note
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scroller.contentInset = contentInsets;
    self.scroller.scrollIndicatorInsets = contentInsets;
}

// helper to determine orientation
-(NSString*)getOrientation:(UIImage *)img
{
switch (img.imageOrientation) {
    case UIImageOrientationDown:           // EXIF = 3
    case UIImageOrientationDownMirrored:   // EXIF = 4
        return [NSString stringWithFormat:@"DOWN %f x %f",img.size.width,img.size.height];
        break;
        
    case UIImageOrientationLeft:           // EXIF = 6
    case UIImageOrientationLeftMirrored:   // EXIF = 5
        return [NSString stringWithFormat:@"LEFT %f x %f",img.size.width,img.size.height];
        break;
        
    case UIImageOrientationRight:          // EXIF = 8
    case UIImageOrientationRightMirrored:  // EXIF = 7
        return [NSString stringWithFormat:@"RIGHT %f x %f",img.size.width,img.size.height];
        break;
}

switch (img.imageOrientation) {
    case UIImageOrientationUpMirrored:     // EXIF = 2
    case UIImageOrientationDownMirrored:   // EXIF = 4
        return [NSString stringWithFormat:@"UP/DOWN MIRRORED %f x %f",img.size.width,img.size.height];
        break;
        
    case UIImageOrientationLeftMirrored:   // EXIF = 5
    case UIImageOrientationRightMirrored:  // EXIF = 7
        return [NSString stringWithFormat:@"LEFT/RIGHT MIRRORED %f x %f",img.size.width,img.size.height];
        break;
    case UIImageOrientationUp: // EXIF = 1
        return [NSString stringWithFormat:@"UP %f x %f",img.size.width,img.size.height];
}
    return @"UP or UNKNOWN";
}

-(IBAction)rotate:(id)sender{
    UIImage* img = [self rotateThumbnail];
    [self removeOldThumbAndWriteNew:img]; 
}

-(UIImage*) rotateThumbnail{
    
    UIImage *thumb = self.previewImageView.image;
    CGImageRef imgRef = thumb.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);// get the width to use for all
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, width,width, CGImageGetBitsPerComponent(imgRef), 0, CGImageGetColorSpace(imgRef), CGImageGetBitmapInfo(imgRef));
    // get the current transform
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0, width);// translate the origin
    
    transform = CGAffineTransformRotate(transform, DegreesToRadians(-90.0));// rotates the context
    
    CGContextConcatCTM(bitmapContext, transform);// concatinate the transforms so they take place
    CGContextSetInterpolationQuality(bitmapContext, kCGInterpolationDefault);
    CGContextDrawImage(bitmapContext, CGRectMake(0, 0, width, width), imgRef);// draw the image in the rotated context
    CGImageRef newImg = CGBitmapContextCreateImage(bitmapContext);// create the new version
    UIImage* newRotated = [UIImage imageWithCGImage:newImg];// get a UIImage to put in the previewImageView;
    
    // update the buildItemVals' imageRotation value to reflect the change
    NSNumber * rotation = [self.buildItemVals valueForKey:@"imageRotation"];
    NSInteger rotationValue = [rotation integerValue];
    rotationValue -= 90;
    rotationValue = (rotationValue > -360) ? rotationValue : 0;
    [self.buildItemVals setValue:[NSNumber numberWithInteger:rotationValue] forKey:@"imageRotation"];// set the buildItemVals value to the new imageRotation
    CGContextRelease(bitmapContext);
    CGImageRelease(newImg);
    
    return newRotated;

}

CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
};

CGFloat RadiansToDegrees(CGFloat radians)
{
    return radians * 180 / M_PI;
};

- (IBAction)editCaption:(id)sender{
    TextEntryViewController *tv = [[TextEntryViewController alloc] initWithNibName:@"TextEntryViewController" bundle:[NSBundle mainBundle]];
    tv.delegate = self;
    
    NSString *txt = ([[Utilities sharedInstance] checkValidString:[self.buildItemVals valueForKey:@"caption"]]) ? [self.buildItemVals valueForKey:@"caption"] : @"";
    tv.textToEdit = txt;
    [self presentViewController:tv animated:YES completion:^{
        
    }];
}


@end