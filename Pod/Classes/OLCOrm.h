//
//  OLCOrm.h
//  Pods
//
//  Created by Lakitha Samarasinghe on 4/26/15.
//
//

#import <Foundation/Foundation.h>
#import "OLCMigrator.h"

#define OLCORM_NOTIFICATION @"OLCOrmNotficationMsg"

@interface OLCOrm : NSObject


+(OLCOrm *) databaseName:(NSString *) database version:(NSNumber *) version enableDebug:(BOOL) debug;
+(OLCOrm *) getSharedInstance;

@property (nonatomic, assign) BOOL debugable;

- (BOOL) isDebugEnabled;
- (BOOL) makeTable:(Class) model;
- (BOOL) makeTable:(Class) model withTableVersion:(NSNumber *) dbVersion;

@end
