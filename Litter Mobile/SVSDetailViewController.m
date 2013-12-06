//
//  SVSDetailViewController.m
//  Litter Mobile
//
//  Created by Scott VonSchilling on 12/4/13.
//  Copyright (c) 2013 Scott VonSchilling. All rights reserved.
//

#import "SVSDetailViewController.h"

@interface SVSDetailViewController ()

@end

@implementation SVSDetailViewController

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
    
    self.username.text = self.myLitt.user.user_name;
    self.message.text = [NSString stringWithFormat:@"\"%@\"", self.myLitt.text];
    [self.message sizeToFit];
    self.userpic.image = [UIImage imageWithData:self.myLitt.user.userpic];
    self.view.backgroundColor = [self.myLitt.user backgroundColor];
    self.bio.text = self.myLitt.user.bio;
    self.toy.text = self.myLitt.user.toy;
    self.spot.text = self.myLitt.user.spot;
    self.location.text = self.myLitt.user.location;
    self.website.scalesPageToFit = YES;
    [self.website loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.myLitt.user.website]]];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)closeBtn:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
