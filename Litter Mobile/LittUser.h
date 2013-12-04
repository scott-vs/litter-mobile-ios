//
//  LittUser.h
//  Litter Mobile
//
//  Created by Scott VonSchilling on 12/4/13.
//  Copyright (c) 2013 Scott VonSchilling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LittUser : NSManagedObject

@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSString * user_name;
@property (nonatomic, retain) NSString * real_name;
@property (nonatomic, retain) NSString * toy;
@property (nonatomic, retain) NSString * spot;
@property (nonatomic, retain) NSString * bg_color;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * image_url;

@end
