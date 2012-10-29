//
//  ImageEditorViewController.m
//  ITM_v0
//
//  Created by Lauren Bonnet on 10/2/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import "ImageEditorViewController.h"

@interface ImageEditorViewController ()

@end

@implementation ImageEditorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.utils = [[Utilities alloc]  init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // set the nav bar to off
    [self.navigationController setNavigationBarHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)resize:(id)sender {
    
    UIImage * imgToSize = self.imageView.image;
    
    NSLog(@"image size: %f , %f", imgToSize.size.width, imgToSize.size.height);
    
    UIImage* newImage = [self resizeImage:imgToSize newSize:CGSizeMake(160, 120)];
    NSLog(@"image size: %f , %f", newImage.size.width, newImage.size.height);
    self.imageView.image = newImage;
    
    
}

- (IBAction)save:(id)sender {
    
    
    
}

- (NSDictionary*) getSavedValues{
    
    NSDictionary *returnDictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:5] forKey:@"newNumber"];
    return returnDictionary;
    // this will pull the values for the title, image path, caption and timestamp and return them
}

- (IBAction)cancel:(id)sender {
}

- (IBAction)useCamera:(id)sender {
}

- (IBAction)useLibrary:(id)sender {
}


// Text input methods

#pragma mark - textField delegate methods

-(void) textFieldDidEndEditing:(UITextField *)textField{
    
        [textField resignFirstResponder];
    self.activeTextField = nil;

}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    self.activeTextField = textField;// assign private variable the value of the textField
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
        [textField resignFirstResponder];
    self.activeTextField = nil;
    
    return YES;
}





- (void)showKeyboard:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollerView.contentInset = contentInsets;
    self.scrollerView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeTextField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.activeTextField.frame.origin.y + self.activeTextField.frame.size.height-kbSize.height);
        [self.scrollerView setContentOffset:scrollPoint animated:YES];
    }

}
// this method is responsible for actually sizing the scroll view when the keyboard is present

- (void)hideKeyboard:(NSNotification*)aNotification
{
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollerView.contentInset = contentInsets;
    self.scrollerView.scrollIndicatorInsets = contentInsets;
}


// Alert View methods

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
}

- (void) alertViewCancel:(UIAlertView *)alertView{
    
    
}

// Image Picker controller delegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
   /* if(self.indicator == nil){
        self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.indicator setCenter:self.view.center];
        [self.view addSubview:self.indicator];
        [self.indicator startAnimating];
        
    }
    
    if([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        
        UIImage *imgToUse = [info objectForKey:UIImagePickerControllerEditedImage];
        if(imgToUse == NULL){
            imgToUse = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        // self.imageView.image = imgToUse; // set the image view to this image
        
        if(picker.sourceType != UIImagePickerControllerSourceTypePhotoLibrary){// if it's from the camera, write it to the saved photos album
            
            [self.lib writeImageToSavedPhotosAlbum:[imgToUse CGImage] orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
                
                
                
                if(!error){
                    //self.buildItem.imagePath = [assetURL absoluteString];
                    [self performSelectorOnMainThread:@selector(saveThumb:) withObject:assetURL waitUntilDone:NO];
                }else{
                    NSLog(@"error: %@",error);
                }
                
            }];
        }else{// if it's the camera
            NSURL *assetURL = [info valueForKey:UIImagePickerControllerReferenceURL];
            
            //            self.buildItem.imagePath = [assetURL absoluteString];
            //            NSLog(@"videoPath: %@",self.buildItem.imagePath);
            [self performSelectorOnMainThread:@selector(saveThumb:) withObject:assetURL waitUntilDone:NO];
        }
        
        
        
    }*/
    
    [self dismissModalViewControllerAnimated:YES];
}

// this method conforms to the method specified by the completion selector argument of the UIImageWriteToSavedPhotosAlbum method above - that method is part of UIKit functions and named in the UIImage class


// final delegate method for cancellation by user
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
}


/* Image Resize */

- (UIImage *) resizeImage:(UIImage*)image newSize:(CGSize)newSize{
    
    // create the rectangle to hold the new image
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    
    CGImageRef imageRef = image.CGImage;// get a reference to the actual core graphics image
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);// create the image context to capture the image once we change it and paint it on
    CGContextRef context = UIGraphicsGetCurrentContext();// created the context, now get a reference to it
    
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);// set the quality
    CGAffineTransform flipVertical = CGAffineTransformMake(1,0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);// flip the context so all points are correct
    
    CGContextDrawImage(context, newRect, imageRef);//draw to the context
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(context);// get the new image from the results of scaling
    UIImage* newImage = [UIImage imageWithCGImage:scaledImage];
    
    CGImageRelease(scaledImage);// release the core graphics object
    UIGraphicsEndImageContext();// end the context
    
    return newImage;
}


- (Boolean) saveImageToHomeDir:(UIImage*) newImage{
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSString* idString = [self.utils GetUUIDString]; 
    NSString *imageName = [NSString stringWithFormat:@"screen_%@",idString];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.jpg",imageName]];
    NSURL *url = [NSURL fileURLWithPath:path];
    [UIImageJPEGRepresentation(viewImage, 0.75f) writeToURL:url atomically:YES];

    
}

/* end image resize */



/*
 - (NSString*)takeScreenShot{
 
 if(self.buildItem.thumbnailPath != @""){//this one has a thumbnail already, so delete it
 NSError *error;
 NSFileManager *mgr = [NSFileManager defaultManager];
 NSString* str = self.buildItem.thumbnailPath;
 if ([mgr removeItemAtPath:self.buildItem.thumbnailPath error:&error] != YES)
 NSLog(@"Unable to delete file: %@", [error localizedDescription]);
 }
 
 NSString* UUID = [self GetUUID];
 if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
 UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0.5);
 //else
 //   UIGraphicsBeginImageContext(self.view.bounds.size);
 
 //UIGraphicsBeginImageContext(self.view.bounds.size);
 [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
 UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 NSString *imageName = [NSString stringWithFormat:@"screen_%@",UUID];
 NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.jpg",imageName]];
 NSURL *url = [NSURL fileURLWithPath:path];
 [UIImageJPEGRepresentation(viewImage, 0.75f) writeToURL:url atomically:YES];
 return path;
 }

 
 
 -(UIImage*)rotateIMG:(UIImage*)src{
 //    UIImage * LandscapeImage = src;
 //    UIImage * PortraitImage = [[UIImage alloc] initWithCGImage: LandscapeImage.CGImage
 //                                                         scale: 1.0
 //                                                   orientation: UIImageOrientationLeft];
 
 UIImageOrientation orient = src.imageOrientation;
 CGImageRef ref = src.CGImage;
 UIImage *newImage;
 switch(orient) {
 
 case UIImageOrientationUp: //EXIF = 1
 NSLog(@"image orientation: UP");
 newImage = [UIImage imageWithCGImage:ref scale:0.5 orientation:UIImageOrientationRight];
 break;
 
 case UIImageOrientationUpMirrored: //EXIF = 2
 NSLog(@"image orientation: UP mirrored");
 newImage = [UIImage imageWithCGImage:ref scale:0.5 orientation:UIImageOrientationRight];
 break;
 
 case UIImageOrientationDown: //EXIF = 3
 NSLog(@"image orientation: Down");
 newImage = [UIImage imageWithCGImage:ref scale:0.5 orientation:UIImageOrientationLeft];
 break;
 
 case UIImageOrientationDownMirrored: //EXIF = 4
 newImage = [UIImage imageWithCGImage:ref scale:0.5 orientation:UIImageOrientationLeft];
 NSLog(@"image orientation: UP");
 break;
 
 case UIImageOrientationLeft: //EXIF = 5
 NSLog(@"image orientation: Left mirrored");
 newImage = [UIImage imageWithCGImage:ref scale:0.5 orientation:UIImageOrientationUp];
 break;
 
 case UIImageOrientationLeftMirrored: //EXIF = 6
 NSLog(@"image orientation: Left");
 newImage = [UIImage imageWithCGImage:ref scale:0.5 orientation:UIImageOrientationUp];
 break;
 
 case UIImageOrientationRightMirrored: //EXIF = 7
 NSLog(@"image orientation: Right mirrored");
 newImage = [UIImage imageWithCGImage:ref scale:0.5 orientation:UIImageOrientationDown];
 break;
 
 case UIImageOrientationRight: //EXIF = 8
 NSLog(@"image orientation: Right");
 newImage = [UIImage imageWithCGImage:ref scale:0.5 orientation:UIImageOrientationDown];
 break;
 
 default:
 [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
 
 }

 
 
 // this method should save the downscaled thumbnail into the Documents directory
 -(void) saveThumb:(NSURL *)assetURL{
 [self.lib assetForURL:assetURL resultBlock:^(ALAsset *asset) {
 //UIImage *thumb = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];//
 
 // downscale this image and make it's orientation up
 UIImage *preview = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage] scale:0.5 orientation:UIImageOrientationUp];
 
 [self performSelectorOnMainThread:@selector(saveNewImage:) withObject:preview waitUntilDone:NO];
 [self performSelectorOnMainThread:@selector(showImageInThumb:) withObject:preview waitUntilDone:NO];
 
 
 } failureBlock:^(NSError *error) {
 NSLog(@"Error on save: %@", [error localizedDescription]);
 }];
 
 }
 
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
 
 
 
 -(void)useCamera{
 // check to see if the camera is on the devie
 if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
 
 
 // create the UIImagePickerController and set this ViewController as it's delegate, then declare the source types, media types and editing preferences
 newMedia = YES;
 UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
 imagePicker.delegate = self;
 imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
 imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage, nil];// including <MobileCoreServices/MobileCoreServices.h> with the header file is what allows us to use kUTTypeImage
 imagePicker.allowsEditing = YES;
 [self presentModalViewController:imagePicker animated:YES];
 
 
 
 
 }
 }
 
 -(void)usePhotos{
 // check to see if the camera roll is available on this device
 if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]){
 // just like the previous, create the imagePicker, set this as it's delegate and set the sourceType to the camera roll, then allow images as the media type and specify no for editing, and present the new view controller modally
 UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
 imagePicker.delegate = self;
 imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
 imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
 imagePicker.allowsEditing = NO;
 [self presentModalViewController:imagePicker animated:YES];
 newMedia = NO;
 
 }
 }
 
 #pragma mark - UIImagePickerControllerDelegate methods
 

 
 */



@end
