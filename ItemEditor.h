//
//  ItemEditor.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuildMainEditScreen.h"
#import "TextEntryViewController.h"



@protocol ItemEditor
@optional

- (void) updateBuildItem: (BuildItem*) updatedItem;// updates the build with the buildItem provided
- (void) updateBuildItemIDs;// updates the item ids to the order they occupy in the array
- (void) deleteBuildItem: (BuildItem*) buildToDelete;// sends back the build to delete to the delegate so the delegate can perform the work of deleting

- (BuildItem*) loadBuildItem;// this will get the BuildItem, this is called on the BuildMainEditScreen 

- (void) setCurrentItemTypeString: (NSString*) itemType;// this is used when a template item is chosen, it sets the currentBuildItemType on the main edit screen
- (BOOL) buildItemIsNew; // called to tell the target that the buildItem assigned to it, is a new one. Mostly for deleting a new buildItem if it's never been updated and saved
- (void) userDidCancelFromEditor:(BuildItem*) newItemToRemove;// new items are created when the user chooses to add a new BuildItem. This will be called when a user changes his/her mind and chooses not to create a new item 

@end

@class TemplatePicker;
@class TemplateLoader;
@class BuildItem;
@class TextEntryViewController;

@interface ItemEditor : UIViewController<UITextFieldDelegate, TemplatePickerDelegate, UIAlertViewDelegate>{
    BOOL _didMakeChanges;// flag to allow us to know if something was changed. If something was changed, then we update the build when returning, otherwise we simply pop to the previous BuildMainEditScreen view controller
    UIScrollView *_scrollerView;
    UITextField *_activeTextField;// allows us to track whether the title or another textfield has been tapped so we can provide the necessary keyboard adjustments
    UIView *_activeView;// will help determine which view is currently selected
    id <ItemEditor> _delegate;// the item editor delegate will allow the class to communicate with BuildMainEditScreen's protocol methods
    // interface elements and buttons common to all editors
    UITextField *_titleTxt;
    UIBarButtonItem *_saveBtn;
    UIBarButtonItem *_cancelBtn;
    UIBarButtonItem *_swapTemplateBtn;
    
    UIEdgeInsets _oldInsets;
    UIEdgeInsets _oldScrollIndicatorInsets;
    CGRect _oldFrame;// the previous content
    CGRect _currentKeyboard;// holds the position of the keyboard
    CGSize _keyboardSize;//holds the current size of the keyboard
    //BuildItem *_buildItem;// this is a reference to the build item we're editing
    
}

@property (strong, nonatomic) id <ItemEditor> delegate;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollerView;// all items are housed in a scrollview
@property (strong, nonatomic) UITextField *activeTextField;
@property (strong, nonatomic) UIView *activeView;// used to determine the location of the currently selected view so we can scroll appropriately
@property (strong, nonatomic) IBOutlet UITextField *titleTxt;// the title, all editors must have a title
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBtn;// saveBtn is used on all editors to allow the user to save changes and return to the main edit screen
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;// cancelBtn, cancels changes and returns to the main edit screen
@property (strong, nonatomic) IBOutlet UIBarButtonItem *swapTemplateBtn;// swapTemplateBtn will bring up the templatepicker so the user can choose a new template. If they choose a new one, the changes from the old one will be lost and a new template will be added to the viewstack of the navigationcontroller in place of the old one
@property BOOL didMakeChanges;// this BOOL changes to YES anytime the user changes any of the text, graphics or video associated with the editor
//@property (strong, nonatomic) BuildItem *buildItem;



-(void)swapTemplate;// swapTemplate method calls the templatepicker modally so the user can choose to swap the template. The user will lose the data on this view and this buildItem if the choose to switch the templates
- (IBAction)save:(id)sender;// called when the user chooses to save, this will interface with the delegate's ItemEditor protocol methods
- (void) makeChangesWithBuild;// makes changes to the build object
- (IBAction)cancel:(id)sender;// this is called if the user doesn't want to make any changes to the item, it will pop back to the BuildMainEditScreen view controller
- (IBAction)deleteBuildItem:(id)sender; // this will delete the buildItem and pop back to the main edit screen
- (IBAction)showSwitchMessage:(id)sender;// this shows a message in an alert view to the user telling the user that switching templates will cause them to lose the data they have in the current editor template

- (NSString*) takeScreenShot;// this is responsible for taking a screenshot of this screen and returning a string that represents the path to that image. That image will then be used as the preview image on the BuildMainEditScreen
- (void) deleteScreenShot;// deletes the previous screenshot
- (void) populateItems;// this will look at the values in the BuildItem and update the items accordingly. This is meant to be overridden at the editor level
- (NSString*) GetUUID;// unique id for the images
@end
