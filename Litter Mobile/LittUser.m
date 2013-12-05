//
//  LittUser.m
//  Litter Mobile
//
//  Created by Scott VonSchilling on 12/4/13.
//  Copyright (c) 2013 Scott VonSchilling. All rights reserved.
//

#import "LittUser.h"


@implementation LittUser{
    NSEntityDescription *myEntity;
    NSManagedObjectContext *myContext;
    NSMutableData *recievedData;
}

@dynamic bg_color;
@dynamic bio;
@dynamic image_url;
@dynamic location;
@dynamic real_name;
@dynamic spot;
@dynamic toy;
@dynamic user_id;
@dynamic user_name;
@dynamic website;
@dynamic userpic;

-(void) getPicture:(NSEntityDescription*) entity forContext:(NSManagedObjectContext *) context{
    myEntity = entity;
    myContext = context;
    
    NSURL *url = [NSURL URLWithString:self.image_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
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
    self.userpic = recievedData;
    NSError *error;
    if (![myContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

- (UIColor *)backgroundColor {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:self.bg_color];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
