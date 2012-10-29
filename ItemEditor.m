//
//  ItemEditor.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ItemEditor.h"
#import "TemplateLoader.h"
#import "TextEntryViewController.h"

#define int NUMBER_OF_LINES = 3;

@implementation ItemEditor


@synthesize delegate = _delegate;
@synthesize scrollerView = _scrollerView;
@synthesize titleTxt = _titleTxt;
@synthesize saveBtn = _saveBtn;
@synthesize cancelBtn = _cancelBtn;
@synthesize swapTemplateBtn = _swapTemplateBtn;
@synthesize didMakeChanges = _didMakeChanges;
//@synthesize buildItem = _buildItem;
@synthesize activeTextField = _activeTextField;
@synthesize activeView = _activeView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardWillHideNotification object:nil];

    self.didMakeChanges = NO;
//    self.buildItem = [self.delegate loadBuildItem];
//    NSLog(@"*****ID: %@", self.buildItem.screenID);
//    [self populateItems];
    
        
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setSaveBtn:nil];
    [self setDelegate:nil];
    [self setScrollerView:nil];
    [self setTitleTxt:nil];
    [self setCancelBtn:nil];
    [self setSwapTemplateBtn:nil];
    [self setDidMakeChanges:NO];
    [self setActiveTextField:nil];
    [self setActiveView:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil]; 
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];  
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


/* ------ BOILERPLATE ITEMEDITOR METHODS -----------*/

#pragma mark - textField delegate methods

-(void) textFieldDidEndEditing:(UITextField *)textField{
    if(textField == self.titleTxt){
        [textField resignFirstResponder];
    }
}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    self.activeTextField = textField;// assign private variable the value of the textField
    self.activeView = self.activeTextField;
    self.didMakeChanges = YES;// set the boolean to make sure we know things changed and can save before returning 
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    if(textField == self.titleTxt)
    {
            [textField resignFirstResponder];
    }
    
    return YES;
}





- (void)showKeyboard:(NSNotification*)aNotification
{
    NSString *test = @"test";
}
// this method is responsible for actually sizing the scroll view when the keyboard is present

- (void)hideKeyboard:(NSNotification*)aNotification
{
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollerView.contentInset = contentInsets;
    self.scrollerView.scrollIndicatorInsets = contentInsets;
}


// each implemenation will override this method to take it's own screenshot to account for the size of the screen 
- (NSString*) takeScreenShot{
        

}






- (void)deleteScreenShot{
    
}


#pragma mark - AlertView delegate methods

- (IBAction)showSwitchMessage:(id)sender{
    UIAlertView *alertMsg = [[UIAlertView alloc] initWithTitle:@"Switch Template?" message:@"You will receive a new template and you will lose the data on this template." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    
    [alertMsg show];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex !=0){
        [self swapTemplate];
    }
    
    
}

- (void) alertViewCancel:(UIAlertView *)alertView{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark swap templates

- (void)swapTemplate{
    TemplatePicker *template = [[TemplatePicker alloc] initWithNibName:@"TemplatePicker" bundle:[NSBundle mainBundle]];
    template.delegate = self;        
    
    [self presentViewController:template animated:YES completion:^(void){
        // add in some post view showing stuff here, executes when the view is loaded and animated in
        
    }];
    
}


#pragma mark TemplatePickerDelegate methods
// this will swap the current viewcontrollers list in the navigation controller for a new one with the selected template in it
- (void) didChooseTemplate:(NSString *)templateType{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate setCurrentItemTypeString:templateType];
        TemplateLoader *tempLoader = [[TemplateLoader alloc] init];
                ItemEditor *templateChosen = [tempLoader loadEditor:templateType withDelegate:self.delegate];
                NSArray *currentArr = [self.navigationController viewControllers];
                NSMutableArray *newArr = [[NSMutableArray alloc] init];
                newArr = [NSMutableArray arrayWithArray:currentArr];
//                if([newArr respondsToSelector:@selector(removeLastObject)])
//                {
                    
                    [newArr removeLastObject];
//                }
        /* below is working if above does not */
//                for(int i = 0; i<[currentArr count]; i++){
//                    [newArr addObject:[currentArr objectAtIndex:i]];
//                    
//                }
//                [newArr removeLastObject];
                [newArr addObject:templateChosen];
                [self.navigationController setViewControllers:newArr animated:YES];
                
    }];     
}

- (void) userDidCancel{
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark - Common Actions for all item editors, some of these will be overridden
- (IBAction)save:(id)sender {
//    if(self.didMakeChanges){
//        
//    }
//    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)cancel:(id)sender{
    
}

- (IBAction)deleteBuildItem:(id)sender{
    }

- (void) populateItems{
    // this is a stub that each editor will override to do the necessary item population
}


- (NSString*) GetUUID{
    CFUUIDRef uid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uid);
    CFRelease(uid);
    return (__bridge NSString*)string;
}

@end
