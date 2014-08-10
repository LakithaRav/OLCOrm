//
//  OLCMigrator.m
//  FMDB Database Tutorial
//
//  Created by Lakitha Samarasinghe on 8/7/14.
//  Copyright (c) 2014 Fidenz. All rights reserved.
//

#import "OLCMigrator.h"
#import "OCLDBHelper.h"

@implementation OLCMigrator

static OLCMigrator *_sharedInt = nil;

+(OLCMigrator *) sharedInstance:(NSString *) database for:(NSNumber *) version
{
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        
        _sharedInt = [[self alloc] init];
        _sharedInt.databasePath = database;
        _sharedInt.dbVersion    = version;
        
    });
    
    return _sharedInt;
}

+(OLCMigrator *) getSharedInstance;
{
    return _sharedInt;
}

- (void) initDb
{
    OCLDBHelper *dbH = [[OCLDBHelper alloc] init];
    [dbH getDb];
    [self makeMigrationTable];
}

- (BOOL) makeMigrationTable
{
    BOOL isCreated = NO;
    
    OCLDBHelper *dbH = [[OCLDBHelper alloc] init];
    isCreated = [dbH makeRawTable:[self createTableQuery]];
    
    return isCreated;
}

- (BOOL) migrateTable:(Class) model for:(NSNumber *) dbVersion
{
    BOOL isAddOrUpdate = NO;
    
    NSDictionary *record = [self getMigrationRecordBy:model];
    
    if([record valueForKey:@"db_version"] != NULL)
    {
        [record setValue:dbVersion forKey:@"db_version"];
        isAddOrUpdate = [self updateMigrationRecord:record];
    }
    else
    {
        isAddOrUpdate = [self makeMigrationRecord:model for:dbVersion];
    }
    
    return isAddOrUpdate;
    
}

- (BOOL) makeTable:(Class) model
{
    BOOL isCreated = NO;
    
    isCreated = [self insertOrUpdateMigration:model for:self.dbVersion];
    
    return isCreated;
}

- (BOOL) makeTable:(Class) model withTableVersion:(NSNumber *) dbVersion
{
    BOOL isCreated = NO;
    
    isCreated = [self insertOrUpdateMigration:model for:dbVersion];
    
    return isCreated;
}

#pragma private methods

- (BOOL) insertOrUpdateMigration:(Class) model for:(NSNumber *) dbVersion
{
    BOOL isCreated = NO;
    
    NSDictionary *record = [self getMigrationRecordBy:model];
    
    if([record valueForKey:@"db_version"] != NULL)
    {
//        NSNumber *ver = [record valueForKey:@"db_version"];
        
        if([[record valueForKey:@"db_version"] intValue] < [dbVersion intValue])
        {
            OCLDBHelper *dbH = [[OCLDBHelper alloc] init];
            isCreated = [dbH makeTable:model];
        }
        else
        {
            isCreated = YES;
        }
    }
    else
    {
        OCLDBHelper *dbH = [[OCLDBHelper alloc] init];
        isCreated = [dbH makeTable:model];
    }
    
    if(isCreated)
    {
        if([record valueForKey:@"db_version"] != NULL)
        {
            [record setValue:self.dbVersion forKey:@"db_version"];
            isCreated = [self updateMigrationRecord:record];
        }
        else
        {
            isCreated = [self makeMigrationRecord:model for:self.dbVersion];
        }
    }
    
    return isCreated;
}

- (NSString *) createTableQuery
{
    NSMutableString *mgQuery = [[NSMutableString alloc] init];
    
    [mgQuery appendString:@"CREATE TABLE IF NOT EXISTS "];
    [mgQuery appendString:[NSString stringWithFormat:@"%@ ", @"migration"]];
    [mgQuery appendString:@"( "];
    [mgQuery appendString:[NSString stringWithFormat:@"%@ %@ NOT NULL PRIMARY KEY AUTOINCREMENT, ", @"id", @"INTEGER"]];
    [mgQuery appendString:[NSString stringWithFormat:@"%@ %@ NOT NULL, ", @"model", @"TEXT"]];
    [mgQuery appendString:[NSString stringWithFormat:@"%@ %@ NOT NULL, ", @"db_version", @"INTEGER"]];
    [mgQuery appendString:[NSString stringWithFormat:@"%@ %@ NOT NULL ",  @"createDate", @"DATETIME"]];
    [mgQuery appendString:@");"];
    
    return mgQuery;
}

- (BOOL) makeMigrationRecord:(Class) model for:(NSNumber *) dbVersion
{
    BOOL isAdded = NO;
    
    OCLDBHelper *dbH = [[OCLDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    [database open];
    
    @try
    {
        NSString *query = [self createInsertQuery:model for:dbVersion];
        isAdded = [database executeStatements:query];
    }
    @catch (NSException *exception)
    {
        NSLog(@"DBException: %@ %@", exception.name, exception.reason);
        
    }
    @finally
    {
        [database close];
    }
    
    return isAdded;
}

- (BOOL) updateMigrationRecord:(NSDictionary *) record
{
    BOOL isUpdated = NO;
    
    OCLDBHelper *dbH = [[OCLDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    [database open];
    
    @try
    {
        NSString *query = [self createUpdateQuery:record];
        isUpdated = [database executeStatements:query];
    }
    @catch (NSException *exception)
    {
        NSLog(@"DBException: %@ %@", exception.name, exception.reason);
        
    }
    @finally
    {
        [database close];
    }
    
    return isUpdated;
}

- (NSString *) createInsertQuery:(Class) model for:(NSNumber *) dbVersion
{
    NSMutableString *mgQuery = [[NSMutableString alloc] init];
    
    [mgQuery appendString:@"INSERT INTO "];
    [mgQuery appendString:[NSString stringWithFormat:@"%@ ", @"migration"]];
    [mgQuery appendString:@"( "];
    [mgQuery appendString:[NSString stringWithFormat:@"%@, %@, %@ ", @"model", @"db_version", @"createDate"]];
    [mgQuery appendString:@") "];
    [mgQuery appendString:@"VALUES "];
    [mgQuery appendString:@"( "];
    [mgQuery appendString:[NSString stringWithFormat:@"'%@', '%@', '%@' ", model, dbVersion, [NSDate date]]];
    [mgQuery appendString:@"); "];
    
    return mgQuery;
}

- (NSString *) createUpdateQuery:(NSDictionary *) record
{
    NSMutableString *mgQuery = [[NSMutableString alloc] init];
    
    [mgQuery appendString:@"UPDATE "];
    [mgQuery appendString:[NSString stringWithFormat:@"%@ ", @"migration"]];
    [mgQuery appendString:@"SET "];
    [mgQuery appendString:[NSString stringWithFormat:@"%@='%@', ", @"model", [record valueForKey:@"model"]]];
    [mgQuery appendString:[NSString stringWithFormat:@"%@='%@', ", @"db_version", [record valueForKey:@"db_version"]]];
    [mgQuery appendString:[NSString stringWithFormat:@"%@='%@' ", @"createDate", [record valueForKey:@"createDate"]]];
    [mgQuery appendString:@"WHERE "];
    [mgQuery appendString:[NSString stringWithFormat:@"%@='%@'", @"id", [record valueForKey:@"id"]]];
    [mgQuery appendString:@"; "];
    
    return mgQuery;
}

- (NSDictionary *) getMigrationRecordBy:(Class) class
{
    NSMutableDictionary *record = [[NSMutableDictionary alloc] init];

    OCLDBHelper *dbH = [[OCLDBHelper alloc] init];
    
    FMDatabaseQueue * queue = [dbH getQueueDb];
    
    @try
    {
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE model='%@'", @"migration", class];
        
        [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            
            FMResultSet *results = [db executeQuery:query];
            
            while([results next])
            {
                [record setValue:[results stringForColumn:@"id"] forKey:@"id"];
                [record setValue:[results stringForColumn:@"model"] forKey:@"model"];
                [record setValue:[NSNumber numberWithInt:[results intForColumn:@"db_version"]] forKey:@"db_version"];
                [record setValue:[results stringForColumn:@"createDate"] forKey:@"createDate"];
                
            }
            
        }];
        //        isCreated = [database executeStatements:statment];
    }
    @catch (NSException *exception)
    {
        NSLog(@"DBException: %@ %@", exception.name, exception.reason);
    }
    @finally
    {
        [queue close];
    }
    
    return record;
}

@end
