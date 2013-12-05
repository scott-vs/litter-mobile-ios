//
//  SVSDetailViewController.h
//  Litter Mobile
//
//  Created by Scott VonSchilling on 12/4/13.
//  Copyright (c) 2013 Scott VonSchilling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Litt.h"
#import "LittUser.h"

@interface SVSDetailViewController : UIViewController

@property (strong, nonatomic) Litt *myLitt;
- (IBAction)closeBtn:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UILabel *message;
@property (strong, nonatomic) IBOutlet UIImageView *userpic;

@end
