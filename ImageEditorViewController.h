//
//  ImageEditorViewController.h
//  ITM_v0
//
//  Created by Lauren Bonnet on 10/2/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utilities.h"

@interface ImageEditorViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate>{
    
    UITextField *_activeTextField;// allows us to track whether the title or another textfield has been tapped so we can provide the necessary keyboard adjustments
}
@property (strong, nonatomic) IBOutlet UITextField *titleTxt;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *timestampTxt;

@property (strong, nonatomic) IBOutlet UIButton *libraryBtn;
@property (strong, nonatomic) IBOutlet UITextField *captionTxt;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (strong, nonatomic) IBOutlet UIButton *cameraBtn;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollerView;
@property (strong, nonatomic) UITextField *activeTextField;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *resizeBtn;
@property (strong, nonatomic) Utilities *utils; // local utilities

//actions
- (IBAction)resize:(id)sender;

- (IBAction)save:(id)sender;

- (IBAction)cancel:(id)sender;
- (IBAction)useCamera:(id)sender;
- (IBAction)useLibrary:(id)sender;
- (UIImage *) resizeImage:(UIImage*)image newSize:(CGSize)newSize;// method to resize images
@end
