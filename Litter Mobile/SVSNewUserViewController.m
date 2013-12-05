//
//  SVSNewUserViewController.m
//  Litter Mobile
//
//  Created by Scott VonSchilling on 12/4/13.
//  Copyright (c) 2013 Scott VonSchilling. All rights reserved.
//

#import "SVSNewUserViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "SVSTableViewController.h"

@interface SVSNewUserViewController (){
    NSMutableData *recievedData;
    NSString *plistPath;
    NSData *plistXML;
    NSDictionary *plistDict;
    NSString *userID;
}

@end

@implementation SVSNewUserViewController

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
    [self.view endEditing:YES];
    self.username.delegate = self;
    self.password.delegate = self;
    self.realname.delegate = self;
    self.toy.delegate = self;
    self.spot.delegate = self;
    self.location.delegate = self;
    self.website.delegate = self;
    self.bio.delegate = self;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [self createBtn:self];
    }
    return NO;

}



- (IBAction)createBtn:(id)sender {
    NSString *pass = self.password.text;
    pass = [self sha1:pass];
    
    NSURL *url = [NSURL URLWithString:@"http://gentle-island-3072.herokuapp.com/api/newUser"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *dataString = [NSString stringWithFormat:@"userName=%@&password=%@&realName=%@&toy=%@&spot=%@&bgColor=%@&bio=%@&location=%@&website=%@", self.username.text,pass,self.realname.text,self.toy.text,self.spot.text,@"FFFFFF",self.bio.text,self.location.text,self.website.text];
    NSData *dataData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:dataData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self ];
    
    [connection start];
    

    
}



-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    recievedData = [[NSMutableData alloc] init];
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    [recievedData appendData:data];
    
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
    
    return nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *returnString = [[NSString alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",returnString);
    
    NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:recievedData options:kNilOptions error:nil];
    
    NSNumber *sucess = [responseJson objectForKey:@"success"];
    if ([sucess integerValue]){
        NSLog(@"Success");
        
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
        
        
        NSString *uname = self.username.text;
        NSString *uid = [responseJson objectForKey:@"userId"];
        [plistDict setValue:uname forKey:@"name"];
        [plistDict setValue:uid forKey:@"uid"];
        userID = uid;
        [plistDict writeToFile:plistPath atomically:YES];
        
        [self performSegueWithIdentifier:@"userCreated" sender:self];
    }
    

    
}



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
    NSLog(@"inside prepare for segue %@", [segue identifier]);
    if ([[segue identifier] isEqualToString:@"userCreated"]) {
        //[[segue destinationViewController] setDelegate:self];
        
        // Get reference to the destination view controller
        SVSTableViewController *vc = (SVSTableViewController*)[segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.managedObjectContext = self.managedObjectContext;
        vc.userID = userID;
        NSLog(@"end segue");
        
    }
}



@end
