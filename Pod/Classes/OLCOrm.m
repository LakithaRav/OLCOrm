//
//  OLCOrm.m
//  Pods
//
//  Created by Lakitha Samarasinghe on 4/26/15.
//
//

#import "OLCOrm.h"

#define OLC_LOG @"OLCLOG"

@implementation OLCOrm
{
    NSString *databaseName;
    NSNumber *databaseVersion;
    OLCMigrator *dbH;
}

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

- (BOOL) makeTable:(Class) model withTableVersion:(NSNumber *) dbVersion
{
    return [dbH makeTable:model withTableVersion:dbVersion];
}

#pragma mark - private

- (void) createDatabase:(NSString *) name withVersion:(NSNumber *) version
{
    dbH = [OLCMigrator sharedInstance:name version:version enableDebug:NO];
    [dbH initDb];
}

@end
