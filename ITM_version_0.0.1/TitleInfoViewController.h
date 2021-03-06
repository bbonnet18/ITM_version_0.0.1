//
//  TitleInfoViewController.h
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 11/15/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Build.h"
#define ASSET_BY_SCREEN_HEIGHT(regular, longScreen) (([[UIScreen mainScreen] bounds].size.height <= 480.0) ? regular : longScreen)
@protocol TitleInfoProtocol
@required

-(void) userDidAddBuildWithTitle:(NSString*)title andDescription:(NSString*) description isNew:(BOOL) buildIsNew;// returns the build we built
-(void) userDidCancel;// returns without creating a build
-(void) userDidDeleteBuildWithID:(NSString*)buildId;//will delete if this has been built before

@end

@interface TitleInfoViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate, UIAlertViewDelegate,UIGestureRecognizerDelegate>{
    UITextView* _activeView;
    BOOL _isNew;// used to tell whether the build is new or not
    NSString* _titleForBuild;
    NSString* _descriptionForBuild;
    NSNumber* _applicationID;/// used to hold the app id
}

@property (strong, nonatomic) IBOutlet UIButton* cancelBtn;
@property (strong, nonatomic) IBOutlet UIButton* continueBtn;
@property (strong, nonatomic) IBOutlet UITextView* descriptionTxt;
@property (strong, nonatomic) NSString* titleForBuild;//the build title variable;
@property (strong, nonatomic) NSString* descriptionForBuild;//the description for build
@property (strong, nonatomic) NSString* thumbNailPath;// the path for the thumbnail if it has one
@property (strong, nonatomic) IBOutlet UITextField* titleTxt;
@property (strong, nonatomic) IBOutlet UIImageView* previewImg;//preview image

@property (nonatomic, assign) BOOL isEditable;// used to initialize and tells whether the item is editablew
@property (strong, nonatomic) id <TitleInfoProtocol> delegate;
@property (strong, nonatomic) UIImage *preview;// actual preview image
@property (strong, nonatomic) IBOutlet UILabel* previewLabel;// label for the preview image


@property (strong, nonatomic) IBOutlet UILabel *datePublishedLabel;
@property (strong, nonatomic) IBOutlet UILabel *datePublishedTitle;
@property (strong, nonatomic) NSString *buildTitle;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *buildID;
@property (strong, nonatomic) NSString *datePublished;// the date this item was published
@property (strong, nonatomic) UITextView *activeView;// the text view, we use this to track when the view is active so we can use the done button
@property (strong, nonatomic) IBOutlet UIButton *doneBtn; // used when editing the description text
@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;// used to delete the item
@property (nonatomic, assign) BOOL isNew;
@property (strong, nonatomic) IBOutlet UIImageView *infoImgView;// used to show the overlay
@property (strong, nonatomic) IBOutlet UIButton* viewButton;//


-(IBAction)cancelBuild:(id)sender;
-(IBAction)continueToEdit:(id)sender;
-(IBAction)deleteBuild:(id)sender;
-(IBAction)viewBuild:(id)sender;// will view the build if it's published
-(void) setAppID:(NSNumber*)num;// sets the applicationID so it can be viewed
@end
