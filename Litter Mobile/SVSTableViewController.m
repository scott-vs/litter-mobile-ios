//
//  SVSTableViewController.m
//  Litter Mobile
//
//  Created by Scott VonSchilling on 12/1/13.
//  Copyright (c) 2013 Scott VonSchilling. All rights reserved.
//

#import "SVSTableViewController.h"
#import "Litt.h"
#import "LittUser.h"
#import "SVSAppDelegate.h"
#import "SVSDetailViewController.h"

@interface SVSTableViewController (){
    NSMutableData *recievedData;
    NSMutableArray *littArray;
    NSURLConnection *getAllConnection;
    NSURLConnection *postNewListConnection;
    LittUser *myUser;
}

@end

@implementation SVSTableViewController

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
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.littField.delegate = self;
    
    NSURL *url = [NSURL URLWithString:@"http://gentle-island-3072.herokuapp.com/api/all"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    
    getAllConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self ];
    
    [getAllConnection start];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
    if (connection == getAllConnection){
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:recievedData options:kNilOptions error:nil];
    NSArray *users = [responseJson objectForKey:@"Users"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LittUser" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSMutableDictionary *usedUsers = [[NSMutableDictionary alloc] init];
    
    for (LittUser *user in fetchedObjects) {
        [usedUsers setObject:user forKey:user.user_id];
    }
    for (NSDictionary *user in users){
        LittUser *lUser = [NSEntityDescription insertNewObjectForEntityForName:@"LittUser" inManagedObjectContext:context];
        if (![[usedUsers allKeys] containsObject:[user objectForKey:@"user_id"]]){
            lUser.user_id = [user objectForKey:@"user_id"];
            lUser.user_name = [user objectForKey:@"user_name"];
            lUser.real_name = [user objectForKey:@"real_name"];
            lUser.toy = [user objectForKey:@"toy"];
            lUser.spot = [user objectForKey:@"spot"];
            lUser.bg_color = [user objectForKey:@"bg_color"];
            lUser.bio = [user objectForKey:@"bio"];
            lUser.website = [user objectForKey:@"website"];
            lUser.location = [user objectForKey:@"location"];
            lUser.image_url = [user objectForKey:@"image_url"];
            //@"http://www.redrovercamping.com/sites/all/themes/rr2/images/default_usr.png"
            
            [usedUsers setObject:lUser forKey:lUser.user_id];
            
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            } else {
                [lUser getPicture:entity forContext:context forTable:[self tableView]];
            }
        }
        
    }
    
    
    NSArray *litts = [responseJson objectForKey:@"Litts"];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"Litt" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSMutableDictionary *littList = [[NSMutableDictionary alloc] init];
    
    for (Litt *ll in fetchedObjects){
       [littList setObject:ll forKey:ll.litt_id];
    }
    for (NSDictionary *litt in litts){
        if (![[littList allKeys] containsObject:[litt objectForKey:@"litt_id"]]){
            Litt *newLitt = [NSEntityDescription insertNewObjectForEntityForName:@"Litt" inManagedObjectContext:context];
            LittUser *lu = [usedUsers objectForKey:[litt objectForKey:@"user_id"]];
            newLitt.user = lu;
            newLitt.text = [litt objectForKey:@"text"];
            newLitt.litt_id = [litt objectForKey:@"litt_id"];
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-ddThh:mm:ssZ"];
            NSDate *myDate = [df dateFromString: [litt objectForKey:@"date"]];
            newLitt.date = myDate;
            [littList setObject:newLitt forKey:newLitt.litt_id];
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
            
        }
        
    }
    NSArray * sortedKeys = [[[[littList allKeys] sortedArrayUsingSelector: @selector(compare:)] reverseObjectEnumerator] allObjects];

    NSArray *littArray1 = [littList objectsForKeys:sortedKeys notFoundMarker:[NSNull null]];
    littArray = [[NSMutableArray alloc] initWithArray:littArray1];
     myUser = [usedUsers objectForKey:self.userID];
    }
    else if (connection == postNewListConnection){
        NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:recievedData options:kNilOptions error:nil];
        
        NSNumber *sucess = [responseJson objectForKey:@"success"];
        if ([sucess integerValue]){
            NSManagedObjectContext *context = [self managedObjectContext];
            Litt *newLitt = [NSEntityDescription insertNewObjectForEntityForName:@"Litt" inManagedObjectContext:context];
            newLitt.user = myUser;
            newLitt.text = self.littField.text;
            newLitt.date = [NSDate date];
            
            newLitt.litt_id = [responseJson objectForKey:@"litt_id"];
            NSError *error;
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            } else {
                [littArray insertObject:newLitt atIndex:0];
                self.littField.text = @"";
            }
        }
        
    }
    
    [self.tableView reloadData];
   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [littArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *simpleTableIdentifier = @"LittCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    Litt *l = [littArray objectAtIndex:indexPath.row];
    
    cell.backgroundColor = [l.user backgroundColor];//[self colorFromHexString: l.user.bg_color];

    UIImageView *userpic = (UIImageView *)[cell viewWithTag:100];
    userpic.image = [UIImage imageWithData:l.user.userpic];
    UILabel *recipeNameLabel = (UILabel *)[cell viewWithTag:101];
    recipeNameLabel.text = l.user.user_name;
    UILabel *recipeDetailLabel = (UILabel *)[cell viewWithTag:102];
    recipeDetailLabel.text = l.text;
    
    return cell;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"details"]) {
        SVSDetailViewController *vc = (SVSDetailViewController*)[segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        vc.myLitt = [littArray objectAtIndex:indexPath.row];
        
    }
}


- (IBAction)newMessage:(id)sender {
    [self.littField resignFirstResponder];
    [self.activity startAnimating];
    NSString *urlString = [NSString stringWithFormat:@"http://gentle-island-3072.herokuapp.com/api/%@/litt",self.userID];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *dataString = [NSString stringWithFormat:@"litt=%@", self.littField.text];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSData *dataData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:dataData];
    
    postNewListConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self ];
    recievedData = [[NSMutableData alloc] init];
    [postNewListConnection start];

}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
@end
