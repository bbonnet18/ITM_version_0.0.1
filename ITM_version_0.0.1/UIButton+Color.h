//
//  UIButton+Color.h
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 1/10/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIButton (Color)

// creates a button with the image on the top and the provided background color and title
+ (UIButton*) createButtonWithImage:(UIImage*) img color:(UIColor*) bgColor  title:(NSString*) title;
@end
