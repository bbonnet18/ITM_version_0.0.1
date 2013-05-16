//
//  WebImageViewController.h
//  TestIMGURLAndResize
//
//  Created by Ben Bonnet on 5/14/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Resize.h"

@protocol WebImageViewControllerDelegate

@required

-(void) userDidCancel;// when the user cancels the operation
-(void) userDidSelectImage:(UIImage*)img;// returns with the image

@end

@interface WebImageViewController : UIViewController <UITextFieldDelegate>{
    
    id <WebImageViewControllerDelegate> _delegate;
    UIImage * _webImage;
}

@property (strong, nonatomic) IBOutlet UIImageView *mainImageView;
@property (strong, nonatomic) IBOutlet UITextField *imageURLTxt;
@property (strong, nonatomic) IBOutlet UIButton *loadImageBtn;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *av;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) id <WebImageViewControllerDelegate> delegate;
- (IBAction)loadImage:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)launchBrowser:(id)sender;
- (IBAction)cancel:(id)sender;
@end
