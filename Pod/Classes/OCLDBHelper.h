//
//  OCLDBHelper.h
//  FMDB Database Tutorial
//
//  Created by Lakitha Samarasinghe on 8/6/14.
//  Copyright (c) 2014 Fidenz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "OLCMigrator.h"

@interface OCLDBHelper : NSObject

//+(OCLDBHelper *) sharedInstance:(NSString *) database;

/*! @brief This property hold the name of the database */
@property (nonatomic, retain) NSString* databaseName;

/*!
 @brief         Initialize the database using FMDB library
 @discussion    This method will create the physical database library in the device with the help of FMDB library and returns the database instance back to the user
 @return        <b>FMDatabase</b> the database instance
 */
- (FMDatabase *) getDb;

/*!
 @brief         This method initialize the database using FMDB library. (Thread safe)
 @discussion    Similar to 'getDb' method this method also create the physical database file on the device and return the <b>FMDatabaseQueue</b> instance to the caller. This is method is use when we 
                are considering thread safe calls
 @see           - (FMDatabase *) getDb
 @return        <b>FMDatabaseQueue</b> the database instance
 */
- (FMDatabaseQueue *) getQueueDb;

/*!
 @brief         Pass the object's Class to create the database table
 @discussion    Responsible for de-serializing the model class and create the SQLite database table
 @param         model object's Class
 @return        BOOL return YES if table got created successfully and NO if not

 */
- (BOOL) makeTable:(Class) model;

/*!
 @brief         Pass raw sql query string to create a database table
 @discussion    To create some custom database table that's not related to any model class, call this with the table create statment
 @param         query String value of the query string
 @return        BOOL return YES if table got created successfully and NO if not
 */
- (BOOL) makeRawTable:(NSString *) query;

@end
