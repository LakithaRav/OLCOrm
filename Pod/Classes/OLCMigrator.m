//
//  OLCMigrator.m
//  FMDB Database Tutorial
//
//  Created by Lakitha Samarasinghe on 8/7/14.
//  Copyright (c) 2014 Fidenz. All rights reserved.
//

#import "OLCMigrator.h"
#import "OLCDBHelper.h"
#import "OLCModel.m"

#define OLC_LOG @"OLCLOG"

@implementation OLCMigrator

/*!
 * @brief Singleton object of OLCMigrator class
 */
static OLCMigrator *_sharedInt = nil;


+(OLCMigrator *) sharedInstance:(NSString *) database version:(NSNumber *) version enableDebug:(BOOL) debug
{
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
    
        _sharedInt = [[self alloc] init];
        _sharedInt.debugable    = debug;
        _sharedInt.databasePath = database;
        _sharedInt.dbVersion    = version;
        
    });
    
//    if(debug)
//        NSLog(@"%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory  inDomains:NSUserDomainMask] lastObject]);
    
    return _sharedInt;
}


+(OLCMigrator *) getSharedInstance;
{
    return _sharedInt;
}


- (void) initDb
{
    OLCDBHelper *dbH = [[OLCDBHelper alloc] init];
    FMDatabase *database = [dbH getDb];
    
    if(self.debugable)
        NSLog(@"Path %@", database.databasePath);
    
    [self makeMigrationTable];
    [self backupDb:database.databasePath];
    [self insertOrUpdateDatabseVersion];
}

/*!
 @brief         Create the migration table
 @discussion    Calling this will create migration table
 */
- (BOOL) makeMigrationTable
{
    BOOL isCreated = NO;
    
    OLCDBHelper *dbH = [[OLCDBHelper alloc] init];
    isCreated = [dbH makeRawTable:[self createTableQuery]];
    
    return isCreated;
}

- (BOOL) makeTable:(Class) model
{
    BOOL isCreated = NO;
    
    isCreated = [self insertOrUpdateMigration:model for:self.dbVersion withMigration:YES];
    
    return isCreated;
}

- (BOOL) makeTable:(Class) model withMigration:(BOOL) migrate
{
    BOOL isCreated = NO;
    
    isCreated = [self insertOrUpdateMigration:model for:self.dbVersion withMigration:migrate];
    
    return isCreated;
}

- (BOOL) makeTable:(Class) model withTableVersion:(NSNumber *) version withMigration:(BOOL) migrate
{
    BOOL isCreated = NO;
    
    isCreated = [self insertOrUpdateMigration:model for:version withMigration:migrate];
    
    return isCreated;
}

#pragma private methods

/*!
 @brief         Insert or Update migration record
 @discussion    Method to insert or update migration record based on database or table version
 @remark        Private method
 @param         model Class of a specific model
 @param         version table verion number
 @return        <b>BOOL</b> YES if created, NO if failed
 */
- (BOOL) insertOrUpdateMigration:(Class) model for:(NSNumber *) version withMigration:(BOOL) migrate
{
    BOOL isCreated = NO;
    
    NSDictionary *record = [self getMigrationRecordBy:model];
    
    if([record valueForKey:@"db_version"] != NULL)
    {
        if([[record valueForKey:@"db_version"] intValue] < [version intValue])
        {
            OLCDBHelper *dbH = [[OLCDBHelper alloc] init];
            isCreated = [dbH makeTable:model];
            
            //migrate record from old table
            if(migrate)
                [self migrateRecords:model];
        }
        else
        {
            isCreated = YES;
        }
    }
    else
    {
        OLCDBHelper *dbH = [[OLCDBHelper alloc] init];
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

- (BOOL) insertOrUpdateDatabseVersion
{
    BOOL isCreated = NO;
    
    NSDictionary *record = [self getMigrationRecordBy:[self class]];
    if([record valueForKey:@"db_version"] != NULL)
    {
        [record setValue:self.dbVersion forKey:@"db_version"];
        isCreated = [self updateMigrationRecord:record];
    }
    else
    {
        isCreated = [self makeMigrationRecord:[self class] for:self.dbVersion];
    }
    
    return isCreated;
}

- (BOOL) backupDb: (NSString *) databasePath
{
//    BOOL isBackedUp = NO;
    
    NSDictionary *record = [self getMigrationRecordBy:[self class]];
    if([record valueForKey:@"db_version"] != NULL)
    {
        if([[record valueForKey:@"db_version"] intValue] < [self.dbVersion intValue])
        {
            //backup the current database
            if ([[NSFileManager defaultManager] isReadableFileAtPath:databasePath] )
            {
                NSString *tmpPath = [NSString stringWithFormat:@"%@.old", databasePath];
                
                NSError *error;
                if ([[NSFileManager defaultManager] isDeletableFileAtPath:tmpPath])
                {
                    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:&error];
                    if (!success) {
                        NSLog(@"Error removing file at path: %@", error.localizedDescription);
                    }
                }
                
                [[NSFileManager defaultManager] copyItemAtPath:databasePath toPath:tmpPath error:nil];
            }
        }
    }
    
    return YES;
}

/*!
 @brief         Crates the migration table query
 @discussion    This method will create and reruns the migration table's create statement to the caller
 @remark        Private method
 @return        <b>NSString</b> migration table create SQL
 */
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

/*!
 @brief         Create the migration table on database
 @discussion    This method create the table migration table in the database
 @remark        Private method
 @param         model Class of a specific model
 @param         version table verion number
 @return        <b>BOOL</b> YES if created, NO if failed
 */
- (BOOL) makeMigrationRecord:(Class) model for:(NSNumber *) version
{
    BOOL isAdded = NO;
    
    OLCDBHelper *dbH = [[OLCDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    [database open];
    
    @try
    {
        NSString *query = [self createInsertQuery:model for:version];
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

/*!
 @brief         Update the migration table on database
 @discussion    This method update the table migration table records
 @remark        Private method
 @param         record Sql query string to update a specific record
 @return        <b>BOOL</b> YES if created, NO if failed
 */
- (BOOL) updateMigrationRecord:(NSDictionary *) record
{
    BOOL isUpdated = NO;
    
    OLCDBHelper *dbH = [[OLCDBHelper alloc] init];
    
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

/*!
 @brief         Create the Insert SQL query
 @discussion    Method used to create Insert SQL Insert statment on a model
 @remark        Private method
 @param         model Class of a specific model
 @param         version table verion number
 @return        <b>NSString</b> Insert SQL query
 */
- (NSString *) createInsertQuery:(Class) model for:(NSNumber *) version
{
    NSMutableString *mgQuery = [[NSMutableString alloc] init];
    
    [mgQuery appendString:@"INSERT INTO "];
    [mgQuery appendString:[NSString stringWithFormat:@"%@ ", @"migration"]];
    [mgQuery appendString:@"( "];
    [mgQuery appendString:[NSString stringWithFormat:@"%@, %@, %@ ", @"model", @"db_version", @"createDate"]];
    [mgQuery appendString:@") "];
    [mgQuery appendString:@"VALUES "];
    [mgQuery appendString:@"( "];
    [mgQuery appendString:[NSString stringWithFormat:@"'%@', '%@', '%@' ", model, version, [NSDate date]]];
    [mgQuery appendString:@"); "];
    
    return mgQuery;
}

/*!
 @brief         Create the Update SQL query
 @discussion    Method used to create Update SQL Insert statment on a model
 @remark        Private method
 @param         model Class of a specific model
 @param         version table verion number
 @return        <b>NSString</b> Update SQL query
 */
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

/*!
 @brief         Retrieve migration record
 @discussion    Method used to retrieve a specific migration record by class name of an model
 @remark        Private method
 @param         model Class of a specific model
 @return        <b>NSDictionary</b> record values
 */
- (NSDictionary *) getMigrationRecordBy:(Class) class
{
    NSMutableDictionary *record = [[NSMutableDictionary alloc] init];

    OLCDBHelper *dbH = [[OLCDBHelper alloc] init];
    
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

/*!
 @brief         Restore data from previous database
 @discussion    Method used to migrate data from old database to new without any data loss.
 @remark        Private method
 @param         model Class of a specific model
 @return        <b>NSDictionary</b> record values
 */
- (void) migrateRecords:(Class) model
{
    OLCDBHelper *dbH = [[OLCDBHelper alloc] init];
    FMDatabase *database = [dbH getDb];
    FMDatabaseQueue *newQueue = [dbH getQueueDb];
    OLCTableHandler * queryH = [[OLCTableHandler alloc] init];
    
    NSString *previousPath = [NSString stringWithFormat:@"%@.old", database.databasePath];
    
    FMDatabaseQueue *oldQueue = [FMDatabaseQueue databaseQueueWithPath:previousPath];
    
    NSDate *_start = [NSDate date];
    @try
    {
        [database open];
        
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@", model];
        
        NSMutableArray *records = [[NSMutableArray alloc] init];
        
        [oldQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            
            FMResultSet *results = [db executeQuery:query];
            
            while([results next])
            {
                NSObject * object = [OLCModel makeObject:results forClass:model];
                NSDictionary *queryData = [queryH createInsertQuery:object];
                [records addObject:queryData];
            }
        }];
        
        [newQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            
            for(NSDictionary *dataobj in records)
            {
                [db executeUpdate:[dataobj valueForKey:OLC_D_QUERY] withParameterDictionary:[dataobj valueForKey:OLC_D_DATA]];
            }
        }];
    }
    @catch (NSException *exception)
    {
        NSLog(@"DBException: %@ %@", exception.name, exception.reason);
    }
    @finally
    {
        [oldQueue close];
        [newQueue close];
        [database close];
        
        double timeelapsed = [_start timeIntervalSinceNow] * -1000.0;
        NSLog(@"[%@]: %@ - Migration time : %fms", OLC_LOG, model, timeelapsed);
    }
}

@end
