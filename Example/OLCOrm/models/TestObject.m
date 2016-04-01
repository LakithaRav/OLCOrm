//
//  TestObject.m
//  OLCOrm
//
//  Created by Lakitha Samarasinghe on 8/10/14.
//  Copyright (c) 2014 Lakitha Samarasinghe. All rights reserved.
//

#import "TestObject.h"
#import "UserObject.h"

@implementation TestObject

//@dynamic Id;

- (UserObject *) hasUser
{
    return (UserObject*) [self belongTo:[UserObject class] foreignKeyCol:@"userId"];
}

+ (NSArray *) ignoredProperties
{
    return @[@"status"];
}

+ (BOOL) debug
{
    return NO;
}

@end
