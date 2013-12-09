//
//  SVSTableViewController.h
//  Litter Mobile
//
//  Created by Scott VonSchilling on 12/1/13.
//  Copyright (c) 2013 Scott VonSchilling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVSTableViewController : UIViewController <NSURLConnectionDataDelegate,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) IBOutlet UITextField *littField;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;



- (IBAction)newMessage:(id)sender;
- (UIColor *)colorFromHexString:(NSString *)hexString;
@end
