//
//  SVSLoginViewController.h
//  Litter Mobile
//
//  Created by Scott VonSchilling on 12/1/13.
//  Copyright (c) 2013 Scott VonSchilling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVSLoginViewController : UIViewController<NSURLConnectionDataDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(IBAction)loginButtonPressed;
-(NSString *)sha1:(NSString*)input;

@end
