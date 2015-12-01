//
//  OLCMigrator.h
//  FMDB Database Tutorial
//
//  Created by Lakitha Samarasinghe on 8/7/14.
//  Copyright (c) 2014 Fidenz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OLCMigrator : NSObject
{

}

/*!
 * @brief Boolean flag that tell if the debug mode is enable or not
 */
@property (nonatomic, assign) BOOL debugable;

/*!
 * @brief save the database version for easy access
 */
@property (nonatomic,retain) NSNumber *dbVersion;

/*!
 * @brief hold the path to the database file
 */
@property (nonatomic, retain) NSString *databasePath;

/*!
 @brief         Database initilize method
 @discussion    Calling this will initialize the OLCMigrator singleton object
 @param         database name of the database
 @param         version database version. Should be an incremental value. Incrementing will cause to drop and create the database again
 @param         debug Boolean value to enable or disable debug mode
 @return        <b>OLCMigrator</b> singleton object
 */
+(OLCMigrator *) sharedInstance:(NSString *) database version:(NSNumber *) version enableDebug:(BOOL) debug;

/*!
 @brief         Retrieve OLCMigrator singleton object
 @discussion    Method will return already created OLCMigrator object to the caller
 @return        <b>OLCMigrator</b> singleton object
 */
+(OLCMigrator *) getSharedInstance;

/*!
 @brief         Initalize the database
 @discussion    Calling this will create the SQLite database file on device and create the migration table with table verioning
 */
- (void) initDb;

/*!
 @brief         Create the database table
 @discussion    This method will create the database table of the model class. Here when createing the database table, the verioning will consider the database version number to update the table structres
 @param         model Class of a specific model
 @return        <b>BOOL</b> YES if created, NO if failed
 */
- (BOOL) makeTable:(Class) model;

/*!
 @brief         Create the database table
 @discussion    Similar to 'makeTable:(Class) model' method this is also used to create the model table, but the option of passing the table version as well. So you can have different table verisons with different database verisons.
 @remark        User when you don't want to drop the whole database to update a one table strucutre. Otherwise it's prefered  to go with the database verions number
 @param         model Class of a specific model
 @param         version table verion number
 @return        <b>BOOL</b> YES if created, NO if failed
 */
- (BOOL) makeTable:(Class) model withTableVersion:(NSNumber *) dbVersion;

@end
