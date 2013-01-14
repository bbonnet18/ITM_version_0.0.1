//
//  PreviewImage.m
//  ITM_v0
//
//  Created by Lauren Bonnet on 10/5/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import "PreviewImage.h"
#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>
#import "UIButton+Color.h"

@implementation PreviewImage
@synthesize delegate = _delegate;
@synthesize itemNumber = _itemNumber;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
               
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame andImage:(UIImage *)img
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // create all the markers for edges and place items
        NSInteger leftEdge = 10;
        NSInteger rightEdge = frame.size.width - 10;
        NSInteger topEdge = 10;
        NSInteger bottomEdge = frame.size.height - 10;
        
        
// need a method to create these buttons
        UIColor *btnTintColor = [UIColor colorWithRed:1.0 green:0.93 blue:0.79 alpha:1.0];
        
        UIImage *editImg = [UIImage imageNamed:@"hammer-square.png"];
        self.editBtn =  [UIButton createButtonWithImage:editImg color:btnTintColor title:@"edit"];//[[Utilities sharedInstance] createRoundedCustomBtnWithImage:editImg];
//        self.editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.editBtn.backgroundColor = btnTintColor;
//        [self.editBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
//        [self.editBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
//        self.editBtn.layer.borderColor = [[UIColor blackColor] CGColor];
//        self.editBtn.layer.borderWidth = 0.5f;
//        self.editBtn.layer.cornerRadius = 10.0f;
//         [self.editBtn setImage:editImg forState:UIControlStateNormal];
//        [self.editBtn sizeToFit];
//        self.editBtn.tintColor = btnTintColor;
        self.editBtn.frame = CGRectMake(frame.size.width/2 - self.editBtn.frame.size.width - 10.0, topEdge, self.editBtn.frame.size.width, self.editBtn.frame.size.height);
        [self.editBtn addTarget:self action:@selector(editItem:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        UIImage *deleteImg = [UIImage imageNamed:@"deleteIcon.png"];
        self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteBtn.backgroundColor = btnTintColor;
        [self.deleteBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [self.deleteBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.deleteBtn.layer.borderColor = [[UIColor blackColor] CGColor];
        self.deleteBtn.layer.borderWidth = 0.5f;
        self.deleteBtn.layer.cornerRadius = 10.0f;
        //self.deleteBtn.frame = CGRectMake(frame.size.width/2, topEdge, 80.0,80.0);
        [self.deleteBtn setImage:deleteImg forState:UIControlStateNormal];
//        CGFloat leftInset = 40.0 - deleteImg.size.width/2;
//        CGFloat topInset = 10.0;
//        CGFloat bottomInset = self.deleteBtn.frame.size.height/2;
//        CGFloat rightInset = leftInset+deleteImg.size.width;
//        [self.deleteBtn setImageEdgeInsets:UIEdgeInsetsMake(topInset, leftInset, bottomInset, rightInset)];
//        leftInset = 10.0;
//        topInset = self.deleteBtn.frame.size.height/2;
//        bottomInset = 10.0;
//        rightInset = 10.0;
//        [self.deleteBtn setTitleEdgeInsets:UIEdgeInsetsMake(topInset, leftInset, bottomInset, rightInset)];
//        [self.deleteBtn setTitle:@"edit" forState:UIControlStateNormal];
//        //[self.deleteBtn sizeToFit];
//        
//        //
        [self.deleteBtn sizeToFit];
         //self.deleteBtn.tintColor = btnTintColor;
        self.deleteBtn.frame = CGRectMake(frame.size.width/2 + 10.0, topEdge, 44.0, 44.0);
        [self.deleteBtn addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage * addBeforeImg = [UIImage imageNamed:@"add_before.png"];
        UIImage * addAfterImg = [UIImage imageNamed:@"add_after.png"];
        
        self.addAfterBtn = [[Utilities sharedInstance] createRoundedCustomBtnWithImage:addAfterImg];//[UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        //[self.addAfterBtn setImage:addAfterImg forState:UIControlStateNormal];
        //[self.addAfterBtn sizeToFit];
       
        [self.addAfterBtn addTarget:self action:@selector(addAfter:) forControlEvents:UIControlEventTouchUpInside];
        
        
        CGRect addBtnFrame = CGRectMake(rightEdge - self.addAfterBtn.frame.size.width, topEdge, self.addAfterBtn.frame.size.width, self.addAfterBtn.frame.size.height);
        self.addAfterBtn.frame = addBtnFrame;
        
        UIButton *btn = 
        
        self.addBeforeBtn = [[Utilities sharedInstance] createRoundedCustomBtnWithImage:addBeforeImg];//[UIButton buttonWithType:UIButtonTypeRoundedRect];
       // [self.addBeforeBtn setImage:addBeforeImg forState:UIControlStateNormal];
        //[self.addBeforeBtn sizeToFit];
       // self.addBeforeBtn.tintColor = btnTintColor;
        [self.addBeforeBtn addTarget:self action:@selector(addBefore:) forControlEvents:UIControlEventTouchUpInside];
        
        addBtnFrame = CGRectMake(leftEdge, topEdge, self.addBeforeBtn.frame.size.width, self.addBeforeBtn.frame.size.height);
        self.addBeforeBtn.frame = addBtnFrame;
        
        self.previewImageView = [[UIImageView alloc] initWithImage:img];
        [self.previewImageView sizeToFit];
        CGRect previewImageFrame = CGRectMake(frame.size.width/2 - self.previewImageView.frame.size.width/2, 80, self.previewImageView.frame.size.width, self.previewImageView.frame.size.height);
        self.previewImageView.frame = previewImageFrame;
        
        
        
        [self addSubview:self.editBtn];
        [self addSubview:self.deleteBtn];
        [self addSubview:self.addAfterBtn];
        [self addSubview:self.addBeforeBtn];
        [self addSubview:self.previewImageView];
        

    }
    return self;
}

-(void) setItemNumber:(NSInteger)itemNumber{
    // disable the add before button if this is item 0
    if(itemNumber >=1){
        [self.addBeforeBtn setEnabled:YES];
    }else{
        [self.addBeforeBtn setEnabled:NO];
    }
    self->_itemNumber = itemNumber;
}

-(IBAction)addAfter:(id)sender{
    
    [self.delegate addAfter:self.itemNumber+1];
    
}

-(IBAction)addBefore:(id)sender{
    
    [self.delegate addBefore:self.itemNumber-1];
}

-(IBAction)editItem:(id)sender{
    
    [self.delegate editItem:self.itemNumber];
}

-(IBAction)deleteItem:(id)sender{
    
    [self.delegate deleteItem:self.itemNumber];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

