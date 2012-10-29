//
//  PreviewImage.m
//  ITM_v0
//
//  Created by Lauren Bonnet on 10/5/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import "PreviewImage.h"

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
        
        NSInteger buttonHeight = 25;
        NSInteger addBtnWidth = 30;
        NSInteger buttonWidth = 150;
        
        self.editBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.editBtn.frame = CGRectMake(frame.size.width/2 - buttonWidth/2, topEdge, buttonWidth, buttonHeight);
        [self.editBtn setTitle:@"edit" forState:UIControlStateNormal];
        [self.editBtn addTarget:self action:@selector(editItem:) forControlEvents:UIControlEventTouchUpInside];
        
        self.deleteBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.deleteBtn.frame = CGRectMake(frame.size.width/2 - buttonWidth/2, topEdge+25, buttonWidth, buttonHeight);
        [self.deleteBtn setTitle:@"delete" forState:UIControlStateNormal];
        [self.deleteBtn addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage * plusImage = [UIImage imageNamed:@"plus.png"];
        
        self.addAfterBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.addAfterBtn setImage:plusImage forState:UIControlStateNormal];
        [self.addAfterBtn sizeToFit];
        [self.addAfterBtn addTarget:self action:@selector(addAfter:) forControlEvents:UIControlEventTouchUpInside];
        
        
        CGRect addBtnFrame = CGRectMake(rightEdge - self.addAfterBtn.frame.size.width, topEdge, self.addAfterBtn.frame.size.width, self.addAfterBtn.frame.size.height);
        self.addAfterBtn.frame = addBtnFrame;
        
        self.addBeforeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.addBeforeBtn setImage:plusImage forState:UIControlStateNormal];
        [self.addBeforeBtn sizeToFit];
        [self.addBeforeBtn addTarget:self action:@selector(addBefore:) forControlEvents:UIControlEventTouchUpInside];
        
        addBtnFrame = CGRectMake(leftEdge, topEdge, self.addBeforeBtn.frame.size.width, self.addBeforeBtn.frame.size.height);
        self.addBeforeBtn.frame = addBtnFrame;
        
        self.previewImageView = [[UIImageView alloc] initWithImage:img];
        [self.previewImageView sizeToFit];
        CGRect previewImageFrame = CGRectMake(frame.size.width/2 - self.previewImageView.frame.size.width/2, 65, self.previewImageView.frame.size.width, self.previewImageView.frame.size.height);
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

