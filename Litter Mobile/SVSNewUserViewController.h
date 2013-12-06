//
//  SVSNewUserViewController.h
//  Litter Mobile
//
//  Created by Scott VonSchilling on 12/4/13.
//  Copyright (c) 2013 Scott VonSchilling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVSNewUserViewController : UIViewController <UITextFieldDelegate, NSURLConnectionDataDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UITextField *realname;
@property (strong, nonatomic) IBOutlet UITextField *toy;
@property (strong, nonatomic) IBOutlet UITextField *spot;
@property (strong, nonatomic) IBOutlet UITextField *location;
@property (strong, nonatomic) IBOutlet UITextField *website;
@property (strong, nonatomic) IBOutlet UITextField *bio;
- (IBAction)createBtn:(id)sender;


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
- (IBAction)photoBtn:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *userpic;
- (IBAction)takePhoto:(id)sender;

@end
