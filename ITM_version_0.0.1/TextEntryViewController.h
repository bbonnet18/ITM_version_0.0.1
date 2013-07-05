//
//  TextEntryViewController.h
//  ReVolt_v0
//
//  Created by Ben Bonnet on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScreenTextEditor
@required
- (void) didFinishEditingText:(NSString*) editedText;//
@end

@interface TextEntryViewController : UIViewController <UITextViewDelegate,UIScrollViewDelegate>
{
    UIScrollView *_scrollerView;
    UIEdgeInsets _oldInsets;
    UIEdgeInsets _oldScrollIndicatorInsets;
    CGRect _oldFrame;// the previous content
    CGRect _currentKeyboard;// holds the position of the keyboard
    CGSize _keyboardSize;//holds the current size of the keyboard
    id <ScreenTextEditor> _delegate;
    NSString *_textToEdit;
    BOOL _keyboardOn;
    NSInteger _charactersLimit;
    NSNumber *_totalLines;
    NSInteger _heightLimit; // limit the height of the text - how many lines
}
- (IBAction)save:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *mainTextView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollerView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBtn;
@property (strong, nonatomic) NSString *textToEdit;
@property (strong, nonatomic) id <ScreenTextEditor> delegate;
@property (nonatomic,assign) NSInteger lineLimit;
@property (nonatomic, assign) NSInteger charactersLimit;
@property (strong, nonatomic) NSNumber *totalLines;
@property (strong, nonatomic) IBOutlet UILabel *charLimit;
//@property (strong, nonatomic) IBOutlet UILabel *linesLimit;
@property (strong, nonatomic) IBOutlet UILabel *lines;
-(void) showTextToEdit:(NSString*)editText;// this is used when initializing so the text can be seen in the text view and to allow editing.
-(BOOL) checkLines: (NSString*) textToAdd textInRange:(NSRange) range;// this will return true if the line number limit has not been met
@end
