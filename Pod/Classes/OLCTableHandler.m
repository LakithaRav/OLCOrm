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

- (NSString *) createInsertQuery:(NSObject *) data
{
    OCLObjectParser *parse = [[OCLObjectParser alloc] init];
    NSArray *columns = [parse parseObject:data];
    
    NSMutableString *insertQuery = [[NSMutableString alloc] init];
    
    [insertQuery appendString:@"INSERT INTO "];
    [insertQuery appendString:[NSString stringWithFormat:@"%@ ", [data class]]];
    
    NSMutableString *cols = [[NSMutableString alloc] init];
    NSMutableString *vals = [[NSMutableString alloc] init];
    
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
            [cols appendString:[NSString stringWithFormat:@"%@ ", [keyval valueForKey:@"column"]]];
        else
            [cols appendString:[NSString stringWithFormat:@"%@, ", [keyval valueForKey:@"column"]]];
        
        if(isLastColumn)
            [vals appendString:[NSString stringWithFormat:@"'%@' ", [keyval valueForKey:@"value"]]];
        else
            [vals appendString:[NSString stringWithFormat:@"'%@', ", [keyval valueForKey:@"value"]]];
    }
    
    [insertQuery appendString:@"( "];
    [insertQuery appendString:cols];
    [insertQuery appendString:@") "];
    [insertQuery appendString:@"VALUES "];
    [insertQuery appendString:@"( "];
    [insertQuery appendString:vals];
    [insertQuery appendString:@"); "];
    
    NSLog(@"[%@]: Query : [%@] %@", OLC_LOG, [data class], insertQuery);
    
    return insertQuery;
}

- (NSString *) createUpdateQuery:(NSObject *) data
{
    OCLObjectParser *parse = [[OCLObjectParser alloc] init];
    NSArray *columns = [parse parseObject:data];
    
    NSMutableString *updateQuery = [[NSMutableString alloc] init];
    
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
            where = [NSString stringWithFormat:@"WHERE %@='%@'", [keyval valueForKey:@"column"], [keyval valueForKey:@"value"]];
            continue;
        }
        
        if(isLastColumn)
            [updateQuery appendString:[NSString stringWithFormat:@"%@='%@' ",    [keyval valueForKey:@"column"], [keyval valueForKey:@"value"]]];
        else
            [updateQuery appendString:[NSString stringWithFormat:@"%@='%@', ",   [keyval valueForKey:@"column"], [keyval valueForKey:@"value"]]];
    }
    
    [updateQuery appendString:where];
    [updateQuery appendString:@";"];
    
    NSLog(@"[%@]: Query : [%@] %@", OLC_LOG, [data class], updateQuery);
    
    return updateQuery;
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

- (NSString *) createFindWhere:(Class) model forVal:(NSString *) value byOperator:(NSString *) opt inColumn:(NSString *) column
{
    NSMutableString *selectQuery = [[NSMutableString alloc] init];
    
    [selectQuery appendString:@"SELECT * FROM "];
    [selectQuery appendString:[NSString stringWithFormat:@"%@ ", model]];
    
    [selectQuery appendString:[NSString stringWithFormat:@"WHERE %@ %@ '%@'", column, opt, value]];
    
    [selectQuery appendString:@";"];
    
    NSLog(@"[%@]: Query : [%@] %@", OLC_LOG, model, selectQuery);
    
    return selectQuery;
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

//- (NSString *) createManyToManyRelationQuery:(Class) model foreignClass:(Class) fmodel foreignKey:(NSString *) fkey primaryKey:(NSString *) pkey
//{
////    SELECT
////    m.name
////    , w.*
////    FROM
////    man m
////    INNER JOIN manWork mw ON m.id = mw.man_id
////    INNER JOIN work w ON mw.work_id = w.work_id
//    
//    NSMutableString *selectQuery = [[NSMutableString alloc] init];
//    
//    [selectQuery appendString:@"SELECT b.* FROM "];
//    [selectQuery appendString:[NSString stringWithFormat:@"%@ a ", model]];
//    [selectQuery appendString:[NSString stringWithFormat:@"INNER JOIN %@ b ", fmodel]];
//    [selectQuery appendString:[NSString stringWithFormat:@"ON a.%@ = b.%@ ", pkey, fkey]];
//    [selectQuery appendString:[NSString stringWithFormat:@"ORDER BY %@ ", pkey]];
//    
//    [selectQuery appendString:@";"];
//    
//    NSLog(@"[%@]: Query : [%@] %@", OLC_LOG, model, selectQuery);
//    
//    return selectQuery;
//}

@end
