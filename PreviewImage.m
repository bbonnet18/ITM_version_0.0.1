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
        
        UIColor *btnTintColor = [UIColor colorWithRed:1.0 green:0.93 blue:0.79 alpha:1.0];
        
        UIImage *editImg = [UIImage imageNamed:@"hammer-square.png"];
        self.editBtn =  [UIButton createButtonWithImage:editImg color:btnTintColor title:nil];
        self.editBtn.frame = CGRectMake(frame.size.width/2 - self.editBtn.frame.size.width - 10.0, topEdge, self.editBtn.frame.size.width, self.editBtn.frame.size.height);
        [self.editBtn addTarget:self action:@selector(editItem:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        UIImage *deleteImg = [UIImage imageNamed:@"deleteIcon.png"];
        self.deleteBtn = [UIButton createButtonWithImage:deleteImg color:[UIColor redColor] title:nil];//[UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteBtn.frame = CGRectMake(frame.size.width/2 + 10.0, topEdge, self.deleteBtn.frame.size.width, self.deleteBtn.frame.size.height);
        [self.deleteBtn addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage * addBeforeImg = [UIImage imageNamed:@"add_before.png"];
        UIImage * addAfterImg = [UIImage imageNamed:@"add_after.png"];
        
        self.addAfterBtn = [UIButton createButtonWithImage:addAfterImg color:btnTintColor title:nil];
        [self.addAfterBtn addTarget:self action:@selector(addAfter:) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect addBtnFrame = CGRectMake(rightEdge - self.addAfterBtn.frame.size.width, topEdge, self.addAfterBtn.frame.size.width, self.addAfterBtn.frame.size.height);
        self.addAfterBtn.frame = addBtnFrame;
        
        self.addBeforeBtn = [UIButton createButtonWithImage:addBeforeImg color:btnTintColor title:nil];
        [self.addBeforeBtn addTarget:self action:@selector(addBefore:) forControlEvents:UIControlEventTouchUpInside];

        addBtnFrame = CGRectMake(leftEdge, topEdge, self.addBeforeBtn.frame.size.width, self.addBeforeBtn.frame.size.height);
        self.addBeforeBtn.frame = addBtnFrame;
        
        self.previewImageView = [[UIImageView alloc] initWithImage:img];
        
        [self.previewImageView sizeToFit];
        CGRect previewImageFrame = CGRectMake(frame.size.width/2 - self.previewImageView.frame.size.width/2, 90, self.previewImageView.frame.size.width, self.previewImageView.frame.size.height);
        self.previewImageView.frame = previewImageFrame;
        
        //title setup
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2 - self.previewImageView.frame.size.width/2, self.addBeforeBtn.frame.origin.y + self.addBeforeBtn.frame.size.height + 2.0, self.previewImageView.frame.size.width, 20.0)];
        self.titleLabel.layer.cornerRadius = 5.0f;
        //self.titleLabel.layer.borderColor = [[UIColor clearColor] CGColor];
        //self.titleLabel.layer.borderWidth = 1.0f;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        // description setup
        
        self.captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2 - self.previewImageView.frame.size.width/2, self.previewImageView.frame.origin.y + self.previewImageView.frame.size.height + 2.0, self.previewImageView.frame.size.width, 20.0)];
        self.captionLabel.layer.cornerRadius = 5.0f;
        self.captionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.captionLabel.backgroundColor = [UIColor clearColor];
        // order counter
        
        self.counterLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2 - 50.0, self.captionLabel.frame.origin.y + self.captionLabel.frame.size.height + 2.0, 100.0, 20.0)];
        self.counterLabel.textAlignment = NSTextAlignmentCenter;
        self.counterLabel.backgroundColor = [UIColor clearColor];
        
        
        
        //self.layer.borderColor = [[UIColor whiteColor] CGColor];
        //self.layer.borderWidth = 2.0f;
        //self.layer.cornerRadius = 8.0f;
    
        
        [self addSubview:self.editBtn];
        [self addSubview:self.deleteBtn];
        [self addSubview:self.addAfterBtn];
        [self addSubview:self.addBeforeBtn];
        [self addSubview:self.titleLabel];
        [self addSubview:self.captionLabel];
        [self addSubview:self.counterLabel];
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

-(void)updateTitleLabel:(NSString *)labelText{
    self.titleLabel.text = labelText;
}

-(void) updateCaptionLabel:(NSString *)labelText{
    self.captionLabel.text = labelText;
}
-(void) updateCounterLabel:(NSString *)counterText{
    self.counterLabel.text = counterText;
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

