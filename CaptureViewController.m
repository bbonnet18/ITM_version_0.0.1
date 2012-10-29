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

@end

@implementation CaptureViewController
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.utils = [[Utilities alloc] init];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // this notification is from the video save process
    
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
    
    if([self.utils checkValidString:[self.buildItemVals valueForKey:@"title"]]){
        self.titleTxt.text = [self.buildItemVals valueForKey:@"title"];
    }
    if([self.utils checkValidString:[self.buildItemVals valueForKey:@"caption"]]){
        self.captionTxt.text = [self.buildItemVals valueForKey:@"caption"];
    }
    if([self.utils checkValidString:[self.buildItemVals valueForKey:@"timeStamp"]]){
        self.timeStampTxt.text = [self.buildItemVals valueForKey:@"timeStamp"];
    }
    UIImage *thumbnailImage = [self getThumbnail:[self.buildItemVals valueForKey:@"thumbnailPath"]];
    if(thumbnailImage == nil){
        [self loadPlaceholderThumb];
    }else{
        [self showImageInThumb:thumbnailImage];
    }// build a preview button if the type is not nil
    if([self.utils checkValidString:[self.buildItemVals valueForKey:@"type"]]){
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
       
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie,kUTTypeImage, nil];
        //imagePicker.videoMaximumDuration = 60.0;// set max duration to prevent videos that are too long
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

-(void) textFieldDidEndEditing:(UITextField *)textField{
    self->_activeField = nil;
    [textField resignFirstResponder];
}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    self->_activeField = textField;
    
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
    //NSURL *assetURL = [NSURL fileURLWithPath:[self.buildItemVals valueForKey:@"mediaPath"]];//[self.buildItemVals valueForKey:@"mediaPath"];
   // NSArray* keys = [NSArray arrayWithObjects:AVURLAssetPreferPreciseDurationAndTimingKey,AVURLAssetReferenceRestrictionsKey, nil];
   // NSArray* objs = [NSArray arrayWithObjects:YES,AVAssetReferenceRestrictionForbidNone, nil];
    //NSDictionary *options = @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
    
    //THE PROBLEM IS:
    
    //The urlStr below cannot be initialized when providing the assetURL from the captured video, it can only be initialized when coming from the library for some reason, even though the asset is being initialized from the same mediaPath variable
    
    // the problem may be due to the timing of it for some reason, it may not be able to get the duration yet?? 
    
//    NSString* newURLStr = [self.buildItemVals valueForKey:@"mediaPath"];
//    NSURL *newURL = [NSURL URLWithString:newURLStr];
//    
//    NSString* url1Str = [newURL absoluteString];
//    NSString* path1 = [newURL path];
//    NSString* full1 = [newURL pathExtension];
//    
//    NSLog(@"URL 1--- %@",url1Str);
//    NSLog(@"absolute 1---%@",path1);
//    NSLog(@"full 1---- %@",full1);
//    
//    NSString* urlStr = [assetURL absoluteString];
//    NSString* path = [assetURL path];
//    NSString* full = [assetURL pathExtension];
//    
//    NSLog(@"URL --- %@",urlStr);
//    NSLog(@"absolute ---%@",path);
//    NSLog(@"full ---- %@",full);
            AVAsset *assetToUse =  (AVAsset*)[[AVURLAsset alloc] initWithURL:assetURL options:nil];
            Float64 durationSeconds = CMTimeGetSeconds([assetToUse duration]);
            CMTime startPoint = CMTimeMake(durationSeconds/2.0,600);
            CMTime actualTime;
            NSError *e = nil;
            NSDate* d = [assetToUse.creationDate dateValue];
            NSString *creationDateString = [[assetToUse.creationDate dateValue] description];
            self.timeStampTxt.text = creationDateString;
            [self.buildItemVals setValue:creationDateString forKey:@"timeStamp"];
    
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
                [self removeOldThumbAndWriteNew:imageToUse];
                NSLog(@" the thing was made");
            }
            
            NSLog(@"created the video thumb");
    
}
// shows the creation timestamp in the timestamp label
- (void) showTimeStamp:(NSURL*)assetURL{
    
    AVAsset *assetToUse =  (AVAsset*)[[AVURLAsset alloc] initWithURL:assetURL options:nil];
    NSDate *creationDate = assetToUse.creationDate;
    NSString *creationDateString = [assetToUse.creationDate stringValue];
    self.timeStampTxt.text = creationDateString;
    [self.buildItemVals setValue:creationDateString forKey:@"timeStamp"];
   
}

- (void) loadPlaceholderThumb{
    
    UIImage* placeholder = [UIImage imageNamed:@"placeholder1.jpg"];
    self.previewImageView.image = placeholder;
    [self.indicator stopAnimating];
}

// used for images only
-(void) saveThumb:(NSURL *)assetURL{
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    [lib assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        //UIImage *thumb = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];//
        
        //get this image and make it's orientation up
        NSDate *date = [NSDate date];
        NSLog(@"date desc: %@",[date description]);
        NSString *creationDateString = date.description;
        self.timeStampTxt.text = creationDateString;
        [self.buildItemVals setValue:creationDateString forKey:@"timeStamp"];
        UIImage *preview = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage] scale:1.0 orientation:UIImageOrientationUp];
        
        NSLog(@" saved image orientation: %d",preview.imageOrientation);
        
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
        if([self.utils checkValidString:pathToThumb]){
            NSLog(@"path is not null");
            NSError *error;
            NSFileManager *mgr = [NSFileManager defaultManager];
            if ([mgr removeItemAtPath:[self.buildItemVals valueForKey:@"thumbnailPath"] error:&error] != YES){
                UIAlertView *errorDeleting = [[UIAlertView alloc] initWithTitle:@"Delete Error" message:@"Unable to delete previous thumbnail." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [errorDeleting show];
            }

        }
        
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
    
    if([self.utils checkValidString:thumbnailPath]){
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
    // if it's nil, then show it
    if(self.previewBtn == nil){
        self.previewBtn = [self buildPreviewButton];// build the preview button so the preview can happen
        if(self.previewBtn != nil){
            [self.view addSubview:self.previewBtn];
        }
    }
    
    

}

// creates a preview button so we can preview the media
- (UIButton*) buildPreviewButton{
    UIButton* previewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [previewButton setTitle:@"Preview" forState:UIControlStateNormal];
    [previewButton sizeToFit];
    
    [previewButton addTarget:self action:@selector(preview) forControlEvents:UIControlEventTouchUpInside];
    
    CGPoint location = CGPointMake(self.view.center.x - previewButton.frame.size.width/2, self.view.center.y - previewButton.frame.size.height/2);
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
    
    if([self.utils checkValidString:[self.buildItemVals valueForKey:@"type"]]){
        NSString *type = [self.buildItemVals valueForKey:@"type"];
        if([type isEqualToString:@"video"]){
            NSLog(@"buildItem.mediaPath: %@", [self.buildItemVals valueForKey:@"mediaPath"]);
            if([self.utils checkValidString:[self.buildItemVals valueForKey:@"mediaPath"]]){
                NSURL *vidURL = [NSURL URLWithString:[self.buildItemVals valueForKey:@"mediaPath"]];
                MPMoviePlayerViewController *mpvc = [[MPMoviePlayerViewController alloc] initWithContentURL:vidURL];
                [mpvc shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientationPortrait == UIInterfaceOrientationLandscapeLeft)];
                
                [self presentMoviePlayerViewControllerAnimated:mpvc];
                
            }

        }else if([type isEqualToString:@"image"]){
            
        }
        
    }
}






- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
   
}

- (void) alertViewCancel:(UIAlertView *)alertView{
   
}
#pragma mark - save and cancel methods

- (IBAction)save:(id)sender{
    [self.buildItemVals setValue:self.titleTxt.text forKey:@"title"];
     [self.buildItemVals setValue:self.captionTxt.text forKey:@"caption"];
     [self.buildItemVals setValue:self.timeStampTxt.text forKey:@"timeStamp"];
    
    // NEED to set the values in the buildItemVals dictionary to the values on the screen and in the values
    
    if([self.utils checkValidString:[self.buildItemVals valueForKey:@"title"]] && [self.utils checkValidString:[self.buildItemVals valueForKey:@"caption"]] && [self.utils checkValidString:[self.buildItemVals valueForKey:@"timeStamp"]] && [self.utils checkValidString:[self.buildItemVals valueForKey:@"mediaPath"]] && [self.utils checkValidString:[self.buildItemVals valueForKey:@"type"]] && [self.utils checkValidString:[self.buildItemVals valueForKey:@"thumbnailPath"]] ){
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


@end