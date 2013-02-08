//
//  PreviewImage.h
//  ITM_v0
//
//  Created by Lauren Bonnet on 10/5/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PreviewImageProtocol

- (void) editItem:(NSInteger) itemNumber;// brings back the item number so it can be edited
- (void) deleteItem:(NSInteger) itemNumber; // supplies the item number so it can be deleted
- (void) addBefore:(NSInteger) beforeIndex;// supplies the item number - 1 so an item can be added to it before the current index
- (void) addAfter: (NSInteger) afterIndex;// supplies the item number + 1 so an item can be added after the current index
@end


@interface PreviewImage : UIView{
    
    id <PreviewImageProtocol> _delegate;
    UIImage *_previewImage;
    NSInteger _itemNumber;
}
@property (strong, nonatomic) UIButton *addAfterBtn;//add a screen after this one
@property (strong, nonatomic) UIButton *addBeforeBtn;// add one before
@property (strong, nonatomic) UIButton *editBtn;// edit this buildItem
@property (strong, nonatomic) UIButton *deleteBtn;// delete the build item
@property (strong, nonatomic) UIImageView *previewImageView;// preview image to hold the thumbnail
@property (strong, nonatomic) UIImage *previewImage;// actual preivew image that will be shown in the previewImageView
@property (strong, nonatomic) id <PreviewImageProtocol> delegate;// delegate to send messages to for each button action
@property (nonatomic, assign) NSInteger itemNumber; // string representing the index
@property (strong, nonatomic) UILabel *titleLabel;// the title of the item
@property (strong, nonatomic) UILabel *descriptionLabel;// the description of the item

-(id) initWithFrame:(CGRect)frame andImage:(UIImage*)img;// new initializer to handle the initialization with an image provided
-(IBAction)addAfter:(id)sender;
-(IBAction)addBefore:(id)sender;
-(IBAction)editItem:(id)sender;
-(IBAction)deleteItem:(id)sender;
-(void) updateTitleLabel:(NSString *)labelText;//updates the label
-(void) updateDescriptionLabel:(NSString*)labelText;// updates the label

@end
