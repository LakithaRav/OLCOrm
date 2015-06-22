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

+(OLCMigrator *) sharedInstance:(NSString *) database version:(NSNumber *) version enableDebug:(BOOL) debug;
+(OLCMigrator *) getSharedInstance;

@property (nonatomic, assign) BOOL debugable;
@property (nonatomic,retain) NSNumber *dbVersion;
@property (nonatomic, retain) NSString *databasePath;

- (void) initDb;
//- (BOOL) makeMigrationTable;
- (BOOL) makeTable:(Class) model;
- (BOOL) makeTable:(Class) model withTableVersion:(NSNumber *) dbVersion;
//- (BOOL) migrateTable:(Class) model for:(NSNumber *) dbVersion;

@end
