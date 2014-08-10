//
//  OLCMigrator.h
//  FMDB Database Tutorial
//
//  Created by Lakitha Samarasinghe on 8/7/14.
//  Copyright (c) 2014 Fidenz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OLCMigrator : NSObject

+(OLCMigrator *) sharedInstance:(NSString *) database for:(NSNumber *) version;
+(OLCMigrator *) getSharedInstance;

@property (nonatomic,retain) NSNumber *dbVersion;
@property (nonatomic, retain) NSString *databasePath;

- (void) initDb;
- (BOOL) makeMigrationTable;
- (BOOL) makeTable:(Class) model;
- (BOOL) makeTable:(Class) model withTableVersion:(NSNumber *) dbVersion;
//- (BOOL) migrateTable:(Class) model for:(NSNumber *) dbVersion;

@end
