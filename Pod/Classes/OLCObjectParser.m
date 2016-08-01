//
//  ObjectParser.m
//  FMDB Database Tutorial
//
//  Created by Lakitha Samarasinghe on 8/6/14.
//  Copyright (c) 2014 Fidenz. All rights reserved.
//

#import "OLCObjectParser.h"
#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>
#import "NSObject+KJSerializer.h"
#import "OLCModel.h"
#import "FMDB/FMDatabase.h"

@implementation OLCObjectParser

- (NSArray *) scanModel:(Class) model
{
    id class = model;
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    
    NSMutableArray *propertyArry = [[NSMutableArray alloc] init];
    
    for (i = 0; i < outCount; i++)
    {
        NSMutableDictionary *column = [[NSMutableDictionary alloc] init];
        
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        
        char *type = property_copyAttributeValue(property, "T");
        NSString *stringType =[[NSString alloc] initWithCString:type encoding:NSMacOSRomanStringEncoding];
        
        [column setValue:propertyName forKey:@"column"];
        [column setValue:stringType forKey:@"type"];
        
        [propertyArry addObject:column];
    }
    
    return propertyArry;
}


- (NSArray *) parseModel:(Class) model
{
    id class = model;
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    
    NSString *primaryKey    = [model performSelector:@selector(primaryKey)];
//    BOOL autoIncrement      = [model performSelector:@selector(primaryKeyAutoIncrement)];
    NSArray  *ignoredList   = [model performSelector:@selector(ignoredProperties)];
    
//    BOOL idColFound = NO;
    
    NSMutableArray *propertyArry = [[NSMutableArray alloc] init];
    
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];

        char *type = property_copyAttributeValue(property, "T");
        
       
        NSString *columnName = propertyName;
        
        //check and skip ignore fields
        if([ignoredList containsObject:columnName]) continue;
        
        NSString *dataType = [self getDBPropertyType:type];

        
        NSMutableDictionary *column = [[NSMutableDictionary alloc] init];
        
//        [column setValue:columnName forKey:@"column"];
//        [column setValue:dataType forKey:@"type"];
        
        if([columnName isEqualToString:primaryKey])
        {
//            idColFound = YES;
            
            [column setValue:columnName forKey:@"column"];
            [column setValue:@"INTEGER" forKey:@"type"];
        }
        else
        {
            
            [column setValue:columnName forKey:@"column"];
            [column setValue:dataType forKey:@"type"];
        }
        
        [propertyArry addObject:column];
    }
    
//    if(!idColFound)
//    {
//        NSMutableDictionary *column = [[NSMutableDictionary alloc] init];
//        [column setValue:@"id" forKey:@"column"];
//        [column setValue:@"INTEGER" forKey:@"type"];
//        
//        [propertyArry addObject:column];
//    }
    
    return propertyArry;
}


- (NSArray *) parseObject: (NSObject *) object
{
    id class = [object class];
    
    NSMutableArray *dataArry = [[NSMutableArray alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        
        char *type = property_copyAttributeValue(property, "T");
        
        NSString *propertyName  = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        
        
        NSMutableDictionary *column = [[NSMutableDictionary alloc] init];
        [column setValue:propertyName forKey:@"column"];
        
        
        NSString *stringFromMORString =[[NSString alloc] initWithCString:type encoding:NSMacOSRomanStringEncoding];
        if([stringFromMORString isEqualToString:@"@\"NSSet\""] || [stringFromMORString isEqualToString:@"@\"NSArray\""] || [stringFromMORString isEqualToString:@"@\"NSDictionary\""])
        {
            NSData *data            = [NSKeyedArchiver archivedDataWithRootObject:[object valueForKey:propertyName]];
            [column setObject:data forKey:@"value"];
        }
        else if([stringFromMORString isEqualToString:@"@\"UIImage\""])
        {
            NSData *data            = UIImagePNGRepresentation([object valueForKey:propertyName]);
            [column setObject:data forKey:@"value"];
        }
        else
        {
            NSObject *value         = [object valueForKey:propertyName];
            [column setValue:value forKey:@"value"];
        }
        
        [dataArry addObject:column];
    }
    
    return dataArry;
}

/*!
 @brief          Map Objective-c datatypes to SQLite datatypes
 @discussion     This method map Objective-c datatypes to SQLite compatible datatypes to create the CREATE statment
 @param          type char value of the attribute type
 @return         <b>NSArray</b> array of NSDictionary values
 */
- (NSString *) getDBPropertyType:(char *) type
{
    NSString *dataType = @"TEXT";
    
    NSString *stringFromMORString =[[NSString alloc] initWithCString:type encoding:NSMacOSRomanStringEncoding];
//    NSLog(@"%@", stringFromMORString);
    
    switch (type[0])
    {
        case 'i':
            dataType = @"NUMARIC";
            //            NSLog(@"int");
            break;
        case 's':
            dataType = @"TEXT";
            //            NSLog(@"short");
            break;
        case 'l':
            dataType = @"NUMARIC";
            //            NSLog(@"long");
            break;
        case 'q':
            dataType = @"NUMARIC";
            //            NSLog(@"long long");
            break;
        case 'C':
            dataType = @"NUMARIC";
            //            NSLog(@"char");
            break;
        case 'c':
            dataType = @"NUMARIC";
            //            NSLog(@"char");
            break;
        case 'I':
            dataType = @"NUMARIC";
            //            NSLog(@"int");
            break;
        case 'S':
            dataType = @"TEXT";
            //            NSLog(@"short");
            break;
        case 'L':
            dataType = @"NUMARIC";
            //            NSLog(@"long");
            break;
        case 'Q':
            dataType = @"NUMARIC";
            //            NSLog(@"long");
            break;
        case 'f':
            dataType = @"NUMARIC";
            //            NSLog(@"float");
            break;
        case 'd':
            dataType = @"NUMARIC";
            //            NSLog(@"double");
            break;
        case 'B':
            dataType = @"NUMARIC";
            //            NSLog(@"bool");
            break;
        default:
            
            if([stringFromMORString isEqualToString:@"@\"NSNumber\""])
            {
                dataType = @"NUMARIC";
            }
            else if([stringFromMORString isEqualToString:@"@\"NSString\""])
            {
                dataType = @"TEXT";
            }
            else if([stringFromMORString isEqualToString:@"@\"NSDate\""])
            {
                dataType = @"DATETIME";
            }
            else if([stringFromMORString isEqualToString:@"@\"NSData\""])
            {
                dataType = @"BLOB";
            }
            else if([stringFromMORString isEqualToString:@"@\"NSSet\""])
            {
                dataType = @"BLOB";
            }
            else if([stringFromMORString isEqualToString:@"@\"NSURL\""])
            {
                dataType = @"BLOB";
            }
            else if([stringFromMORString isEqualToString:@"@\"NSInteger\""])
            {
                dataType = @"INTEGER";
            }
            else
            {
                dataType = @"BLOB";
            }
            
            break;
    }
    
    return dataType;
}

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
