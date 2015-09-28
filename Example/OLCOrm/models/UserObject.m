//
//  UserObject.m
//  OLCOrm
//
//  Created by Lakitha Samarasinghe on 8/18/14.
//  Copyright (c) 2014 Lakitha Samarasinghe. All rights reserved.
//

#import "UserObject.h"
#import "TestObject.h"

@implementation UserObject

- (NSArray *) hasTests
{
    return [self hasMany:[TestObject class] foreignKeyCol:@"userId"];
}

@end
