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
    UIColor *btnTintColor = bgColor;//bgColor;[UIColor colorWithRed:1.0 green:0.93 blue:0.79 alpha:1.0];//tan
    
   UIButton *retBtn = [self buttonWithType:UIButtonTypeCustom];
    retBtn.backgroundColor = btnTintColor;
    [retBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [retBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
retBtn.layer.borderColor = [[UIColor blackColor] CGColor];
retBtn.layer.borderWidth = 0.5f;
retBtn.layer.cornerRadius = 10.0f;
    
    [retBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 35.0, 5.0)];
    [retBtn setImage:img forState:UIControlStateNormal];
    //[retBtn setTitleEdgeInsets:UIEdgeInsetsMake(65.0, 5.0, 5.0, 5.0)];
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 30.0, 50.0, 30.0)];
    [titleLbl setTextAlignment:NSTextAlignmentCenter];
    [titleLbl setBackgroundColor:bgColor];
    titleLbl.text = title;
    [retBtn addSubview:titleLbl];
    //[retBtn setTitle:@"edit" forState:UIControlStateNormal];
    //[retBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
retBtn.tintColor = btnTintColor;
retBtn.frame = CGRectMake(0.0, 0.0, 64.0, 64.0);
//    
    return retBtn;

}

@end
