//
//  ObjectParser.m
//  FMDB Database Tutorial
//
//  Created by Lakitha Samarasinghe on 8/6/14.
//  Copyright (c) 2014 Fidenz. All rights reserved.
//

#import "OCLObjectParser.h"
#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>
#import "NSObject+KJSerializer.h"
#import "OCLModel.h"

@implementation OCLObjectParser

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
        if([stringFromMORString isEqualToString:@"@\"NSSet\""] || [stringFromMORString isEqualToString:@"@\"NSArray\""])
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


//- (NSString *) getDBPropertyType:(char *) type
//{
//    //    https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1
//    
//    NSString *dataType = @"TEXT";
//    
//    NSString *stringFromMORString =[[NSString alloc] initWithCString:type encoding:NSMacOSRomanStringEncoding];
//    NSLog(@"%@", stringFromMORString);
//    
//    switch (type[0])
//    {
//        case 'i':
//            dataType = @"NUMARIC";
//            //            NSLog(@"int");
//            break;
//        case 's':
//            dataType = @"TEXT";
//            //            NSLog(@"short");
//            break;
//        case 'l':
//            dataType = @"DOUBLE";
//            //            NSLog(@"long");
//            break;
//        case 'q':
//            dataType = @"DOUBLE";
//            //            NSLog(@"long long");
//            break;
//        case 'C':
//            dataType = @"BOOLEAN";
//            //            NSLog(@"char");
//            break;
//        case 'c':
//            dataType = @"BOOLEAN";
//            //            NSLog(@"char");
//            break;
//        case 'I':
//            dataType = @"INTEGER";
//            //            NSLog(@"int");
//            break;
//        case 'S':
//            dataType = @"TEXT";
//            //            NSLog(@"short");
//            break;
//        case 'L':
//            dataType = @"DOUBLE";
//            //            NSLog(@"long");
//            break;
//        case 'Q':
//            dataType = @"DOUBLE";
//            //            NSLog(@"long");
//            break;
//        case 'f':
//            dataType = @"FLOAT";
//            //            NSLog(@"float");
//            break;
//        case 'd':
//            dataType = @"DOUBLE";
//            //            NSLog(@"double");
//            break;
//        case 'B':
//            dataType = @"BOOLEAN";
//            //            NSLog(@"bool");
//            break;
//        default:
//            
//            if([stringFromMORString isEqualToString:@"@\"NSNumber\""])
//            {
//                dataType = @"INTEGER";
//                //                NSLog(@"NSNumber this is");
//            }
//            else if([stringFromMORString isEqualToString:@"@\"NSString\""])
//            {
//                dataType = @"TEXT";
//                //                NSLog(@"NSData this is");
//            }
//            else if([stringFromMORString isEqualToString:@"@\"NSDate\""])
//            {
//                dataType = @"DATETIME";
//                //                NSLog(@"NSDate this is");
//            }
//            else if([stringFromMORString isEqualToString:@"@\"NSData\""])
//            {
//                dataType = @"BLOB";
//                //                NSLog(@"NSData this is");
//            }
//            else if([stringFromMORString isEqualToString:@"@\"NSSet\""])
//            {
//                dataType = @"BLOB";
//                //                NSLog(@"NSData this is");
//            }
//            else if([stringFromMORString isEqualToString:@"@\"NSSet\""])
//            {
//                dataType = @"BLOB";
//                //                NSLog(@"NSData this is");
//            }
//            
//            break;
//    }
//    
//    return dataType;
//}

//- (NSObject *) getXcodePropertyType:(Class) model
//{
//    NSObject * data = [[NSObject alloc] init];
//    
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    [dic setValue:@"fgdfg" forKey:@"Name"];
//    
//    NSMutableDictionary *dic2 = [[NSMutableDictionary alloc] init];
//    [dic2 setValue:@"1s" forKey:@"0"];
//    [dic2 setValue:@"2s" forKey:@"1"];
//    [dic2 setValue:@"3s" forKey:@"2"];
//    [dic setValue:dic2 forKey:@"Data"];
//    
//    model *smpl = [model new];
//   // [smpl setDictionary:dic];
//    
//    return data;
//}

@end
