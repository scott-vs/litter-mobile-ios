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
    UIImage *bgImage =[UIImage imageNamed:@"litterlogin.png"];
    bgImage.size.width;
    self.view.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    //UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"litterlogin.png"]];
    //backgroundImage.frame = CGRectMake(0,0, 640, 100);
    
    //backgroundImage.contentMode = UIViewContentModeScaleAspectFit;;
    //backgroundImage.clipsToBounds = YES;

    //[self.view addSubview:backgroundImage];
    //[self.view sendSubviewToBack:backgroundImage];
	// Do any additional setup after loading the view.
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
    
    NSLog(@"plist: %@",plistDict);
    if (![username  isEqual: @""]){
        NSLog(@"YES");
        [self performSegueWithIdentifier:@"tableLoad" sender:self];
    }
    
    //[plistXML writeToFile:plistPath atomically:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)loginButtonPressed{
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
    
    NSLog(@"%@ %@", uname, [self sha1:pass]);
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
        
        
        NSString *uname = self.userName.text;
        NSString *uid = [responseJson objectForKey:@"userId"];
        [plistDict setValue:uname forKey:@"name"];
        [plistDict setValue:uid forKey:@"uid"];
        userID = uid;
        NSLog(@"plist: %@",plistXML);
        [plistDict writeToFile:plistPath atomically:YES];
        
        [self performSegueWithIdentifier:@"tableLoad" sender:self];
    } else {
        NSLog(@"Nope");
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
    if ([[segue identifier] isEqualToString:@"tableLoad"]) {
        SVSTableViewController *vc = (SVSTableViewController*)[segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.managedObjectContext = self.managedObjectContext;
        vc.userID = userID;
        NSLog(@"end segue");
        
    } else if ([[segue identifier] isEqualToString:@"createNew"]) {
        SVSNewUserViewController *vc = (SVSNewUserViewController*)[segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
    }
}




@end
