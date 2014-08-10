//
//  OLCTableHandler.h
//  FMDB Database Tutorial
//
//  Created by Lakitha Samarasinghe on 8/6/14.
//  Copyright (c) 2014 Fidenz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OLCTableHandler : NSObject

- (NSString *) createTableQuery:(Class) model;
- (NSString *) createInsertQuery:(NSObject *) data;
- (NSString *) createUpdateQuery:(NSObject *) data;
- (NSString *) createDeleteQuery:(NSObject *) data;

- (NSString *) createFindByIdQuery:(Class) model forId:(NSNumber *) Id;
- (NSString *) createFindAllQuery:(Class) model;
- (NSString *) createWhereQuery:(Class) model withFilter:(NSString *) filter andSort:(NSString *) sorter;
- (NSString *) createFindWhere:(Class) model forVal:(NSString *) value byOperator:(NSString *) opt inColumn:(NSString *) column;

@end
