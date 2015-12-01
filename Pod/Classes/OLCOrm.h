//
//  OLCOrm.h
//  Pods
//
//  Created by Lakitha Samarasinghe on 4/26/15.
//
//

#import <Foundation/Foundation.h>
#import "OLCMigrator.h"

#define OLCORM_NOTIFICATION @"OLCOrmNotficationMsg"

@interface OLCOrm : NSObject

/*!
 * @brief OLCOrm debug enable disable flag
 */
@property (nonatomic, assign) BOOL debugable;

/*!
 @brief         Database initilize method
 @discussion    Calling this will create the database file and initialize the OLCMigrator singleton object
 @param         database name of the database
 @param         version database version. Should be an incremental value. Incrementing will cause to drop and create the database again
 @param         debug Boolean value to enable or disable debug mode
 @return        <b>OLCMigrator</b> singleton object
 */
+(OLCOrm *) databaseName:(NSString *) database version:(NSNumber *) version enableDebug:(BOOL) debug;

/*!
 @brief         Retrieve OLCMigrator singleton object
 @discussion    Method will return already created OLCMigrator object to the caller
 @return        <b>OLCMigrator</b> singleton object
 */
+(OLCOrm *) getSharedInstance;


/*!
 @brief         Get if debug mode is enabled or not
 @discussion    Return the status of the debug mode to the caller
 @return        <b>BOOL</b> debug status YES if enabled NO if not
 */
- (BOOL) isDebugEnabled;

/*!
 @brief         Intermediate method to create table for a specific model class
 @discussion    This method will call the 'OLCMigrator' objects 'makeTable:(Class) model' method
 @param         model Mode class to create
 @return        <b>BOOL</b> debug status YES if enabled NO if not
 */
- (BOOL) makeTable:(Class) model;

/*!
 @brief         Intermediate method to create table for a specific model class
 @discussion    This method will call the 'OLCMigrator' objects 'makeTable:(Class) model withTableVersion:(NSNumber *) version' method
 @param         model Mode class to create
 @param         version Table version
 @return        <b>BOOL</b> debug status YES if enabled NO if not
 */
- (BOOL) makeTable:(Class) model withTableVersion:(NSNumber *) dbVersion;

@end
