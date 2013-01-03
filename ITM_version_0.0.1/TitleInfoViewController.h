//
//  TitleInfoViewController.h
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 11/15/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Build.h"

@protocol TitleInfoProtocol
@required

-(void) userDidAddBuildWithTitle:(NSString*)title andDescription:(NSString*) description isNew:(BOOL) buildIsNew;// returns the build we built
-(void) userDidCancel;// returns without creating a build
-(void) userDidDeleteBuildWithID:(NSString*)buildId;//will delete if this has been built before

@end

@interface TitleInfoViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>{
    UITextView* _activeView;
    BOOL _isNew;// used to tell whether the build is new or not
    NSString* _titleForBuild;
    NSString* _descriptionForBuild;
}

@property (strong, nonatomic) IBOutlet UIButton* cancelBtn;
@property (strong, nonatomic) IBOutlet UIButton* continueBtn;
@property (strong, nonatomic) IBOutlet UITextView* descriptionTxt;
@property (strong, nonatomic) NSString* titleForBuild;//the build title variable;
@property (strong, nonatomic) NSString* descriptionForBuild;//the description for build
@property (strong, nonatomic) NSString* thumbNailPath;// the path for the thumbnail if it has one
@property (strong, nonatomic) IBOutlet UITextField* titleTxt;
@property (strong, nonatomic) IBOutlet UIImageView* previewImg;//preview image
@property (strong, nonatomic) IBOutlet UILabel *statusTxt;// represents the status
@property (strong, nonatomic) IBOutlet UIImageView* statusImg;//shows whether the item is editable/uploading/viewable
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;//the label for status
@property (strong, nonatomic) NSString *status;// the actual status of the build
@property (nonatomic, assign) BOOL isEditable;// used to initialize and tells whether the item is editablew
@property (strong, nonatomic) id <TitleInfoProtocol> delegate;
@property (strong, nonatomic) UIImage *preview;// actual preview image
@property (strong, nonatomic) IBOutlet UILabel* previewLabel;// label for the preview image
@property (strong, nonatomic) NSString *buildTitle;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *buildID;
@property (strong, nonatomic) UITextView *activeView;// the text view, we use this to track when the view is active so we can use the done button
@property (strong, nonatomic) IBOutlet UIButton *doneBtn; // used when editing the description text
@property (nonatomic, assign) BOOL isNew;

-(IBAction)cancelBuild:(id)sender;
-(IBAction)continueToEdit:(id)sender;
-(IBAction)deleteBuild:(id)sender;
@end
