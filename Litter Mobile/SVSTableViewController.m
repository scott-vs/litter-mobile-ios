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

@interface SVSTableViewController (){
    NSMutableData *recievedData;
    NSArray *littArray;
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
    
    NSURL *url = [NSURL URLWithString:@"http://0.0.0.0:5000/api/all"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self ];
    
    [connection start];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    //NSString *returnString = [[NSString alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",returnString);
    
    
    //SVSAppDelegate *appDelegate = (SVSAppDelegate *)[[UIApplication sharedApplication]delegate];
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
    NSLog(@"Used users: %@", usedUsers);
    for (NSDictionary *user in users){
        NSLog(@"%@", [user objectForKey:@"user_id"]);
        NSLog(@"%@", [user objectForKey:@"user_name"]);
        LittUser *lUser = [NSEntityDescription insertNewObjectForEntityForName:@"LittUser" inManagedObjectContext:context];
        if (![[usedUsers allKeys] containsObject:[user objectForKey:@"user_id"]]){
            NSLog(@"Not found");
            lUser.user_id = [user objectForKey:@"user_id"];
            lUser.user_name = [user objectForKey:@"user_name"];
            lUser.real_name = [user objectForKey:@"real_name"];
            lUser.toy = [user objectForKey:@"toy"];
            lUser.spot = [user objectForKey:@"spot"];
            lUser.bg_color = [user objectForKey:@"bg_color"];
            lUser.bio = [user objectForKey:@"bio"];
            //lUser.website = [user objectForKey:@"website"];
            lUser.location = [user objectForKey:@"location"];
            //lUser.image_url = [user objectForKey:@"image_url"];
            
            [usedUsers setObject:lUser forKey:lUser.user_id];
            
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
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

    littArray = [littList objectsForKeys:sortedKeys notFoundMarker:[NSNull null]];
    
    [self.tableView reloadData];
   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"in table view");
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
    
    //cell.textLabel.text = l.text;
    
    //UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    //recipeImageView.image = [UIImage imageNamed:recipe.imageFile];
    UILabel *recipeNameLabel = (UILabel *)[cell viewWithTag:101];
    recipeNameLabel.text = l.user.user_name;
    UILabel *recipeDetailLabel = (UILabel *)[cell viewWithTag:102];
    recipeDetailLabel.text = l.text;
    
    return cell;
    
}

@end
