//
//  OCLModel.m
//  FMDB Database Tutorial
//
//  Created by Lakitha Samarasinghe on 8/6/14.
//  Copyright (c) 2014 Fidenz. All rights reserved.
//

#import "OCLModel.h"
#import "OCLDBHelper.h"
#import "OCLObjectParser.h"
#import "OCLDBHelper.h"

#define OLC_LOG @"OLCLOG"

@implementation OCLModel

@synthesize Id;

- (id) init
{
    if(self = [super init])
    {
        queryH = [[OLCTableHandler alloc] init];
    }
    return self;
}


- (BOOL) save
{
    BOOL isAdded = NO;
    
    OCLDBHelper *dbH = [[OCLDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    [database open];
    
    @try
    {
        NSDictionary *queryData = [queryH createInsertQuery:self];
        isAdded = [database executeUpdate:[queryData valueForKey:OLC_D_QUERY] withParameterDictionary:[queryData valueForKey:OLC_D_DATA]];
    }
    @catch (NSException *exception)
    {
        NSLog(@"[%@]: DBException : %@ %@", OLC_LOG, exception.name, exception.reason);
        
    }
    @finally
    {
        if(isAdded)
            [self notifyChange:Insert];
        
        [database close];
    }
    
    return isAdded;
}


- (NSNumber*) saveAndGetId
{
    NSNumber *recordId = @-1;
    
    OCLDBHelper *dbH = [[OCLDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    [database open];
    
    @try
    {
        NSDictionary *queryData  = [queryH createInsertQuery:self];
        BOOL isAdded = [database executeUpdate:[queryData valueForKey:OLC_D_QUERY] withParameterDictionary:[queryData valueForKey:OLC_D_DATA]];
        
        if(isAdded)
        {
            NSString *query = [queryH createLastInsertRecordIdQuery:[self class]];
            FMResultSet *results = [database executeQuery:query];
            
            while([results next])
            {
                int i = [results intForColumn:@"last_insert_rowid"];
                recordId = [NSNumber numberWithInt:i];
            }
        }
        else
        {
            recordId = [NSNumber numberWithInt:-1];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"[%@]: DBException : %@ %@", OLC_LOG, exception.name, exception.reason);
        
    }
    @finally
    {
        if([recordId intValue] > -1)
            [self notifyChange:Insert];
        
        [database close];
    }
    
    return recordId;
}


- (BOOL) update
{
    BOOL isUpdated = NO;
    
    OCLDBHelper *dbH = [[OCLDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    [database open];
    
    @try
    {
        NSDictionary *queryData = [queryH createUpdateQuery:self];
        isUpdated = [database executeUpdate:[queryData valueForKey:OLC_D_QUERY] withParameterDictionary:[queryData valueForKey:OLC_D_DATA]];
    }
    @catch (NSException *exception)
    {
        NSLog(@"[%@]: DBException : %@ %@", OLC_LOG, exception.name, exception.reason);
        
    }
    @finally
    {
        if(isUpdated)
            [self notifyChange:Update];
        
        [database close];
    }
    
    return isUpdated;
}


- (BOOL) delete
{
    BOOL isDeleted = NO;
    
    OCLDBHelper *dbH = [[OCLDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    [database open];
    
    @try
    {
        NSString *query = [queryH createDeleteQuery:self];
        isDeleted = [database executeUpdate:query];
    }
    @catch (NSException *exception)
    {
        NSLog(@"[%@]: DBException : %@ %@", OLC_LOG, exception.name, exception.reason);
        
    }
    @finally
    {
        if(isDeleted)
            [self notifyChange:Delete];
        
        [database close];
    }
    
    return isDeleted;
}

#pragma mark - relationships


- (NSObject *) hasOne:(Class) model foreignKeyCol:(NSString *) fkey /*primaryKeyCol:(NSString *) pkey*/
{
    NSObject * object = nil;
    
    OCLDBHelper *dbH = [[OCLDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    OLCTableHandler *qH = nil;
    
    [database open];
    
    @try
    {
        qH = [[OLCTableHandler alloc] init];
        
        NSString * primaryKey = [model performSelector:@selector(primaryKey)];
        
        NSString *query = [qH createOneToOneRelationQuery:self foreignClass:model foreignKey:fkey primaryKey:primaryKey];
        FMResultSet *results = [database executeQuery:query];
        
        {
            while([results next])
            {
                object = [OCLModel makeObject:results forClass:model];
            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"[%@]: DBException : %@ %@", OLC_LOG, exception.name, exception.reason);
        
    }
    @finally
    {
        qH = nil;
        [database close];
    }
    
    return object;
}


- (NSArray *) hasMany:(Class) model foreignKeyCol:(NSString *) fkey /*primaryKeyCol:(NSString *) pkey*/
{
    NSMutableArray *objArry = [[NSMutableArray alloc] init];
    
    OCLDBHelper *dbH = [[OCLDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    OLCTableHandler *qH = nil;
    
    [database open];
    
    @try
    {
        qH = [[OLCTableHandler alloc] init];
        
        NSString * primaryKey = [model performSelector:@selector(primaryKey)];
        
        NSString *query = [qH createOneToManyRelationQuery:self foreignClass:model foreignKey:fkey primaryKey:primaryKey];
        FMResultSet *results = [database executeQuery:query];
        
        {
            while([results next])
            {
                NSObject * object = [OCLModel makeObject:results forClass:model];
                [objArry addObject:object];
            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"[%@]: DBException : %@ %@", OLC_LOG, exception.name, exception.reason);
        
    }
    @finally
    {
        qH = nil;
        [database close];
    }
    
    return  objArry;
}


- (NSObject *) belongTo:(Class) model foreignKeyCol:(NSString *) pkey
{
    return [self hasOne:model foreignKeyCol:pkey];
}

#pragma mark - static


+ (NSString*) primaryKey
{
    return @"Id";
}


+ (BOOL) primaryKeyAutoIncrement
{
    return YES;
}


+ (NSArray *)ignoredProperties
{
    return @[];
}


+ (BOOL) debug
{
    return NO;
}


+ (NSArray*) all
{
    NSMutableArray *objArry = [[NSMutableArray alloc] init];
    
    OCLDBHelper *dbH = [[OCLDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    OLCTableHandler *qH = nil;
    
    [database open];
    
    @try
    {
        qH = [[OLCTableHandler alloc] init];
        
        NSString *query = [qH createFindAllQuery:[self class]];
        FMResultSet *results = [database executeQuery:query];
        
        while([results next])
        {
            NSObject * object = [self makeObject:results forClass:[self class]];
            [objArry addObject:object];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"[%@]: DBException : %@ %@", OLC_LOG, exception.name, exception.reason);
        
    }
    @finally
    {
        qH = nil;
        [database close];
    }
    
    return objArry;
}


+ (NSObject *) find:(NSNumber *) Id
{
    NSObject * object = nil;
    
    OCLDBHelper *dbH = [[OCLDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    OLCTableHandler *qH = nil;
    
    [database open];
    
    @try
    {
        qH = [[OLCTableHandler alloc] init];
        
        NSString *query = [qH createFindByIdQuery:[self class] forId:Id];
        FMResultSet *results = [database executeQuery:query];
        
        while([results next])
        {
            object = [OCLModel makeObject:results forClass:[self class]];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"[%@]: DBException : %@ %@", OLC_LOG, exception.name, exception.reason);
        
    }
    @finally
    {
        qH = nil;
        [database close];
    }
    
    return object;
}


+ (NSArray *) whereColumn:(NSString *) column byOperator:(NSString *) opt forValue:(NSString *) value accending:(BOOL) sort
{
    NSMutableArray *objArry = [[NSMutableArray alloc] init];
    
    OCLDBHelper *dbH = [[OCLDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    OLCTableHandler *qH = nil;
    
    [database open];
    
    @try
    {
        qH = [[OLCTableHandler alloc] init];
        
        NSDictionary *queryData = [qH createFindWhere:[self class] forVal:value byOperator:opt inColumn:column accending:sort];
        FMResultSet *results = [database executeQuery:[queryData valueForKey:OLC_D_QUERY] withParameterDictionary:[queryData valueForKey:OLC_D_DATA]];
                
        while([results next])
        {
            NSObject * object = [OCLModel makeObject:results forClass:[self class]];
            [objArry addObject:object];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"[%@]: DBException : %@ %@", OLC_LOG, exception.name, exception.reason);
        
    }
    @finally
    {
        qH = nil;
        [database close];
    }
    
    return  objArry;
}


+ (NSArray *) where:(NSString *) clause sortBy:(NSString *) column accending:(BOOL) sort
{
    NSMutableArray *objArry = [[NSMutableArray alloc] init];
    
    OCLDBHelper *dbH = [[OCLDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    OLCTableHandler *qH = nil;
    
    [database open];
    
    @try
    {
        qH = [[OLCTableHandler alloc] init];
        
        NSString *query = [qH createWhereQuery:[self class] withFilter:clause andSort:column accending:sort];
        FMResultSet *results = [database executeQuery:query];
        
        while([results next])
        {
            NSObject * object = [OCLModel makeObject:results forClass:[self class]];
            [objArry addObject:object];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"[%@]: DBException : %@ %@", OLC_LOG, exception.name, exception.reason);
        
    }
    @finally
    {
        qH = nil;
        [database close];
    }
    
    return  objArry;
}


+ (NSArray *) query:(NSString *) query
{
    NSMutableArray *objArry = [[NSMutableArray alloc] init];
    
    OCLDBHelper *dbH = [[OCLDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    [database open];
    
    @try
    {
        FMResultSet *results = [database executeQuery:query];
        
        while([results next])
        {
            NSObject * object = [OCLModel makeObject:results forClass:[self class]];
            [objArry addObject:object];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"[%@]: DBException : %@ %@", OLC_LOG, exception.name, exception.reason);
        
    }
    @finally
    {
        [database close];
    }
    
    return  objArry;
}


+ (BOOL) truncateTable
{
    BOOL isDeleted = NO;
    
    OCLDBHelper *dbH = [[OCLDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    OLCTableHandler *qH = nil;
    
    [database open];
    
    @try
    {
        qH = [[OLCTableHandler alloc] init];
        
        NSString *query = [qH createTruncateTableQuery:[self class]];
        isDeleted = [database executeStatements:query];
    }
    @catch (NSException *exception)
    {
        NSLog(@"[%@]: DBException : %@ %@", OLC_LOG, exception.name, exception.reason);
        
    }
    @finally
    {
        [database close];
    }
    
    return isDeleted;
}

//- (NSArray *) belongToMany:(Class) model inMapping:(Class) mapmodel foreignKeyCol:(NSString *) fkey primaryKeyCol:(NSString *) pkey
//{
//    NSArray * records = [[NSArray alloc] init];
//    
//    return records;
//}

#pragma mark - notifications

+ (void) notifyOnChanges:(id) context withMethod:(SEL) method
{
    [[NSNotificationCenter defaultCenter] addObserver:context selector:method name:NSStringFromClass([self class]) object:nil];
}

/*!
 @brief         Trigger local notification
 @discussion    Private method use to fire local notification based on the CRUD operations happen on the database table
 @param         type <b>Operations</b> enum
 */
- (void) notifyChange:(Operations) type
{
    
    OLCOrmNotification *notif = [[OLCOrmNotification alloc] initWithObject:self];
    notif.selection = 1;
    notif.type = type;
    [[NSNotificationCenter defaultCenter] postNotificationName:NSStringFromClass([self class]) object:notif];
}


+ (void) removeNotifyer:(id) context
{
    [[NSNotificationCenter defaultCenter] removeObserver:context name:NSStringFromClass([self class]) object:nil];
}

#pragma mark - private

+ (NSObject *) makeObject:(FMResultSet *) result forClass:(Class) model
{
    NSObject * object = nil;
    
    OCLObjectParser *parse = [[OCLObjectParser alloc] init];
    NSArray *columns = [parse scanModel:model];
    
    object = [model new];
    NSDictionary * dictionary = [object getDictionary];
    
    NSArray  *ignoredList   = [model performSelector:@selector(ignoredProperties)];
    
    for(int i=0; i < [columns count]; i++)
    {
        NSDictionary *keyval    = (NSDictionary *) columns[i];
        NSString *colName       = [keyval valueForKey:@"column"];
        NSString *colType       = [keyval valueForKey:@"type"];
        
        if([ignoredList containsObject:colName]) continue;
        
        const char *type = [colType UTF8String];
        
        switch (type[0])
        {
            case 'i':
                [dictionary setValue:[NSNumber numberWithInt:[result intForColumn:colName]] forKey:colName];
                //            NSLog(@"int");
                break;
            case 's':
                [dictionary setValue:[NSNumber numberWithShort:[result intForColumn:colName]] forKey:colName];
                //            NSLog(@"short");
                break;
            case 'l':
                [dictionary setValue:[NSNumber numberWithLong:[result longForColumn:colName]] forKey:colName];
                //            NSLog(@"long");
                break;
            case 'q':
                [dictionary setValue:[NSNumber numberWithLongLong:[result longLongIntForColumn:colName]] forKey:colName];
                //            NSLog(@"long long");
                break;
            case 'C':
                [dictionary setValue:[result stringForColumn:colName] forKey:colName];
                //            NSLog(@"char");
                break;
            case 'c':
                [dictionary setValue:[result stringForColumn:colName] forKey:colName];
                //            NSLog(@"char");
                break;
            case 'I':
                [dictionary setValue:[NSNumber numberWithInt:[result intForColumn:colName]] forKey:colName];
                //            NSLog(@"int");
                break;
            case 'S':
                [dictionary setValue:[result stringForColumn:colName] forKey:colName];
                //            NSLog(@"short");
                break;
            case 'L':
                [dictionary setValue:[NSNumber numberWithLong:[result longForColumn:colName]] forKey:colName];
                //            NSLog(@"long");
                break;
            case 'Q':
                [dictionary setValue:[NSNumber numberWithLong:[result longForColumn:colName]] forKey:colName];
                //            NSLog(@"long");
                break;
            case 'f':
                [dictionary setValue:[NSNumber numberWithFloat:[result doubleForColumn:colName]] forKey:colName];
                //            NSLog(@"float");
                break;
            case 'd':
                [dictionary setValue:[NSNumber numberWithDouble:[result doubleForColumn:colName]] forKey:colName];
                //            NSLog(@"double");
                break;
            case 'B':
                [dictionary setValue:[NSNumber numberWithInt:[result intForColumn:colName]] forKey:colName];
                //            NSLog(@"bool");
                break;
            default:
                
                if([colType isEqualToString:@"@\"NSNumber\""])
                {
                    [dictionary setValue:[result objectForColumnName:colName] forKey:colName];
                }
                else if([colType isEqualToString:@"@\"NSString\""])
                {
                    [dictionary setValue:[result stringForColumn:colName] forKey:colName];
                }
                else if([colType isEqualToString:@"@\"NSDate\""])
                {
                    NSDate *date = [result dateForColumn:colName];
                    [dictionary setValue:date forKey:colName];
                }
                else if([colType isEqualToString:@"@\"NSData\""])
                {
                    [dictionary setValue:[result dataForColumn:colName] forKey:colName];
                }
                else if([colType isEqualToString:@"@\"NSSet\""])
                {
                    NSData *data = [result dataForColumn:colName];
                    NSSet *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    [dictionary setValue:array forKey:colName];
                }
                else if([colType isEqualToString:@"@\"NSArray\""])
                {
                    NSData *data = [result dataForColumn:colName];
                    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    
                    [dictionary setValue:array forKey:colName];
                }
                else if([colType isEqualToString:@"@\"NSURL\""])
                {
                    [dictionary setValue:[NSURL URLWithString:[result stringForColumn:colName]] forKey:colName];
                }
                else if([colType isEqualToString:@"@\"NSInteger\""])
                {
                    [dictionary setValue:[NSNumber numberWithInt:[result intForColumn:colName]] forKey:colName];
                }
                else if([colType isEqualToString:@"@\"UIImage\""])
                {
                    NSData *data = [result dataForColumn:colName];
                    [dictionary setValue:[UIImage imageWithData:data] forKey:colName];
                }
                else
                {
                    [dictionary setValue:[result dataForColumn:colName] forKey:colName];
                }
                
                break;
        }
        
    }
    
    [object setDictionary:dictionary];
    
    return object;
}

@end
