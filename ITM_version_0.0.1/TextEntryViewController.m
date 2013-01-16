//
//  TextEntryViewController.m
//  ReVolt_v0
//
//  Created by Ben Bonnet on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextEntryViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface TextEntryViewController ()

@end


@implementation TextEntryViewController
@synthesize mainTextView;
@synthesize scrollerView = _scrollerView;
@synthesize delegate = _delegate;
@synthesize saveBtn;
@synthesize textToEdit = _textToEdit;
@synthesize charactersLimit = _charactersLimit;
@synthesize totalLines = _totalLines;
//@synthesize charLimit = _charLimit;
//@synthesize linesLimit = _linesLimit;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //[self.delegate setDidFinishEditing:NO];
        self.lineLimit = 2; 
        self.charactersLimit = 250;
        self->_heightLimit = 50;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFrame:) name:UITextViewTextDidChangeNotification object:nil];
    self.mainTextView.text = self.textToEdit;
    self.mainTextView.layer.borderWidth = 5.0f;// set the border for this textView
    self.mainTextView.layer.borderColor = [[UIColor grayColor] CGColor];// set the color for the border
    self.totalLines = 0;
    [self.navigationController setNavigationBarHidden:YES];
    [self.mainTextView becomeFirstResponder];

    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setMainTextView:nil];
//    [self setCharLimit:nil];
//    [self setLinesLimit:nil];
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil]; 
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];  
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return (UIInterfaceOrientationIsPortrait(interfaceOrientation) || UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

- (void) showTextToEdit:(NSString *)editText{
    self.textToEdit = editText;
}

-(void) textViewDidBeginEditing:(UITextView *)textView{
    
}


-(void) textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    
    
}

-(void)textViewDidChange:(UITextView *)aTextView {
    CGSize textViewSize = aTextView.frame.size;
    CGSize textSize = [aTextView.text sizeWithFont:aTextView.font constrainedToSize:textViewSize lineBreakMode:NSLineBreakByWordWrapping];
    
}


//-(void) textViewDidChange:(UITextView *)textView{
//   // NSLog(@"***** ------  real: %f",self.mainTextView.contentSize.height);
//    if(self.mainTextView.contentSize.height > 52){
//        
//    }else{
//        
//    }
//}

// receive this delegate method when the user enters text

-(BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    BOOL underCharLimit = NO;// set boolean to check when finished with other checks
    
    // set a variable equal to the current text plus new text - the range, the range
    // will be 0 if the user is typing and 1 if delete is pressed
    NSInteger newLength = [textView.text length] + [text length] - range.length;
    
    NSInteger remainingChar = self.charactersLimit - newLength;// the available length remaining
    
    //self.charLimit.text = [NSString stringWithFormat:@"%@",[[NSNumber numberWithInt:remainingChar] stringValue]];
    
    if(newLength < self.charactersLimit){
        underCharLimit = YES;
    }
    
    // Check to see if we're at the line limit and under the character limit
    if([self checkLines:text textInRange:range] == YES && underCharLimit == YES){
        [self.mainTextView setBackgroundColor:[UIColor colorWithRed:0.58 green:0.82 blue:0.95 alpha:1.0]];
        return YES;
    }else{
        [self.mainTextView setBackgroundColor:[UIColor redColor]];
        return NO;
    }
        
}

- (BOOL) checkLines:(NSString *)textToAdd textInRange:(NSRange)range{
    
    NSString *newText = [self.mainTextView.text stringByReplacingCharactersInRange:range withString:textToAdd];

    
    CGSize textViewSize = self.mainTextView.frame.size;

    CGSize textSize = [newText sizeWithFont:self.mainTextView.font constrainedToSize:textViewSize lineBreakMode:NSLineBreakByWordWrapping];
    
    
    //self.lines.text = [NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:textSize.height]];
    
    BOOL isDelete = NO;

    if(textToAdd.length == 0 && range.length == 1){
        isDelete = YES;
    }

    if(textSize.height < self->_heightLimit || isDelete){
        return YES;
    }else{
        return NO;
    }
    
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
        [self.mainTextView resignFirstResponder];
    
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{

        [self.mainTextView becomeFirstResponder];

}

- (void)showKeyboard:(NSNotification*)aNotification
{
    [self showKeyboardInView:aNotification];
    
}
// this method is responsible for actually sizing the scroll view when the keyboard is present
- (void) showKeyboardInView:(NSNotification *)aNotification{
    NSDictionary* info = [aNotification userInfo];
    CGSize sz = CGSizeMake(480.0, 216.0);
    self->_keyboardSize = sz;//[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self->_oldInsets = self.scrollerView.contentInset;
    self->_oldScrollIndicatorInsets = self.scrollerView.scrollIndicatorInsets;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self->_keyboardSize.height, 0.0);
    self.scrollerView.contentInset = contentInsets;// set content inset so the content window area is inset and allows us to scroll to the right place. 
    self.scrollerView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGFloat padding = 10.0;
    
    
    CGRect f = self.mainTextView.frame;// get the frame of the textView, it may change as we edit it and we'll have to update that ---!!!!
    CGRect r = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    r = [self.view convertRect:r fromView:nil];
    self->_currentKeyboard = r;
    
    CGRect aRect = self.view.frame;// the frame's view rect for the entire view
    aRect.size.height -= self->_keyboardSize.height;// shorten this now because the keyboard is on it
    NSLog(@"minY: %f",CGRectGetMaxY(f));
    NSLog(@"frame.size: %f and contentSize: %f",f.size.height, self.mainTextView.contentSize.height);
    CGPoint scroller = CGPointMake(0.0, CGRectGetMinY(f) + f.size.height);
    
    if (!CGRectContainsPoint(aRect, scroller) ) {// check to see if the rect we create contains the text view
        CGFloat yVal = scroller.y;
        CGFloat newY = yVal -self->_currentKeyboard.size.height + padding;
        CGPoint scrollPoint = CGPointMake(0.0, newY);// calculating the difference here tells us that the content should move up only the distance between the y location of the textview and height of the keyboard size. Think about it like where it was before, minus the keyboard height that's now taking up space on the screen.;
        [self.scrollerView setContentOffset:scrollPoint animated:YES];
    }
    
}


- (void)doneEditingAction:(id)sender
{
	// finish typing text/dismiss the keyboard by removing it as the first responder
    [self.mainTextView resignFirstResponder];
	self.navigationItem.rightBarButtonItem = nil;
    
}

// handles changing the frame so the text can work in either orientation

-(void) changeFrame:(NSNotification *)note{
    
    
    
    CGRect frame = self.mainTextView.frame;
    UIScrollView *sv = (UIScrollView*)self.mainTextView;
    frame.size.height = sv.contentSize.height + 20.0;
    sv.frame = frame;
    
    if(sv.contentSize.height != self->_oldFrame.size.height){
        CGFloat sizeDiff = sv.contentSize.height - self->_oldFrame.size.height;
        [self updateFrame:sizeDiff];//self.mainTextView.contentSize.height];
    }
    
    self->_oldFrame = sv.frame;
    
}

- (void) updateFrame: (CGFloat) newHeight{
    CGFloat padding = 10.0;
    CGSize newSize = CGSizeMake(self.scrollerView.contentSize.width, self.scrollerView.contentSize.height + newHeight + padding);
    self.scrollerView.contentSize = newSize;// set the content size appropriately
    
    CGRect aRect = self.view.frame;// the frame's view rect for the entire view
    aRect.size.height -= self->_currentKeyboard.size.height;//this shrinks the box so we know if the new point is within it
    
    CGPoint scroller = CGPointMake(0.0, self.mainTextView.frame.origin.y + self.mainTextView.frame.size.height+5.0);
    
    if (!CGRectContainsPoint(aRect, scroller) ) {// check to see if the rect we create contains the text view
        CGFloat yVal = scroller.y;
        CGFloat newY = yVal-self->_currentKeyboard.size.height + padding;
        CGPoint scrollPoint = CGPointMake(0.0, newY);// calculating the difference here tells us that the content should move up only the distance between the y location of the textview and height of the keyboard size. Think about it like where it was before, minus the keyboard height that's now taking up space on the screen.;
        [self.scrollerView setContentOffset:scrollPoint animated:YES];
    }
    
}

- (void)hideKeyboard:(NSNotification*)aNotification
{
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollerView.contentInset = contentInsets;
    self.scrollerView.scrollIndicatorInsets = contentInsets;
}


- (IBAction)save:(id)sender {
    [self.mainTextView resignFirstResponder];
    [self.delegate didFinishEditingText:self.mainTextView.text];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
