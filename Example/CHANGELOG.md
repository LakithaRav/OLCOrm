# Change Log
All notable changes to this project will be documented in this file.

---

## [1.1.1](https://github.com/LakithaRav/OLCOrm/releases/tag/1.1.1) (03/08/2016)
Released on Webdsday, August 03, 2016.

#### Added
* CHANGELOG.md file added.

#### Changed
* Reverted `- (NSObject *) hasOne:(Class) model foreignKeyCol:(NSString *) fkey` to `- (NSObject *) hasOne:(Class) model foreignKey:(NSString *) fkey` for simplicity.
* Reverted `- (NSArray *) hasMany:(Class) model foreignKeyCol:(NSString *) fkey` to `- (NSArray *) hasMany:(Class) model foreignKey:(NSString *) fkey` for simplicity.
* Reverted `- (NSObject *) belongTo:(Class) model foreignKeyCol:(NSString *) pkey` to `- (NSObject *) belongTo:(Class) model foreignKey:(NSString *) pkey` for simplicity.


## [1.1.0](https://github.com/LakithaRav/OLCOrm/releases/tag/1.1.0) (24/07/2016)
Released on Sunday, July 24, 2016.

#### Added
* Data migration on database version update added.
* `+ (void) printTable` static method added to dump the table strcture with record to xcode console.

#### Updated
* CocoaPods structure updated with latest [updated](http://blog.cocoapods.org/CocoaPods-App-1.0/).