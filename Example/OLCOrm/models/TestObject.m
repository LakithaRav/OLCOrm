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

- (UserObject *) hasUser
{
    return (UserObject*) [self hasOne:[UserObject class] foreignKeyCol:@"userId" primaryKeyCol:@"Id"];
}

@end
