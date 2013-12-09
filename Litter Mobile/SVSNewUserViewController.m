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
#import "LittUser.h"

@interface SVSNewUserViewController (){
    NSMutableData *recievedData;
    NSString *plistPath;
    NSData *plistXML;
    NSDictionary *plistDict;
    NSString *userID;
    NSData *pngData;
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
    
    // Activity monitor
    self.activity.hidesWhenStopped = YES;
    [self.view addSubview:self.activity];
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
    }
    return NO;

}


- (IBAction)createBtn:(id)sender {
    if ([self.username.text length] == 0 || [self.password.text length] == 0
        || [self.realname.text length] == 0 || [self.location.text length] == 0
        || [self.website.text length] == 0 || [self.bio.text length] == 0
        || [self.toy.text length] == 0 || [self.spot.text length] == 0) {
        UIAlertView *errorAlert =[[UIAlertView alloc] initWithTitle:@"Incomplete" message:@"Please fill out all values." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorAlert show];
        
    } else {
        [self.activity startAnimating];
        
        NSString *pass = self.password.text;
        pass = [self sha1:pass];
        
        NSURL *url = [NSURL URLWithString:@"http://gentle-island-3072.herokuapp.com/api/newUser"];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        
        NSString *dataString = [NSString stringWithFormat:@"userName=%@&password=%@&realName=%@&toy=%@&spot=%@&bgColor=%@&bio=%@&location=%@&website=%@", self.username.text,pass,self.realname.text,self.toy.text,self.spot.text,@"#CCCCCC",self.bio.text,self.location.text,self.website.text];
        dataString = [dataString stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSData *dataData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:dataData];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self ];
        NSLog(@"Starting connections:");
        [connection start];
    }

    
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

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self.activity stopAnimating];
    UIAlertView *errorAlert =[[UIAlertView alloc] initWithTitle:@"Server Failure" message:@"Our server appears to be down. Please let Scott know so that he can restart it." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [errorAlert show];
    
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
    
    return nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [self.activity stopAnimating];
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
        
        
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error;
        LittUser *lUser = [NSEntityDescription insertNewObjectForEntityForName:@"LittUser" inManagedObjectContext:context];
        
        lUser.user_id = [NSNumber numberWithInteger: [userID integerValue]];;
        lUser.user_name = self.username.text;
        lUser.real_name = self.realname.text;
        lUser.toy = self.toy.text;
        lUser.spot = self.spot.text;
        lUser.bg_color = @"#CCCCCC";
        lUser.bio = self.bio.text;
        lUser.website = self.website.text;
        lUser.location = self.location.text;
        lUser.image_url = @"local";
        lUser.userpic = pngData;
        
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        } else {
           [self performSegueWithIdentifier:@"userCreated" sender:self];
        }
        
        
        
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
    if ([[segue identifier] isEqualToString:@"userCreated"]) {
        // Get reference to the destination view controller
        SVSTableViewController *vc = (SVSTableViewController*)[segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.managedObjectContext = self.managedObjectContext;
        vc.userID = userID;
    }
}



- (IBAction)photoBtn:(id)sender {
    UIImagePickerController *picker =[[UIImagePickerController alloc] init];
    
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    pngData = UIImagePNGRepresentation(chosenImage);
    
    self.userpic.image = [UIImage imageWithData:pngData];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (IBAction)takePhoto:(id)sender {
    UIImagePickerController *picker =[[UIImagePickerController alloc] init];
    
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    
    [self presentViewController:picker animated:YES completion:NULL];

}
@end
