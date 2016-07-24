//
//  OLCOrm.m
//  Pods
//
//  Created by Lakitha Samarasinghe on 4/26/15.
//
//

#import "OLCOrm.h"
#import "OLCModel.h"

#define OLC_LOG @"OLCLOG"

@implementation OLCOrm
{
    NSString *databaseName;
    NSNumber *databaseVersion;
    OLCMigrator *dbH;
}

/*!
 * @brief Singleton object of OLCMigrator class
 */
static OLCOrm *_sharedInt = nil;


+(OLCOrm *) databaseName:(NSString *) database version:(NSNumber *) version enableDebug:(BOOL) debug
{
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        
        _sharedInt = [[self alloc] init];
        _sharedInt.debugable    = debug;
        
        [_sharedInt createDatabase:database withVersion:version];
        
    });
    
    return _sharedInt;
}


+(OLCOrm *) getSharedInstance
{
    return _sharedInt;
}

#pragma mark - public 


- (BOOL) isDebugEnabled;
{
    return _sharedInt.debugable;
}


- (BOOL) makeTable:(Class) model
{
    return [dbH makeTable:model];
}

- (BOOL) makeTable:(Class) model withMigration:(BOOL) migrate
{
    return [dbH makeTable:model withMigration:migrate];
}

- (BOOL) makeTable:(Class) model withTableVersion:(NSNumber *) version withMigration:(BOOL) migrate
{
    return [dbH makeTable:model withTableVersion:version withMigration:migrate];
}

#pragma mark - private

/*!
 @brief         Intermediate method to create database file
 @discussion    This method will call the 'OLCMigrator' objects 'createDatabase:(NSString *) name withVersion:(NSNumber *) version' method
 @param         name Database name
 @param         version Database version
 @remark        Private method
 */
- (void) createDatabase:(NSString *) name withVersion:(NSNumber *) version
{
    dbH = [OLCMigrator sharedInstance:name version:version enableDebug:self.debugable];
    [dbH initDb];
}

@end
