//
//  CaptureViewController.h
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 10/15/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "ImageEditor.h"
#import "UIImage+Resize.h"
#import "UIButton+Color.h"
#import "Utilities.h"
#import "TextEntryViewController.h"


@interface CaptureViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UIScrollViewDelegate,ScreenTextEditor>{
    id <ImageEditor> _delegate;// invokes the delegate methods to return values and dismiss this view
    UITextField *_activeField;// used with the keyboard methods to adjust the scroll view so the keyboard can show along with the text field
}

@property (nonatomic, strong) id <ImageEditor> delegate;
@property (strong, nonatomic) IBOutlet UIImageView *previewImageView;
@property (strong, nonatomic) IBOutlet UITextField *titleTxt;
@property (strong, nonatomic) IBOutlet UITextField *captionTxt;
@property (strong, nonatomic) IBOutlet UILabel *timeStampTxt;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) IBOutlet UIButton *videoCaptureBtn;
@property (strong, nonatomic) IBOutlet UIButton *libraryBtn;
@property (strong, nonatomic) IBOutlet UIButton *imageCaptureBtn;
@property (strong, nonatomic) IBOutlet UIButton *previewBtn;// shown when a preview is possible

@property (strong, nonatomic) IBOutlet UIScrollView *scroller;
@property (strong, nonatomic) IBOutlet UIButton* rotateBtn;//holds a reference to the rotation button
@property (strong, nonatomic) UITextField *activeField;// used with the keyboard methods to adjust the scroll view so the keyboard can show along with the text field
@property (strong, nonatomic) NSMutableDictionary *buildItemVals;// holds all the values passed in and this object is also passed back to the main editor
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
- (IBAction)videoCapture:(id)sender;// this method will allow the user to capture video
- (IBAction)imageCapture:(id)sender;// this method will allow the user to capture images
- (IBAction)useLibrary:(id)sender;// this method will allow users to select videos or images from the library
- (IBAction)save:(id)sender; // saves the values in the dictionary and calls the delegate methods
- (IBAction)cancel:(id)sender; // cancels the editing process and calls the delegate methods
- (IBAction)rotate:(id)sender;// rotates the image preview thumbnail
- (IBAction)editCaption:(id)sender;// allows the user to edit the caption text with a separate controller

@end

