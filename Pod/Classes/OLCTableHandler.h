//
//  OLCTableHandler.h
//  FMDB Database Tutorial
//
//  Created by Lakitha Samarasinghe on 8/6/14.
//  Copyright (c) 2014 Fidenz. All rights reserved.
//


#define OLC_D_QUERY @"dQuery"
#define OLC_D_DATA @"dData"

#import <Foundation/Foundation.h>

@interface OLCTableHandler : NSObject

@property (nonatomic) BOOL logEnabled;

- (NSString *) createTableQuery:(Class) model;
- (NSDictionary *) createInsertQuery:(NSObject *) data;
- (NSDictionary *) createUpdateQuery:(NSObject *) data;
- (NSString *) createDeleteQuery:(NSObject *) data;

- (NSString *) createFindByIdQuery:(Class) model forId:(NSNumber *) Id;
- (NSString *) createFindAllQuery:(Class) model;
- (NSString *) createWhereQuery:(Class) model withFilter:(NSString *) filter andSort:(NSString *) column accending:(BOOL) sort;
- (NSDictionary *) createFindWhere:(Class) model forVal:(NSString *) value byOperator:(NSString *) opt inColumn:(NSString *) column accending:(BOOL) sort;

- (NSString *) createOneToOneRelationQuery:(NSObject *) data foreignClass:(Class) fmodel foreignKey:(NSString *) fkey primaryKey:(NSString *) pkey;
- (NSString *) createOneToManyRelationQuery:(NSObject *) data foreignClass:(Class) fmodel foreignKey:(NSString *) fkey primaryKey:(NSString *) pkey;

- (NSString *) createTruncateTableQuery:(Class) model;
- (NSString *) createLastInsertRecordIdQuery:(Class) model;

@end
