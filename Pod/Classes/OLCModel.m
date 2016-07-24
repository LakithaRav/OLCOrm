//
//  OCLModel.m
//  FMDB Database Tutorial
//
//  Created by Lakitha Samarasinghe on 8/6/14.
//  Copyright (c) 2014 Fidenz. All rights reserved.
//

#import "OLCModel.h"
#import "OLCDBHelper.h"
#import "OLCObjectParser.h"
#import "NSObject+KJSerializer.h"
#import "OLCTableHandler.h"
#import "OLCOrm.h"

#define OLC_LOG @"OLCLOG"

@implementation OLCModel
{
    OLCTableHandler *queryH;
}

//removed to support Swift 2.0
//@synthesize Id;

- (id) init
{
    if(self = [super init])
    {
        queryH = [[OLCTableHandler alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
//    [encoder encodeObject:self.Id forKey:@"Id"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
//        self.Id = [decoder decodeObjectForKey:@"Id"];
    }
    return self;
}


- (BOOL) save
{
    BOOL isAdded = NO;
    
    OLCDBHelper *dbH = [[OLCDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    [database open];
    
    NSDate *_start = [NSDate date];
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
        
        if([self.class debug])
        {
            double timeelapsed = [_start timeIntervalSinceNow] * -1000.0;
            NSLog(@"[%@]: %@ - save : %fms", OLC_LOG, [self class], timeelapsed);
        }
    }
    
    return isAdded;
}


- (NSNumber*) saveAndGetId
{
    NSNumber *recordId = @-1;
    
    OLCDBHelper *dbH = [[OLCDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    [database open];
    
    NSDate *_start = [NSDate date];
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
        
        if([self.class debug])
        {
            double timeelapsed = [_start timeIntervalSinceNow] * -1000.0;
            NSLog(@"[%@]: %@ - saveAndGetId : %fms", OLC_LOG, [self class], timeelapsed);
        }
    }
    
    return recordId;
}


- (BOOL) update
{
    BOOL isUpdated = NO;
    
    OLCDBHelper *dbH = [[OLCDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    [database open];
    
    NSDate *_start = [NSDate date];
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
        
        if([self.class debug])
        {
            double timeelapsed = [_start timeIntervalSinceNow] * -1000.0;
            NSLog(@"[%@]: %@ - update : %fms", OLC_LOG, [self class], timeelapsed);
        }
    }
    
    return isUpdated;
}


- (BOOL) delete
{
    BOOL isDeleted = NO;
    
    OLCDBHelper *dbH = [[OLCDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    [database open];
    
    NSDate *_start = [NSDate date];
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
        
        if([self.class debug])
        {
            double timeelapsed = [_start timeIntervalSinceNow] * -1000.0;
            NSLog(@"[%@]: %@ - delete : %fms", OLC_LOG, [self class], timeelapsed);
        }
    }
    
    return isDeleted;
}

#pragma mark - relationships


- (NSObject *) hasOne:(Class) model foreignKeyCol:(NSString *) fkey /*primaryKeyCol:(NSString *) pkey*/
{
    NSObject * object = nil;
    
    OLCDBHelper *dbH = [[OLCDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    OLCTableHandler *qH = nil;
    
    [database open];
    
    NSDate *_start = [NSDate date];
    @try
    {
        qH = [[OLCTableHandler alloc] init];
        
        NSString * primaryKey = [model performSelector:@selector(primaryKey)];
        
        NSString *query = [qH createOneToOneRelationQuery:self foreignClass:model foreignKey:fkey primaryKey:primaryKey];
        FMResultSet *results = [database executeQuery:query];
        
        {
            while([results next])
            {
                object = [OLCModel makeObject:results forClass:model];
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
        
        if([self.class debug])
        {
            double timeelapsed = [_start timeIntervalSinceNow] * -1000.0;
            NSLog(@"[%@]: %@ - hasOne : %fms", OLC_LOG, [self class], timeelapsed);
        }
    }
    
    return object;
}


- (NSArray *) hasMany:(Class) model foreignKeyCol:(NSString *) fkey /*primaryKeyCol:(NSString *) pkey*/
{
    NSMutableArray *objArry = [[NSMutableArray alloc] init];
    
    OLCDBHelper *dbH = [[OLCDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    OLCTableHandler *qH = nil;
    
    [database open];
    
    NSDate *_start = [NSDate date];
    @try
    {
        qH = [[OLCTableHandler alloc] init];
        
        NSString * primaryKey = [model performSelector:@selector(primaryKey)];
        
        NSString *query = [qH createOneToManyRelationQuery:self foreignClass:model foreignKey:fkey primaryKey:primaryKey];
        FMResultSet *results = [database executeQuery:query];
        
        {
            while([results next])
            {
                NSObject * object = [OLCModel makeObject:results forClass:model];
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
        
        if([self.class debug])
        {
            double timeelapsed = [_start timeIntervalSinceNow] * -1000.0;
            NSLog(@"[%@]: %@ - hasMany : %fms", OLC_LOG, [self class], timeelapsed);
        }
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
    
    OLCDBHelper *dbH = [[OLCDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    OLCTableHandler *qH = nil;
    
    [database open];
    
    NSDate *_start = [NSDate date];
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
        
        if([self debug])
        {
            double timeelapsed = [_start timeIntervalSinceNow] * -1000.0;
            NSLog(@"[%@]: %@ - all : %fms", OLC_LOG, [self class], timeelapsed);
        }
    }
    
    return objArry;
}


+ (NSObject *) find:(NSNumber *) Id
{
    NSObject * object = nil;
    
    OLCDBHelper *dbH = [[OLCDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    OLCTableHandler *qH = nil;
    
    [database open];
    
    NSDate *_start = [NSDate date];
    @try
    {
        qH = [[OLCTableHandler alloc] init];
        
        NSString *query = [qH createFindByIdQuery:[self class] forId:Id];
        FMResultSet *results = [database executeQuery:query];
        
        while([results next])
        {
            object = [OLCModel makeObject:results forClass:[self class]];
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
        
        if([self debug])
        {
            double timeelapsed = [_start timeIntervalSinceNow] * -1000.0;
            NSLog(@"[%@]: %@ - find : %fms", OLC_LOG, [self class], timeelapsed);
        }
    }
    
    return object;
}


+ (NSArray *) whereColumn:(NSString *) column byOperator:(NSString *) opt forValue:(NSString *) value accending:(BOOL) sort
{
    NSMutableArray *objArry = [[NSMutableArray alloc] init];
    
    OLCDBHelper *dbH = [[OLCDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    OLCTableHandler *qH = nil;
    
    [database open];
    
    NSDate *_start = [NSDate date];
    @try
    {
        qH = [[OLCTableHandler alloc] init];
        
        NSDictionary *queryData = [qH createFindWhere:[self class] forVal:value byOperator:opt inColumn:column accending:sort];
        FMResultSet *results = [database executeQuery:[queryData valueForKey:OLC_D_QUERY] withParameterDictionary:[queryData valueForKey:OLC_D_DATA]];
                
        while([results next])
        {
            NSObject * object = [OLCModel makeObject:results forClass:[self class]];
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
        
        if([self debug])
        {
            double timeelapsed = [_start timeIntervalSinceNow] * -1000.0;
            NSLog(@"[%@]: %@ - whereColumn : %fms", OLC_LOG, [self class], timeelapsed);
        }
    }
    
    return  objArry;
}


+ (NSArray *) where:(NSString *) clause sortBy:(NSString *) column accending:(BOOL) sort NS_REFINED_FOR_SWIFT
{
    NSMutableArray *objArry = [[NSMutableArray alloc] init];
    
    OLCDBHelper *dbH = [[OLCDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    OLCTableHandler *qH = nil;
    
    [database open];
    
    NSDate *_start = [NSDate date];
    @try
    {
        qH = [[OLCTableHandler alloc] init];
        
        NSString *query = [qH createWhereQuery:[self class] withFilter:clause andSort:column accending:sort];
        FMResultSet *results = [database executeQuery:query];
        
        while([results next])
        {
            NSObject * object = [OLCModel makeObject:results forClass:[self class]];
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
        
        if([self debug])
        {
            double timeelapsed = [_start timeIntervalSinceNow] * -1000.0;
            NSLog(@"[%@]: %@ - where : %fms", OLC_LOG, [self class], timeelapsed);
        }
    }
    
    return  objArry;
}


+ (NSArray *) query:(NSString *) query
{
    NSMutableArray *objArry = [[NSMutableArray alloc] init];
    
    OLCDBHelper *dbH = [[OLCDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    [database open];
    
    NSDate *_start = [NSDate date];
    @try
    {
        FMResultSet *results = [database executeQuery:query];
        
        while([results next])
        {
            NSObject * object = [OLCModel makeObject:results forClass:[self class]];
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
        
        if([self debug])
        {
            double timeelapsed = [_start timeIntervalSinceNow] * -1000.0;
            NSLog(@"[%@]: %@ - query : %fms", OLC_LOG, [self class], timeelapsed);
        }
    }
    
    return  objArry;
}


+ (BOOL) truncate
{
    BOOL isDeleted = NO;
    
    OLCDBHelper *dbH = [[OLCDBHelper alloc] init];
    
    FMDatabase * database = [dbH getDb];
    
    OLCTableHandler *qH = nil;
    
    [database open];
    
    NSDate *_start = [NSDate date];
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
        
        if([self debug])
        {
            double timeelapsed = [_start timeIntervalSinceNow] * -1000.0;
            NSLog(@"[%@]: %@ - truncate : %fms", OLC_LOG, [self class], timeelapsed);
        }
    }
    
    return isDeleted;
}

//- (NSArray *) belongToMany:(Class) model inMapping:(Class) mapmodel foreignKeyCol:(NSString *) fkey primaryKeyCol:(NSString *) pkey
//{
//    NSArray * records = [[NSArray alloc] init];
//    
//    return records;
//}

+ (void) printTable
{
    NSArray *objects = [self all];
    
    OLCObjectParser *parse = [[OLCObjectParser alloc] init];
    NSArray *columns = [parse scanModel:[self class]];
    
    NSMutableString *log = [[NSMutableString alloc] init];
    
    [log appendString:@"\n"];
    
    for(NSDictionary *header in columns)
    {
        [log appendString:[NSString stringWithFormat:@"%@\t ", [header valueForKey:@"column"]]];
    }
    
    [log appendString:@"\n"];
    
    for(NSDictionary *record in objects)
    {
        for(NSDictionary *header in columns)
        {
            if(
               [[header valueForKey:@"type"] isEqualToString:@"@\"NSData\""] ||
               [[header valueForKey:@"type"] isEqualToString:@"@\"NSSet\""] ||
               [[header valueForKey:@"type"] isEqualToString:@"@\"UIImage\""]
               )
                [log appendString:[NSString stringWithFormat:@"%@\t ", @"data"]];
            else
            {
                NSString *data = [NSString stringWithFormat:@"%@", [record valueForKey:[header valueForKey:@"column"]]];
                data = [data stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                [log appendString:[NSString stringWithFormat:@"%@\t ", data]];
            }
        }
        
        [log appendString:@"\n"];
    }
    
    [log appendString:@"\n"];
    
    NSLog(@"%@", log);
}

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
    
    OLCObjectParser *parse = [[OLCObjectParser alloc] init];
    NSArray *columns = [parse scanModel:model];
    
    object = [model new];
    NSDictionary * dictionary = [object getObjDictionary];
    
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
                else if([colType isEqualToString:@"@\"NSDictionary\""])
                {
                    NSData *data = [result dataForColumn:colName];
                    NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    [dictionary setValue:dic forKey:colName];
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
    
    [object setObjDictionary:dictionary];
    
    return object;
}

@end
