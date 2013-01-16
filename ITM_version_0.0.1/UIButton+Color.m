//
//  UIButton+Color.m
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 1/10/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

#import "UIButton+Color.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIButton (Color)

+ (UIButton*) createButtonWithImage:(UIImage *) img color:(UIColor *)bgColor title:(NSString*) title{
    
   UIButton *retBtn = [self buttonWithType:UIButtonTypeCustom];
    retBtn.backgroundColor = bgColor;
    [retBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [retBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
retBtn.layer.borderColor = [[UIColor blackColor] CGColor];
retBtn.layer.borderWidth = 0.5f;
retBtn.layer.cornerRadius = 10.0f;
    CGFloat bottomInset = (title != nil) ? 20.0:0.0;// set the bottom inset to zero
    
    [retBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, bottomInset, 0.0)];
    [retBtn setImage:img forState:UIControlStateNormal];
    if(title != nil){// if there's a title, need to adjust the bottom inset
        UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 30.0, 45.0, 20.0)];
        [titleLbl setTextAlignment:NSTextAlignmentCenter];
        [titleLbl setBackgroundColor:bgColor];
        titleLbl.font = [UIFont systemFontOfSize:12.0];
        titleLbl.text = title;
        [retBtn addSubview:titleLbl];
    }
    
    
    retBtn.tintColor = bgColor;
    retBtn.frame = CGRectMake(0.0, 0.0, 55.0, 55.0);
//    
    return retBtn;

}

@end
