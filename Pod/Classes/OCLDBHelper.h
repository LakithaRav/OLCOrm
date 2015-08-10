//
//  OCLDBHelper.h
//  FMDB Database Tutorial
//
//  Created by Lakitha Samarasinghe on 8/6/14.
//  Copyright (c) 2014 Fidenz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "OLCMigrator.h"

@interface OCLDBHelper : NSObject

//+(OCLDBHelper *) sharedInstance:(NSString *) database;

@property (nonatomic, retain) NSString* databaseName;

- (FMDatabase *) getDb;
- (FMDatabaseQueue *) getQueueDb;
- (BOOL) makeTable:(Class) model;
- (BOOL) makeRawTable:(NSString *) query;

@end
