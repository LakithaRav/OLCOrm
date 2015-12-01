//
//  OCLDBHelper.m
//  FMDB Database Tutorial
//
//  Created by Lakitha Samarasinghe on 8/6/14.
//  Copyright (c) 2014 Fidenz. All rights reserved.
//

#import "OCLDBHelper.h"
#import "OLCTableHandler.h"

#define OLC_LOG @"OLCLOG"

@implementation OCLDBHelper

//static OCLDBHelper *_sharedInt = nil;
//
//+(OCLDBHelper *) sharedInstance:(NSString *) database
//{
//    static dispatch_once_t oncePredicate;
//    dispatch_once(&oncePredicate, ^{
//
//        _sharedInt = [[self alloc] init];
//        _sharedInt.databaseName = database;
//        
//    });
//    
//    return _sharedInt;
//}


- (FMDatabase *) getDb
{
    OLCMigrator *orm = [OLCMigrator getSharedInstance];
    
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];
    NSString *dbPath = [documentsDir   stringByAppendingPathComponent:orm.databasePath];
    
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    
    return database;
}

- (FMDatabaseQueue *) getQueueDb
{
    OLCMigrator *orm = [OLCMigrator getSharedInstance];
    
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];
    NSString *dbPath = [documentsDir   stringByAppendingPathComponent:orm.databasePath];
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    
    return queue;
}

- (BOOL) makeTable:(Class) model
{
    BOOL isCreated = NO;
    
    OLCTableHandler *tblH = [[OLCTableHandler alloc] init];
    
    NSString *statment = [tblH createTableQuery:model];
    
    FMDatabaseQueue* queue = [self getQueueDb];
    
    @try
    {
        [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [db executeStatements:statment];
        }];
        
        isCreated = YES;
        
//        isCreated = [database executeStatements:statment];
    }
    @catch (NSException *exception)
    {
        NSLog(@"[%@]: DBException : %@ %@", OLC_LOG, exception.name, exception.reason);
    }
    @finally
    {
        [queue close];
    }
    
    return isCreated;
}

- (BOOL) makeRawTable:(NSString *) query
{
    BOOL isCreated = NO;
    
    FMDatabaseQueue* queue = [self getQueueDb];
    
    @try
    {
        [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [db executeStatements:query];
        }];
        
        isCreated = YES;
        
        //        isCreated = [database executeStatements:statment];
    }
    @catch (NSException *exception)
    {
        NSLog(@"[%@]: DBException : %@ %@", OLC_LOG, exception.name, exception.reason);
    }
    @finally
    {
        [queue close];
    }
    
    return isCreated;
}

@end
