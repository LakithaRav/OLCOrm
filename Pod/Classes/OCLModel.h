//
//  OCLModel.h
//  FMDB Database Tutorial
//
//  Created by Lakitha Samarasinghe on 8/6/14.
//  Copyright (c) 2014 Fidenz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+KJSerializer.h"
#import "OLCTableHandler.h"

@interface OCLModel : NSObject
{
    OLCTableHandler *queryH;
}

// CRUD OPTS.
- (BOOL) save;
- (BOOL) update;
- (BOOL) delete;

// COMMON STUFF
- (NSObject *) find:(NSNumber *) Id;
- (NSArray *) findAll;
- (NSArray *) whereColumn:(NSString *) column byOperator:(NSString *) opt forValue:(NSString *) value;
- (NSArray *) where:(NSString *) clause sortBy:(NSString *) sorter;
- (NSArray *) query:(NSString *) query;
@end
