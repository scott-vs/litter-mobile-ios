//
//  LittUser.h
//  Litter Mobile
//
//  Created by Scott VonSchilling on 12/3/13.
//  Copyright (c) 2013 Scott VonSchilling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LittUser : NSManagedObject

@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSString * user_name;

@end
