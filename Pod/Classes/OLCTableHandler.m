//
//  OLCTableHandler.m
//  FMDB Database Tutorial
//
//  Created by Lakitha Samarasinghe on 8/6/14.
//  Copyright (c) 2014 Fidenz. All rights reserved.
//

#import "OLCTableHandler.h"
#import "OCLObjectParser.h"

#define OLC_LOG @"OLCLOG"

@implementation OLCTableHandler

#pragma table structure handler

- (NSString *) createTableQuery:(Class) model
{
    OCLObjectParser *parse = [[OCLObjectParser alloc] init];
    NSArray *columns = [parse parseModel:model];
    
    NSString *className = NSStringFromClass (model);
    
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
        
        BOOL isLastColumn = NO;
        
        isLastColumn = (i == [columns count]-1) ? YES : NO;
        
        if([colName isEqualToString:@"id"] || [colName isEqualToString:@"Id"] || [colName isEqualToString:@"ID"] )
        {
            if(isLastColumn)
                [createQuery appendString:[NSString stringWithFormat:@"%@ %@ NOT NULL PRIMARY KEY AUTOINCREMENT", colName, typeName]];
            else
                [createQuery appendString:[NSString stringWithFormat:@"%@ %@ NOT NULL PRIMARY KEY AUTOINCREMENT, ", colName, typeName]];
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
    
    [insertQuery appendString:@"INSERT INTO "];
    [insertQuery appendString:[NSString stringWithFormat:@"%@ ", [data class]]];
    
    NSMutableString *cols = [[NSMutableString alloc] init];
    NSMutableString *vals = [[NSMutableString alloc] init];
    NSMutableDictionary *paraDic = [[NSMutableDictionary alloc] init];
    
    for(int i=0; i < [columns count]; i++)
    {
//        BOOL isLastColumn = NO;
        
        BOOL isLastColumn = (i == [columns count]-1) ? YES : NO;
        
        NSDictionary *keyval = (NSDictionary *) columns[i];
        
        NSString *colName = [keyval valueForKey:@"column"];
        
        if([colName isEqualToString:@"id"] || [colName isEqualToString:@"Id"] || [colName isEqualToString:@"ID"] )
        {
            continue;
        }
        
        if(isLastColumn)
            [cols appendString:[NSString stringWithFormat:@"%@", [keyval valueForKey:@"column"]]];
        else
            [cols appendString:[NSString stringWithFormat:@"%@,", [keyval valueForKey:@"column"]]];
        
        if(isLastColumn)
        {
//            [vals appendString:[NSString stringWithFormat:@"'%@' ", [keyval valueForKey:@"value"]]];
            [vals appendString:[NSString stringWithFormat:@":%@", [keyval valueForKey:@"column"]]];
        }
        else
        {
//            [vals appendString:[NSString stringWithFormat:@"'%@', ", [keyval valueForKey:@"value"]]];
            [vals appendString:[NSString stringWithFormat:@":%@,", [keyval valueForKey:@"column"]]];
        }
        
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
    
    NSLog(@"[%@]: Query : [%@] %@", OLC_LOG, [data class], insertQuery);
    
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
    
    [updateQuery appendString:@"UPDATE "];
    [updateQuery appendString:[NSString stringWithFormat:@"%@ ", [data class]]];
    [updateQuery appendString:@"SET "];
        
    NSString *where = @"";
    
    for(int i=0; i < [columns count]; i++)
    {
        BOOL isLastColumn = (i == [columns count]-1) ? YES : NO;
        
        NSDictionary *keyval = (NSDictionary *) columns[i];
        
        NSString *colName = [keyval valueForKey:@"column"];
        
        if([colName isEqualToString:@"id"] || [colName isEqualToString:@"Id"] || [colName isEqualToString:@"ID"] )
        {
            [vals appendString:[NSString stringWithFormat:@":%@", colName]];
//            where = [NSString stringWithFormat:@"WHERE %@='%@'", [keyval valueForKey:@"column"], [keyval valueForKey:@"value"]];
            where = [NSString stringWithFormat:@"WHERE %@=:%@", colName, colName];
        }
        else
        {
            if(isLastColumn)
            {
                [vals appendString:[NSString stringWithFormat:@":%@", colName]];
    //            [updateQuery appendString:[NSString stringWithFormat:@"%@='%@' ",    [keyval valueForKey:@"column"], [keyval valueForKey:@"value"]]];
                [updateQuery appendString:[NSString stringWithFormat:@"%@=:%@ ", colName, colName]];
            }
            else
            {
                [vals appendString:[NSString stringWithFormat:@":%@,", colName]];
    //            [updateQuery appendString:[NSString stringWithFormat:@"%@='%@', ",   [keyval valueForKey:@"column"], [keyval valueForKey:@"value"]]];
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
    
    NSLog(@"[%@]: Query : [%@] %@", OLC_LOG, [data class], updateQuery);
    
    return queryData;
}

- (NSString *) createDeleteQuery:(NSObject *) data
{
    OCLObjectParser *parse = [[OCLObjectParser alloc] init];
    NSArray *columns = [parse parseObject:data];
    
    NSMutableString *deleteQuery = [[NSMutableString alloc] init];
    
    [deleteQuery appendString:@"DELETE FROM "];
    [deleteQuery appendString:[NSString stringWithFormat:@"%@ ", [data class]]];
    
    NSString *where = @"";
    
    for(int i=0; i < [columns count]; i++)
    {
        NSDictionary *keyval = (NSDictionary *) columns[i];
        
        NSString *colName = [keyval valueForKey:@"column"];
        
        if([colName isEqualToString:@"id"] || [colName isEqualToString:@"Id"] || [colName isEqualToString:@"ID"] )
        {
            where = [NSString stringWithFormat:@"WHERE %@='%@'", [keyval valueForKey:@"column"], [keyval valueForKey:@"value"]];
        }
    }
    
    [deleteQuery appendString:where];
    [deleteQuery appendString:@";"];
    
    NSLog(@"[%@]: Query : [%@] %@", OLC_LOG, [data class], deleteQuery);
    
    return deleteQuery;
}

- (NSString *) createFindAllQuery:(Class) model;
{
    NSMutableString *selectQuery = [[NSMutableString alloc] init];
    
    [selectQuery appendString:@"SELECT * FROM "];
    [selectQuery appendString:[NSString stringWithFormat:@"%@ ", model]];
    [selectQuery appendString:@";"];
    
    NSLog(@"[%@]: Query : [%@] %@", OLC_LOG, model, selectQuery);
    
    return selectQuery;
}

- (NSString *) createFindByIdQuery:(Class) model forId:(NSNumber *) Id
{
    OCLObjectParser *parse = [[OCLObjectParser alloc] init];
    NSArray *columns = [parse parseModel:model];
    
    NSMutableString *selectQuery = [[NSMutableString alloc] init];
    
    [selectQuery appendString:@"SELECT * FROM "];
    [selectQuery appendString:[NSString stringWithFormat:@"%@ ", model]];
    
    NSString *where = @"";
    
    for(int i=0; i < [columns count]; i++)
    {
        NSDictionary *keyval = (NSDictionary *) columns[i];
        
        NSString *colName = [keyval valueForKey:@"column"];
        
        if([colName isEqualToString:@"id"] || [colName isEqualToString:@"Id"] || [colName isEqualToString:@"ID"] )
        {
            where = [NSString stringWithFormat:@"WHERE %@='%@'", [keyval valueForKey:@"column"], Id];
            break;
        }
    }
    
    [selectQuery appendString:where];
    [selectQuery appendString:@";"];
    
    NSLog(@"[%@]: Query : [%@] %@", OLC_LOG, model, selectQuery);
    
    return selectQuery;
}

- (NSDictionary *) createFindWhere:(Class) model forVal:(NSString *) value byOperator:(NSString *) opt inColumn:(NSString *) column
{
    NSMutableDictionary *queryData = [[NSMutableDictionary alloc] init];
    
    NSMutableString *selectQuery = [[NSMutableString alloc] init];
    
    [selectQuery appendString:@"SELECT * FROM "];
    [selectQuery appendString:[NSString stringWithFormat:@"%@ ", model]];
    
    [selectQuery appendString:[NSString stringWithFormat:@"WHERE %@ %@ :%@", column, opt, column]];
    
    [selectQuery appendString:@";"];
    
    NSMutableDictionary *valueDic = [[NSMutableDictionary alloc] init];
    [valueDic setValue:value forKey:column];
    
    [queryData setValue:selectQuery forKey:OLC_D_QUERY];
    [queryData setObject:valueDic forKey:OLC_D_DATA];
    
    NSLog(@"[%@]: Query : [%@] %@", OLC_LOG, model, selectQuery);
    
    return queryData;
}

- (NSString *) createWhereQuery:(Class) model withFilter:(NSString *) filter andSort:(NSString *) sorter
{
    NSMutableString *selectQuery = [[NSMutableString alloc] init];
    
    [selectQuery appendString:@"SELECT * FROM "];
    [selectQuery appendString:[NSString stringWithFormat:@"%@ ", model]];
    [selectQuery appendString:[NSString stringWithFormat:@"WHERE %@ ", filter]];
    [selectQuery appendString:[NSString stringWithFormat:@"ORDER BY %@ ", sorter]];
    
    [selectQuery appendString:@";"];
    
    NSLog(@"[%@]: Query : [%@] %@", OLC_LOG, model, selectQuery);
    
    return selectQuery;
}

- (NSString *) createOneToOneRelationQuery:(NSObject *) data foreignClass:(Class) fmodel foreignKey:(NSString *) fkey primaryKey:(NSString *) pkey
{
    NSMutableString *selectQuery = [[NSMutableString alloc] init];
    
    OCLObjectParser *parse = [[OCLObjectParser alloc] init];
    NSArray *columns = [parse parseObject:data];
    
    NSNumber * Id = nil;
    for(int i=0; i < [columns count]; i++)
    {
        NSDictionary *keyval = (NSDictionary *) columns[i];
        
        NSString *colName = [keyval valueForKey:@"column"];
        if([colName isEqualToString:@"id"] || [colName isEqualToString:@"Id"] || [colName isEqualToString:@"ID"] )
        {
            Id = [keyval valueForKey:@"value"];
            break;
        }
    }
    
    [selectQuery appendString:@"SELECT b.* FROM "];
    [selectQuery appendString:[NSString stringWithFormat:@"%@ a ", [data class]]];
    [selectQuery appendString:[NSString stringWithFormat:@"INNER JOIN %@ b ", fmodel]];
    [selectQuery appendString:[NSString stringWithFormat:@"ON a.%@ = b.%@ ", fkey, pkey]];
    [selectQuery appendString:[NSString stringWithFormat:@"WHERE a.%@ = %@ ", pkey, Id]];
    [selectQuery appendString:[NSString stringWithFormat:@"ORDER BY a.%@ ", pkey]];
    [selectQuery appendString:@";"];
    
    NSLog(@"[%@]: Query : [%@] %@", OLC_LOG, [data class], selectQuery);
    
    return selectQuery;
}

- (NSString *) createOneToManyRelationQuery:(NSObject *) data foreignClass:(Class) fmodel foreignKey:(NSString *) fkey primaryKey:(NSString *) pkey
{
    NSMutableString *selectQuery = [[NSMutableString alloc] init];
    
    OCLObjectParser *parse = [[OCLObjectParser alloc] init];
    NSArray *columns = [parse parseObject:data];
    
    NSNumber * Id = nil;
    for(int i=0; i < [columns count]; i++)
    {
        NSDictionary *keyval = (NSDictionary *) columns[i];
        
        NSString *colName = [keyval valueForKey:@"column"];
        if([colName isEqualToString:@"id"] || [colName isEqualToString:@"Id"] || [colName isEqualToString:@"ID"] )
        {
            Id = [keyval valueForKey:@"value"];
            break;
        }
    }
    
    [selectQuery appendString:@"SELECT b.* FROM "];
    [selectQuery appendString:[NSString stringWithFormat:@"%@ a ", [data class]]];
    [selectQuery appendString:[NSString stringWithFormat:@"LEFT JOIN %@ b ", fmodel]];
    [selectQuery appendString:[NSString stringWithFormat:@"ON a.%@ = b.%@ ", pkey, fkey]];
    [selectQuery appendString:[NSString stringWithFormat:@"WHERE a.%@ = %@ ", pkey, Id]];
    [selectQuery appendString:[NSString stringWithFormat:@"ORDER BY a.%@ ", pkey]];
    
    [selectQuery appendString:@";"];
    
    NSLog(@"[%@]: Query : [%@] %@", OLC_LOG, [data class], selectQuery);
    
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
    
    NSNumber * Id = nil;
    for(int i=0; i < [columns count]; i++)
    {
        NSDictionary *keyval = (NSDictionary *) columns[i];
        
        NSString *colName = [keyval valueForKey:@"column"];
        if([colName isEqualToString:@"id"] || [colName isEqualToString:@"Id"] || [colName isEqualToString:@"ID"] )
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
    
    NSLog(@"[%@]: Query : [%@] %@", OLC_LOG, [data class], selectQuery);
    
    return selectQuery;
}

- (NSString *) createTruncateTableQuery:(Class) model
{
    NSMutableString *truncateQuery = [[NSMutableString alloc] init];
    
    [truncateQuery appendString:@"DELETE FROM "];
    [truncateQuery appendString:[NSString stringWithFormat:@"%@; ", model]];
    [truncateQuery appendString:[NSString stringWithFormat:@"DELETE FROM sqlite_sequence WHERE name='%@';", model] ];
    [truncateQuery appendString:@"VACUUM; "];
    
    NSLog(@"[%@]: Query : [%@] %@", OLC_LOG, model, truncateQuery);
    
    return truncateQuery;
}

- (NSString *) createLastInsertRecordIdQuery:(Class) model
{
    NSMutableString *truncateQuery = [[NSMutableString alloc] init];
    
    [truncateQuery appendString:@"SELECT last_insert_rowid() as last_insert_rowid; "];
    
    NSLog(@"[%@]: Query : [%@] %@", OLC_LOG, model, truncateQuery);
    
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
