//
//  HomeTableCell.h
//  ITM_version_0.0.1
//
//  Created by Lauren Bonnet on 12/20/12.
//  Copyright (c) 2012 Ben Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeTableCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UILabel* titleTxt;// the title
@property (nonatomic,strong) IBOutlet UIButton* statusBtn;// the button representing the status
@property (nonatomic, strong) IBOutlet UIImage* bgImg;// background image
@property (nonatomic, strong) IBOutlet UIButton* infoBtn;// activates the info screen
@property (nonatomic, strong) IBOutlet UILabel* uploadingLabel;// shown when an item is uploading
@property (nonatomic, strong) IBOutlet UIProgressView* uploadingProgress;// shown when an item is uploading
@end
