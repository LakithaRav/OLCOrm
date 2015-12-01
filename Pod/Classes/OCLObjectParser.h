//
//  ObjectParser.h
//  FMDB Database Tutorial
//
//  Created by Lakitha Samarasinghe on 8/6/14.
//  Copyright (c) 2014 Fidenz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCLObjectParser : NSObject

/*!
 @brief          De-Serialize Mode Class
 @discussion     Pass the model class to this method to de-serialize the class to get the name value pair of attribute name and it's data type
 @param          model Class of the object
 @return         <b>NSArray</b> array of NSDictionary values
 */
- (NSArray *) scanModel:(Class) model;

/*!
 @brief          De-Serialize Mode Class
 @discussion     Almost similar to 'scanModel' method, this will also de-serialize the model class. But the difference is that the attribute's datatypes are converted to SQLite datatypes
 @remark         Helper method on creating the sql create statement on an model class
 @param          model Class of the object
 @return         <b>NSArray</b> array of NSDictionary values
 */
- (NSArray *) parseModel:(Class) model;

/*!
 @brief          De-Serialize Object to collection of NSDictionary values
 @discussion     This method de-serializes the object and convert it to an array of NSDictionary values
 @remark         Helper method create the Insert and Update SQL statements
 @param          object object to be de-serialze
 @return         <b>NSArray</b> array of NSDictionary values
 */
- (NSArray *) parseObject: (NSObject *) object;

@end
