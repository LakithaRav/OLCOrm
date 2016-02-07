//
//  OLCTableHandler.m
//  FMDB Database Tutorial
//
//  Created by Lakitha Samarasinghe on 8/6/14.
//  Copyright (c) 2014 Fidenz. All rights reserved.
//

#import "OLCTableHandler.h"
#import "OCLObjectParser.h"
#import "OLCOrm.h"
#import "OCLModel.h"

#define OLC_LOG @"OLCLOG"

@implementation OLCTableHandler

#pragma table structure handler

- (NSString *) createTableQuery:(Class) model
{
    OCLObjectParser *parse = [[OCLObjectParser alloc] init];
    NSArray *columns = [parse parseModel:model];
    
    NSString *className = NSStringFromClass (model);
    
    NSString *primaryKey    = [model performSelector:@selector(primaryKey)];
    BOOL autoIncrement      = (BOOL)[model performSelector:@selector(primaryKeyAutoIncrement)];
    NSArray  *ignoredList   = [model performSelector:@selector(ignoredProperties)];
    
    NSMutableString *createQuery = [[NSMutableString alloc] init];
    
    [createQuery appendString:@"DROP TABLE IF EXISTS "];
    [createQuery appendString:[NSString stringWithFormat:@"%@; ", className]];
    
    [createQuery appendString:@"CREATE TABLE IF NOT EXISTS "];
    [createQuery appendString:[NSString stringWithFormat:@"%@ ", className]];
    [createQuery appendString:@"( "];
    
    for(int i=0; i < [columns count]; i++)
    {
        NSDictionary * column = columns[i];
        
        NSString *colName   = [column valueForKey:@"column"];
        NSString *typeName  = [column valueForKey:@"type"];
                
        BOOL isLastColumn = (i == [columns count]-1) ? YES : NO;
        
        if([ignoredList containsObject:colName]) continue;
        
        if([colName isEqualToString:primaryKey])
        {
            if(isLastColumn)
            {
                if(autoIncrement)
                    [createQuery appendString:[NSString stringWithFormat:@"%@ %@ NOT NULL PRIMARY KEY AUTOINCREMENT ", colName, typeName]];
                else
                    [createQuery appendString:[NSString stringWithFormat:@"%@ %@ NOT NULL PRIMARY KEY ", colName, typeName]];
            }
            else
            {
                if(autoIncrement)
                    [createQuery appendString:[NSString stringWithFormat:@"%@ %@ NOT NULL PRIMARY KEY AUTOINCREMENT, ", colName, typeName]];
                else
                    [createQuery appendString:[NSString stringWithFormat:@"%@ %@ NOT NULL PRIMARY KEY, ", colName, typeName]];
            }
                
        }
        else
        {
            if(isLastColumn)
                [createQuery appendString:[NSString stringWithFormat:@"%@ %@ ", colName, typeName]];
            else
                [createQuery appendString:[NSString stringWithFormat:@"%@ %@, ", colName, typeName]];
        }
        
    }
    
    [createQuery appendString:@");"];
    
    if([[OLCOrm getSharedInstance] isDebugEnabled] || [model performSelector:@selector(debug)])
        NSLog(@"[%@]: Query : [%@] %@", OLC_LOG, model, createQuery);
    
    return createQuery;
}

#pragma table CRUD -R operators

- (NSDictionary *) createInsertQuery:(NSObject *) data
{
    NSMutableDictionary *queryData = [[NSMutableDictionary alloc] init];
    
    OCLObjectParser *parse = [[OCLObjectParser alloc] init];
    NSArray *columns = [parse parseObject:data];
    
    NSMutableString *insertQuery = [[NSMutableString alloc] init];
    
    NSString *primaryKey    = [[data class] performSelector:@selector(primaryKey)];
    BOOL autoIncrement      = (BOOL)[[data class] performSelector:@selector(primaryKeyAutoIncrement)];
    NSArray  *ignoredList   = [[data class] performSelector:@selector(ignoredProperties)];
    
    [insertQuery appendString:@"INSERT INTO "];
    [insertQuery appendString:[NSString stringWithFormat:@"%@ ", [data class]]];
    
    NSMutableString *cols = [[NSMutableString alloc] init];
    NSMutableString *vals = [[NSMutableString alloc] init];
    NSMutableDictionary *paraDic = [[NSMutableDictionary alloc] init];
    
    for(int i=0; i < [columns count]; i++)
    {
        
        BOOL isLastColumn = (i == [columns count]-1) ? YES : NO;
        
        NSDictionary *keyval = (NSDictionary *) columns[i];
        
        NSString *colName = [keyval valueForKey:@"column"];
        
        if([colName isEqualToString:primaryKey])
        {
            if(autoIncrement)
                continue;
        }
        
        if([ignoredList containsObject:colName])
            continue;
        
        if(isLastColumn)
            [cols appendString:[NSString stringWithFormat:@"%@", [keyval valueForKey:@"column"]]];
        else
            [cols appendString:[NSString stringWithFormat:@"%@,", [keyval valueForKey:@"column"]]];
        
        if(isLastColumn)
            [vals appendString:[NSString stringWithFormat:@":%@", [keyval valueForKey:@"column"]]];
        else
            [vals appendString:[NSString stringWithFormat:@":%@,", [keyval valueForKey:@"column"]]];
        
        NSObject *value = [keyval valueForKey:@"value"];
        
        if(value == nil) value = (NSString*) @"";
        
        [paraDic setValue:value forKey:[keyval valueForKey:@"column"]];
        
    }
    
    [insertQuery appendString:@"("];
    [insertQuery appendString:cols];
    [insertQuery appendString:@") "];
    [insertQuery appendString:@"VALUES "];
    [insertQuery appendString:@"("];
    [insertQuery appendString:vals];
    [insertQuery appendString:@"); "];
    
    [queryData setValue:insertQuery forKey:OLC_D_QUERY];
    [queryData setObject:paraDic forKey:OLC_D_DATA];
    
    if([[OLCOrm getSharedInstance] isDebugEnabled] || [[data class] performSelector:@selector(debug)])
        NSLog(@"[%@]: Query : [%@] %@ \n\n", OLC_LOG, [data class], insertQuery);
    
    return queryData;
}

- (NSDictionary *) createUpdateQuery:(NSObject *) data
{
    NSMutableDictionary *queryData = [[NSMutableDictionary alloc] init];
    
    OCLObjectParser *parse = [[OCLObjectParser alloc] init];
    NSArray *columns = [parse parseObject:data];
    
    NSMutableString *updateQuery = [[NSMutableString alloc] init];
    
    NSMutableString *vals = [[NSMutableString alloc] init];
    NSMutableDictionary *paraDic = [[NSMutableDictionary alloc] init];
    
    NSString *primaryKey    = [[data class] performSelector:@selector(primaryKey)];
    NSArray  *ignoredList   = [[data class] performSelector:@selector(ignoredProperties)];
    
    [updateQuery appendString:@"UPDATE "];
    [updateQuery appendString:[NSString stringWithFormat:@"%@ ", [data class]]];
    [updateQuery appendString:@"SET "];
        
    NSString *where = @"";
    
    for(int i=0; i < [columns count]; i++)
    {
        BOOL isLastColumn = (i == [columns count]-1) ? YES : NO;
        
        NSDictionary *keyval = (NSDictionary *) columns[i];
        
        NSString *colName = [keyval valueForKey:@"column"];
        
        if([ignoredList containsObject:colName]) continue; //ignore the ignored property list
        
        if([colName isEqualToString:primaryKey]) //update record by primary key reference
        {
            [vals appendString:[NSString stringWithFormat:@":%@", colName]];
            where = [NSString stringWithFormat:@"WHERE %@=:%@", colName, colName];
        }
        else
        {
            if(isLastColumn)
            {
                [vals appendString:[NSString stringWithFormat:@":%@", colName]];
                [updateQuery appendString:[NSString stringWithFormat:@"%@=:%@ ", colName, colName]];
            }
            else
            {
                [vals appendString:[NSString stringWithFormat:@":%@,", colName]];
                [updateQuery appendString:[NSString stringWithFormat:@"%@=:%@, ", colName, colName]];
            }
        }
        
        NSObject *value = [keyval valueForKey:@"value"];
        
        if(value == nil) value = (NSString*) @"";
        
        [paraDic setObject:(NSString*)value forKey:colName];
    }
    
    [updateQuery appendString:where];
    [updateQuery appendString:@";"];
    
    [queryData setValue:updateQuery forKey:OLC_D_QUERY];
    [queryData setObject:paraDic forKey:OLC_D_DATA];
    
    if([[OLCOrm getSharedInstance] isDebugEnabled] || [[data class] performSelector:@selector(debug)])
        NSLog(@"[%@]: Query : [%@] %@ \n\n", OLC_LOG, [data class], updateQuery);
    
    return queryData;
}

- (NSString *) createDeleteQuery:(NSObject *) data
{
    OCLObjectParser *parse = [[OCLObjectParser alloc] init];
    NSArray *columns = [parse parseObject:data];
    
    NSMutableString *deleteQuery = [[NSMutableString alloc] init];
    
    NSString *primaryKey    = [[data class] performSelector:@selector(primaryKey)];
    
    [deleteQuery appendString:@"DELETE FROM "];
    [deleteQuery appendString:[NSString stringWithFormat:@"%@ ", [data class]]];
    
    NSString *where = @"";
    
    for(int i=0; i < [columns count]; i++)
    {
        NSDictionary *keyval = (NSDictionary *) columns[i];
        
        NSString *colName = [keyval valueForKey:@"column"];
        
        if([colName isEqualToString:primaryKey]) //delete record by primary key reference
        {
            where = [NSString stringWithFormat:@"WHERE %@='%@'", [keyval valueForKey:@"column"], [keyval valueForKey:@"value"]];
        }
    }
    
    [deleteQuery appendString:where];
    [deleteQuery appendString:@";"];
    
    if([[OLCOrm getSharedInstance] isDebugEnabled] || [[data class] performSelector:@selector(debug)])
        NSLog(@"[%@]: Query : [%@] %@ \n\n", OLC_LOG, [data class], deleteQuery);
    
    return deleteQuery;
}

- (NSString *) createFindAllQuery:(Class) model;
{
    NSMutableString *selectQuery = [[NSMutableString alloc] init];
    
    [selectQuery appendString:@"SELECT * FROM "];
    [selectQuery appendString:[NSString stringWithFormat:@"%@ ", model]];
    [selectQuery appendString:@";"];
    
    if([[OLCOrm getSharedInstance] isDebugEnabled] || [model performSelector:@selector(debug)])
        NSLog(@"[%@]: Query : [%@] %@ \n\n", OLC_LOG, model, selectQuery);
    
    return selectQuery;
}

- (NSString *) createFindByIdQuery:(Class) model forId:(NSNumber *) Id
{
    OCLObjectParser *parse = [[OCLObjectParser alloc] init];
    NSArray *columns = [parse parseModel:model];
    
    NSMutableString *selectQuery = [[NSMutableString alloc] init];
    
    NSString *primaryKey    = [model performSelector:@selector(primaryKey)];
    
    [selectQuery appendString:@"SELECT * FROM "];
    [selectQuery appendString:[NSString stringWithFormat:@"%@ ", model]];
    
    NSString *where = @"";
    
    for(int i=0; i < [columns count]; i++)
    {
        NSDictionary *keyval = (NSDictionary *) columns[i];
        
        NSString *colName = [keyval valueForKey:@"column"];
        
        if([colName isEqualToString:primaryKey])
        {
            where = [NSString stringWithFormat:@"WHERE %@='%@'", [keyval valueForKey:@"column"], Id];
            break;
        }
    }
    
    [selectQuery appendString:where];
    [selectQuery appendString:@";"];
    
    if([[OLCOrm getSharedInstance] isDebugEnabled] || [model performSelector:@selector(debug)])
        NSLog(@"[%@]: Query : [%@] %@ \n\n", OLC_LOG, model, selectQuery);
    
    return selectQuery;
}

- (NSDictionary *) createFindWhere:(Class) model forVal:(NSString *) value byOperator:(NSString *) opt inColumn:(NSString *) column accending:(BOOL) sort
{
    NSMutableDictionary *queryData = [[NSMutableDictionary alloc] init];
    
    NSMutableString *selectQuery = [[NSMutableString alloc] init];
    
    [selectQuery appendString:@"SELECT * FROM "];
    [selectQuery appendString:[NSString stringWithFormat:@"%@ ", model]];
    [selectQuery appendString:[NSString stringWithFormat:@"WHERE %@ %@ :%@ ", column, opt, column]];
    [selectQuery appendString:[NSString stringWithFormat:@"ORDER BY %@ ", column]];
    
    if(sort)
        [selectQuery appendString:[NSString stringWithFormat:@"ASC"]];
    else
        [selectQuery appendString:[NSString stringWithFormat:@"DESC"]];
    
    [selectQuery appendString:@";"];
    
    NSMutableDictionary *valueDic = [[NSMutableDictionary alloc] init];
    [valueDic setValue:value forKey:column];
    
    [queryData setValue:selectQuery forKey:OLC_D_QUERY];
    [queryData setObject:valueDic forKey:OLC_D_DATA];
    
    if([[OLCOrm getSharedInstance] isDebugEnabled] || [model performSelector:@selector(debug)])
        NSLog(@"[%@]: Query : [%@] %@ \n\n", OLC_LOG, model, selectQuery);
    
    return queryData;
}

- (NSString *) createWhereQuery:(Class) model withFilter:(NSString *) filter andSort:(NSString *) column accending:(BOOL) sort
{
    NSMutableString *selectQuery = [[NSMutableString alloc] init];
    
    [selectQuery appendString:@"SELECT * FROM "];
    [selectQuery appendString:[NSString stringWithFormat:@"%@ ", model]];
    [selectQuery appendString:[NSString stringWithFormat:@"WHERE %@ ", filter]];
    [selectQuery appendString:[NSString stringWithFormat:@"ORDER BY %@ ", column]];
    
    if(sort)
        [selectQuery appendString:[NSString stringWithFormat:@"ASC"]];
    else
        [selectQuery appendString:[NSString stringWithFormat:@"DESC"]];
    
    [selectQuery appendString:@";"];
    
    if([[OLCOrm getSharedInstance] isDebugEnabled] || [model performSelector:@selector(debug)])
        NSLog(@"[%@]: Query : [%@] %@ \n\n", OLC_LOG, model, selectQuery);
    
    return selectQuery;
}

- (NSString *) createOneToOneRelationQuery:(NSObject *) data foreignClass:(Class) fmodel foreignKey:(NSString *) fkey primaryKey:(NSString *) pkey
{
    NSMutableString *selectQuery = [[NSMutableString alloc] init];
    
    OCLObjectParser *parse = [[OCLObjectParser alloc] init];
    NSArray *columns = [parse parseObject:data];
    
    NSString *primaryKey    = [fmodel performSelector:@selector(primaryKey)];
    
    NSNumber * Id = nil;
    for(int i=0; i < [columns count]; i++)
    {
        NSDictionary *keyval = (NSDictionary *) columns[i];
        
        NSString *colName = [keyval valueForKey:@"column"];
        
        if([colName isEqualToString:primaryKey])
        {
            Id = [keyval valueForKey:@"value"];
            break;
        }
    }
    
    [selectQuery appendString:@"SELECT b.* FROM "];
    [selectQuery appendString:[NSString stringWithFormat:@"%@ a ", [data class]]];
    [selectQuery appendString:[NSString stringWithFormat:@"INNER JOIN %@ b ", fmodel]];
    [selectQuery appendString:[NSString stringWithFormat:@"ON a.%@ = b.%@ ", fkey, primaryKey]];
    [selectQuery appendString:[NSString stringWithFormat:@"WHERE a.%@ = %@ ", fkey, Id]];
    [selectQuery appendString:[NSString stringWithFormat:@"ORDER BY a.%@ ", fkey]];
    [selectQuery appendString:@";"];
    
    if([[OLCOrm getSharedInstance] isDebugEnabled] || [[data class] performSelector:@selector(debug)])
        NSLog(@"[%@]: Query : [%@] %@ \n\n", OLC_LOG, [data class], selectQuery);
    
    return selectQuery;
}

- (NSString *) createOneToManyRelationQuery:(NSObject *) data foreignClass:(Class) fmodel foreignKey:(NSString *) fkey primaryKey:(NSString *) pkey
{
    NSMutableString *selectQuery = [[NSMutableString alloc] init];
    
    OCLObjectParser *parse = [[OCLObjectParser alloc] init];
    NSArray *columns = [parse parseObject:data];
    
    NSString *primaryKey    = [[data class] performSelector:@selector(primaryKey)];
    
    NSNumber * Id = nil;
    for(int i=0; i < [columns count]; i++)
    {
        NSDictionary *keyval = (NSDictionary *) columns[i];
        
        NSString *colName = [keyval valueForKey:@"column"];
        
        if([colName isEqualToString:primaryKey])
        {
            Id = [keyval valueForKey:@"value"];
            break;
        }
    }
    
    [selectQuery appendString:@"SELECT b.* FROM "];
    [selectQuery appendString:[NSString stringWithFormat:@"%@ a ", [data class]]];
    [selectQuery appendString:[NSString stringWithFormat:@"CROSS JOIN %@ b ", fmodel]];
    [selectQuery appendString:[NSString stringWithFormat:@"ON a.%@ = b.%@ ", primaryKey, fkey]];
    [selectQuery appendString:[NSString stringWithFormat:@"WHERE a.%@ = %@ ", primaryKey, Id]];
    [selectQuery appendString:[NSString stringWithFormat:@"ORDER BY b.%@ ", fkey]];
    
    [selectQuery appendString:@";"];
    
    if([[OLCOrm getSharedInstance] isDebugEnabled] || [[data class] performSelector:@selector(debug)])
        NSLog(@"[%@]: Query : [%@] %@ \n\n", OLC_LOG, [data class], selectQuery);
    
//    SELECT b.* FROM UserObject a CROSS JOIN TestObject b ON a.Id = b.userId WHERE a.Id = 1 ORDER BY a.userId ;
    
    return selectQuery;
}

- (NSString *) createManyToManyRelationQuery:(NSObject *) data mapModel:(Class) mmodel foreignModel:(Class) fmodel modelMapKey:(NSString *) mmkey foreignMapKey:(NSString *) fmkey
{
//    SELECT
//    m.name
//    , w.*
//    FROM
//    man m
//    INNER JOIN manWork mw ON m.id = mw.man_id
//    INNER JOIN work w ON mw.work_id = w.work_id
    
    NSMutableString *selectQuery = [[NSMutableString alloc] init];
    
    OCLObjectParser *parse = [[OCLObjectParser alloc] init];
    NSArray *columns = [parse parseObject:data];
    
    NSString *primaryKey    = [[data class] performSelector:@selector(primaryKey)];
    
    NSNumber * Id = nil;
    for(int i=0; i < [columns count]; i++)
    {
        NSDictionary *keyval = (NSDictionary *) columns[i];
        
        NSString *colName = [keyval valueForKey:@"column"];
        if([colName isEqualToString:primaryKey])
        {
            Id = [keyval valueForKey:@"value"];
            break;
        }
    }
    
    [selectQuery appendString:@"SELECT c.* FROM "];
    [selectQuery appendString:[NSString stringWithFormat:@"%@ a ", [data class]]];
    [selectQuery appendString:[NSString stringWithFormat:@"INNER JOIN %@ b ", mmodel]];
    [selectQuery appendString:[NSString stringWithFormat:@"ON a.Id = b.%@ ", mmkey]];
    [selectQuery appendString:[NSString stringWithFormat:@"INNER JOIN %@ c ", fmodel]];
    [selectQuery appendString:[NSString stringWithFormat:@"ON c.Id = b.%@ ", fmkey]];
    [selectQuery appendString:[NSString stringWithFormat:@"WHERE a.Id = %@ ", Id]];
    [selectQuery appendString:[NSString stringWithFormat:@"ORDER BY %@ ", mmkey]];
    
    [selectQuery appendString:@";"];
    
    if([[OLCOrm getSharedInstance] isDebugEnabled] || [[data class] performSelector:@selector(debug)])
        NSLog(@"[%@]: Query : [%@] %@ \n\n", OLC_LOG, [data class], selectQuery);
    
    return selectQuery;
}

- (NSString *) createTruncateTableQuery:(Class) model
{
    NSMutableString *truncateQuery = [[NSMutableString alloc] init];
    
    [truncateQuery appendString:@"DELETE FROM "];
    [truncateQuery appendString:[NSString stringWithFormat:@"%@; ", model]];
    [truncateQuery appendString:[NSString stringWithFormat:@"DELETE FROM sqlite_sequence WHERE name='%@';", model] ];
    [truncateQuery appendString:@"VACUUM; "];
    
    if([[OLCOrm getSharedInstance] isDebugEnabled] || [[model class] performSelector:@selector(debug)])
        NSLog(@"[%@]: Query : [%@] %@ \n\n", OLC_LOG, model, truncateQuery);
    
    return truncateQuery;
}

- (NSString *) createLastInsertRecordIdQuery:(Class) model
{
    NSMutableString *truncateQuery = [[NSMutableString alloc] init];
    
    [truncateQuery appendString:@"SELECT last_insert_rowid() as last_insert_rowid; "];
    
    if([[OLCOrm getSharedInstance] isDebugEnabled] || [[model class] performSelector:@selector(debug)])
        NSLog(@"[%@]: Query : [%@] %@ \n\n", OLC_LOG, model, truncateQuery);
    
    return truncateQuery;
}

//- (NSString *) filterEscapChar:(NSString *) value
//{
//    for (NSString* item in TEST)
//    {
//        
//    }
//}

@end
