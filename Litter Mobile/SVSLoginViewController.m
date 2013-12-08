//
//  SVSLoginViewController.m
//  Litter Mobile
//
//  Created by Scott VonSchilling on 12/1/13.
//  Copyright (c) 2013 Scott VonSchilling. All rights reserved.
//

#import "SVSLoginViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "SVSTableViewController.h"
#import "SVSNewUserViewController.h"

@interface SVSLoginViewController (){
    NSMutableData *recievedData;
    NSString *plistPath;
    NSData *plistXML;
    NSDictionary *plistDict;
    NSString *userID;
}

@end

@implementation SVSLoginViewController

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
    
    // load backgound
    UIImage *bgImage =[UIImage imageNamed:@"litterlogin.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    
    //delagate text fields
    self.userName.delegate = self;
    self.password.delegate = self;
    
    // Activity monitor
    self.activity.hidesWhenStopped = YES;
    [self.view addSubview:self.activity];
}



- (void)viewDidAppear:(BOOL)animated{
    // load user properties
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
   
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"user_data.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"user_data" ofType:@"plist"];
    }
    
    plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    plistDict = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:&format
                                          errorDescription:&errorDesc];
    
    NSString *username = [plistDict objectForKey:@"name"];
    
    if (![username  isEqual: @""]){
        [self performSegueWithIdentifier:@"tableLoad" sender:self];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)loginButtonPressed{
    [self.activity startAnimating];
    // Send login creds to sever
    NSString *uname = self.userName.text;
    NSString *pass = self.password.text;
    pass = [self sha1:pass];
    
    NSURL *url = [NSURL URLWithString:@"http://gentle-island-3072.herokuapp.com/api/auth"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *dataString = [NSString stringWithFormat:@"u=%@&p=%@",uname,pass];
    NSData *dataData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:dataData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self ];
    [connection start];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    recievedData = [[NSMutableData alloc] init];
    if ([response respondsToSelector:@selector(statusCode)])
    {
        NSInteger statusCode = [((NSHTTPURLResponse *)response) statusCode];
        if (statusCode != 200)
        {
            [connection cancel];  // stop connecting; no more delegate messages
            NSLog(@"didReceiveResponse statusCode with %ld", (long)statusCode);
            UIAlertView *errorAlert =[[UIAlertView alloc] initWithTitle:@"Server Failure" message:@"Our server appears to be down. Please let Scott know so that he can restart it." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [errorAlert show];
            [self.activity stopAnimating];
        }
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [recievedData appendData:data];
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
    return nil;
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self.activity stopAnimating];
    UIAlertView *errorAlert =[[UIAlertView alloc] initWithTitle:@"Server Failure" message:@"Our server appears to be down. Please let Scott know so that he can restart it." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [errorAlert show];
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [self.activity stopAnimating];
    NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:recievedData options:kNilOptions error:nil];
    NSLog(@"response: %@", responseJson);
    NSNumber *sucess = [responseJson objectForKey:@"success"];
    if ([sucess integerValue]){
        // save user properties
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask, YES) objectAtIndex:0];
        plistPath = [rootPath stringByAppendingPathComponent:@"user_data.plist"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            plistPath = [[NSBundle mainBundle] pathForResource:@"user_data" ofType:@"plist"];
        }
        
        plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        plistDict = (NSDictionary *)[NSPropertyListSerialization
                                     propertyListFromData:plistXML
                                     mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                     format:&format
                                     errorDescription:&errorDesc];
        
        
        NSString *uname = self.userName.text;
        NSString *uid = [responseJson objectForKey:@"userId"];
        [plistDict setValue:uname forKey:@"name"];
        [plistDict setValue:uid forKey:@"uid"];
        userID = uid;
        [plistDict writeToFile:plistPath atomically:YES];
        
        [self performSegueWithIdentifier:@"tableLoad" sender:self];
    } else {
        UIAlertView *errorAlert =[[UIAlertView alloc] initWithTitle:@"Invalid Login" message:@"Invalid username and / or password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorAlert show];
    }
    
}


// Create sha1 hash for password
-(NSString*) sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"tableLoad"]) {
        SVSTableViewController *vc = (SVSTableViewController*)[segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.userID = userID;
        
    } else if ([[segue identifier] isEqualToString:@"createNew"]) {
        SVSNewUserViewController *vc = (SVSNewUserViewController*)[segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO;
    
}




@end
