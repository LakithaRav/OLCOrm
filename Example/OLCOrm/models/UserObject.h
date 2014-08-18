//
//  UserObject.h
//  OLCOrm
//
//  Created by Lakitha Samarasinghe on 8/18/14.
//  Copyright (c) 2014 Lakitha Samarasinghe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCLModel.h"

@class TestObject;

@interface UserObject : OCLModel

@property (nonatomic, retain) NSNumber* Id;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* desc;
@property (nonatomic, retain) NSNumber* status;

- (NSArray *) hasTests;

@end
