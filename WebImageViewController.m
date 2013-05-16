//
//  WebImageViewController.m
//  TestIMGURLAndResize
//
//  Created by Ben Bonnet on 5/14/13.
//  Copyright (c) 2013 Ben Bonnet. All rights reserved.
//

#import "WebImageViewController.h"

@interface WebImageViewController ()
- (void) loadURLImg:(UIImage*)mImg;// loads the image into the imageView;
- (void) getImage:(NSString*)imgPath;// launches the request and returns when the request is fulfilled
@end

@implementation WebImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.av setHidden:YES];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loadImage:(id)sender {
    if(![self.imageURLTxt.text isEqualToString:@""]){
        [self getImage:self.imageURLTxt.text];
    }else{
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Please Enter a URL" message:@"You must enter a valid image URL" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [av show];
    }
    
}

- (IBAction)save:(id)sender {
    if(self->_webImage != nil){
        [self.delegate userDidSelectImage:self->_webImage];
    }
}

- (IBAction)launchBrowser:(id)sender {
    
    NSURL * imageURL = [NSURL URLWithString:@"http://images.google.com"];
    
    [[UIApplication sharedApplication] openURL:imageURL];
}

-(void) getImage:(NSString*)imgPath{
    NSURL *imgURL = [NSURL URLWithString:imgPath];
    NSURLRequest *imgReq = [NSURLRequest requestWithURL:imgURL];

    [self.av setHidden:NO];
    [self.av startAnimating];
    [NSURLConnection sendAsynchronousRequest:imgReq queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *resp, NSData *d, NSError *error) {
    if(!error){
        UIImage *img = [UIImage imageWithData:d];
        //UIImage *croppedImg = [img resizedImage:CGSizeMake(250.0, 250.0) interpolationQuality:0];
        
        //UIImage *roundee = [img thumbnailImage:250 transparentBorder:1 cornerRadius:15 interpolationQuality:0];
        if(img != nil){
            self->_webImage = img;
            [self performSelectorOnMainThread:@selector(loadURLImg:) withObject:img waitUntilDone:YES];//can block it because it's not the main thread
        }else{
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error retrieving image" message:@"You must enter a valid image URL" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [av show];
        }
        
    }
}];

}

- (void) loadURLImg:(UIImage*)mImg{
    UIImage *roundee = [mImg thumbnailImage:250 transparentBorder:1 cornerRadius:15 interpolationQuality:1];
    [self.mainImageView setImage:roundee];
    [self.av stopAnimating];
    [self.av setHidden:YES];
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
    
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return  YES;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}





- (IBAction)cancel:(id)sender {
    [self.delegate userDidCancel];
    
}
@end
