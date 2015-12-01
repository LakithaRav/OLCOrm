//
//  OCLModel.h
//  FMDB Database Tutorial
//
//  Created by Lakitha Samarasinghe on 8/6/14.
//  Copyright (c) 2014 Fidenz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+KJSerializer.h"
#import "OLCTableHandler.h"
#import "OLCOrm.h"
#import "OLCOrmNotification.h"

@interface OCLModel : NSObject
{
    OLCTableHandler *queryH;
}

/*!
 * @brief Primary Key property if user haven't specified one.
 */
@property (nonatomic, retain) NSNumber* Id;

// CRUD OPTS.

/*!
 @brief         Save object to the database
 @discussion    Call this method when you want to save the object in the database.
 @return        <b>BOOL</b> YES on success and NO on failiure.
 */
- (BOOL) save;

/*!
 @brief         Save object to the database
 @discussion    Similar to default 'save' method, this metod can be use to save object to the database and retrieve the auto-incremental Primary Key back. On faliure this will return <b>-1</b>
 @see           - (BOOL) save
 @return        <b>NSNumber</b> Returns the inserterd record's Auto-Incremental Primary Key
 */
- (NSNumber*) saveAndGetId;

/*!
 @brief         Update object in database
 @discussion    Call this method to update the object on the database. This will use object's currently assigned attribute values to update the database record. Here the query will use 'Primary Key' 
                value to look for the updating object. By default this will be 'Id' but you can always overide the Primary key column
 @return        <b>BOOL</b> YES on success and NO on failiure
 */
- (BOOL) update;

/*!
 @brief         Remove object from database
 @discussion    Call this method to remove an object from the database. Here the query will use 'Primary Key' value to look for the updating object. By default this will be 'Id' but you can always 
                overide the Primary key column
 @return        <b>BOOL</b> YES on success and NO on failiure
 */
- (BOOL) delete;

// RELATIONSHIPS

/*!
 @brief          One-to-One Relationship
 @discussion     This method will create an one-to-one relationship between two objects using sql 'INNER JOIN' between given <b>Model</b> and the <b>Foreign Key</b> value
 Sample usage;
 @code
 return (UserObject*) [self hasOne:[UserObject class] foreignKeyCol:@"userId"] 
 @endcode
 @param          model Class of the object
 @param          fkey Foreign Key Id of the reference object
 @return         <b>NSObject</b> if not found this will return 'nil'
 */
- (NSObject *) hasOne:(Class) model foreignKeyCol:(NSString *) fkey /*primaryKeyCol:(NSString *) pkey*/;

/*!
 @brief         One-to-Many Relationship
 @discussion    This method will create an one-to-many relationship between two objects using sql 'CROSS JOIN' between given <b>Model</b> and the <b>Foreign Key</b> value
 Example;
 @code
 return [self hasMany:[TestObject class] foreignKeyCol:@"userId"] 
 @endcode
 @param         model Class of the object
 @param         fkey Foreign Key Id of the reference object
 @return        <b>NSObject</b> if not found this will return 'nil'
 */
- (NSArray *) hasMany:(Class) model foreignKeyCol:(NSString *) fkey /*primaryKeyCol:(NSString *) pkey*/;

/*!
 @brief         One-to-One Relationship
 @discussion    Similar to 'hasOne', this method will create an one-to-one relationship between two objects using sql 'INNER JOIN' between given <b>Model</b> and the <b>Foreign Key</b> value
                Example;
 @code
 return (UserObject*) [self hasOne:[UserObject class] foreignKeyCol:@"userId"] 
 @endcode
 @param         model Class of the object
 @param         fkey Foreign Key Id of the reference object
 @return        <b>NSObject</b> if not found this will return 'nil'
 @see           (NSObject *) hasOne:(Class) model foreignKeyCol:(NSString *) fkey
 */
- (NSObject *) belongTo:(Class) model foreignKeyCol:(NSString *) pkey;

//- (NSArray *) belongToMany:(Class) model inMapping:(Class) mapmodel foreignKeyCol:(NSString *) fkey primaryKeyCOl:(NSString *) pkey;

// STATIC STUFF

/*!
 @brief         Set custom Primary Key column (default is Id)
 @discussion    Overide this method on your model class when you want to overide the default 'primary key' column of an object model. By default this is set to 'Id'. This change will only effect when 
                creating the database table and chaning this value afterword will cause database operations to fail
 @return        <b>NSString</b> primary key column
 */
+ (NSString*) primaryKey;

/*!
 @brief         Set primary key auto increment option on/off
 @discussion    Overide this method on your model class if you want to toggle the auto incremental option. By default this is set to 'YES'. This will only effect only at table creation stage. Chaing 
                this afterword will take no effect on the model
 @return        <b>BOOL</b> YES to make it auto increment and NO for not
 */
+ (BOOL) primaryKeyAutoIncrement;

/*!
 @brief         Set ignore properties of an object
 
 @discussion    Overide this method to add object properties that need to be ignored at table creation stage. Adding array of property names that need to be ignored when creating the database table.
                By default this returing array is empty
                Example;
 @code
 + (NSArray *) ignoredProperties
 {
     return @[@"status", @"isAdded"];
 }
 @endcode
 @return        <b>NSArray</b> collection of ignoring property list
 */
+ (NSArray *) ignoredProperties;

/*!
 @brief         Set object debug mode on/off
 @discussion    Overide this method on your model class when you want to enable or disable on the model class. This will overide the <b>'[OLCOrm databaseName:@"olcdemo.sqlite" version:[NSNumber
                numberWithInt:1] enableDebug:NO]'</b> option and enable or disable the debuger specifically to that model class
 @return        <b>BOOL</b> YES to enable and NO to disable
 */
+ (BOOL) debug;

/*!
 @brief         Retrive record by it's Primary key
 @discussion    Call this method to retrive single record from it's primary key value
 @param         Id Primary Key value
 @return        <b>NSObject</b> return object if found or nil if not
 */
+ (NSObject *) find:(NSNumber *) Id;

/*!
 @brief         Get all records from the database
 @discussion    Call this method to retrive all the records related to model class from the database
 @return        <b>NSArray</b> array of objects
 */
+ (NSArray*) all;

/*!
 @brief         Search for record by a specific column
 @discussion    Use this method to extract specific set of records using one column
 @code [TestObject whereColumn:@"link" byOperator:@"=" forValue:@"http://google.com" accending:YES] @endcode
 @param         column Column name looking for
 @param         opt Operator to use for the search, Could be =, !=, <, >, <=, >= basically any operator that works in SQL
 @param         sort Sorting order YES for ascending or No for decending
 @return        <b>NSArray</b> of objects
 */
+ (NSArray *) whereColumn:(NSString *) column byOperator:(NSString *) opt forValue:(NSString *) value accending:(BOOL) sort;

/*!
 @brief         Search for records by set of columns
 @discussion    Use this method to extract specific set of records using more than one column
 @code [TestObject where:@"flag = 1" sortBy:@"title, addAt" accending:NO] @endcode
 @param         clause Set of condition for the search query
 @param         column from which column the results should be order by. Could be One or Many
 @param         sort Sorting order YES for ascending or No for decending
 @return        <b>NSArray</b> of objects
 */
+ (NSArray *) where:(NSString *) clause sortBy:(NSString *) column accending:(BOOL) sort;

/*!
 @brief         Execute RAW query on the database
 @discussion    Use this method to execute RAW queries on the SQLite database. Use this incase OLCOrm dose not support your requirment.
 @code [TestObject query:@"Update TestObject SET status = 1"] @endcode
 @param         query Raw SQL query
 @return        <b>NSArray</b> of objects
 */
+ (NSArray *) query:(NSString *) query;

/*!
 @brief         Delete all records from the database
 @discussion    Call this method to remove all records from the database. This will also reset the auto-incremental Id of the table.
 @return        <b>BOOL</b> YES on success No of faliure
 */
+ (BOOL) truncateTable;

/*!
 @brief         Will update the subscribed function on database changes
 @discussion    Subscribe to this method in situations where the application need to monitor changes in a specific model table such as insert, update or delete. When an opertion happen on the
 subscribed table this method will fire the passed method block that you want the callback.
 @code [TestObject notifyOnChanges:self withMethod:@selector(testNotificationListner:)] @endcode
 @param         context Application context. <b>Self</b>
 @param         method reference to a callback method
 */
+ (void) notifyOnChanges:(id) context withMethod:(SEL) method;

/*!
 @brief         Remove database change notificaitons
 @discussion    Call this method to remove the change observer from the mode class
 @param         context Application context. <b>Self</b>
 */
+ (void) removeNotifyer:(id) context;
@end
