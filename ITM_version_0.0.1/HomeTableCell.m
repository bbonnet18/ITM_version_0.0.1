//
//  HomeTableCell.m
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 12/20/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import "HomeTableCell.h"

@implementation HomeTableCell
@synthesize titleTxt = _titleTxt;
@synthesize statusBtn = _statusBtn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
       
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:NO];

    // Configure the view for the selected state
}
-(IBAction)testBtn:(id)sender{
    NSString* test = @"go";
}



@end