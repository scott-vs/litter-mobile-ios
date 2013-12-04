//
//  Litt.h
//  Litter Mobile
//
//  Created by Scott VonSchilling on 12/3/13.
//  Copyright (c) 2013 Scott VonSchilling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LittUser;

@interface Litt : NSManagedObject

@property (nonatomic, retain) NSNumber * litt_id;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) LittUser *user;

@end
