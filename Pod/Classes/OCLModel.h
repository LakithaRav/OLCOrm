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
#import "OLCOrm.h"
#import "OLCOrmNotification.h"

@interface OCLModel : NSObject
{
    OLCTableHandler *queryH;
}

@property (nonatomic, retain) NSNumber* Id;

// CRUD OPTS.
- (BOOL) save;
- (NSNumber*) saveAndGetId;
- (BOOL) update;
- (BOOL) delete;

// RELATIONSHIPS
- (NSObject *) hasOne:(Class) model foreignKeyCol:(NSString *) fkey /*primaryKeyCol:(NSString *) pkey*/;
- (NSArray *) hasMany:(Class) model foreignKeyCol:(NSString *) fkey /*primaryKeyCol:(NSString *) pkey*/;
- (NSObject *) belongTo:(Class) model foreignKeyCol:(NSString *) pkey;
//- (NSArray *) belongToMany:(Class) model inMapping:(Class) mapmodel foreignKeyCol:(NSString *) fkey primaryKeyCOl:(NSString *) pkey;

// STATIC STUFF
+ (NSString*) primaryKey;
+ (BOOL) primaryKeyAutoIncrement;
+ (NSArray *)ignoredProperties;
+ (BOOL) debug;
+ (NSObject *) find:(NSNumber *) Id;
+ (NSArray*) all;
+ (NSArray *) whereColumn:(NSString *) column byOperator:(NSString *) opt forValue:(NSString *) value accending:(BOOL) sort;
+ (NSArray *) where:(NSString *) clause sortBy:(NSString *) column accending:(BOOL) sort;
+ (NSArray *) query:(NSString *) query;
+ (BOOL) truncateTable;

+ (void) notifyOnChanges:(id) context withMethod:(SEL) method;
@end
