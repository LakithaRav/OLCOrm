# OLCOrm v1.1.0

[![CI Status](http://img.shields.io/travis/Lakitha Samarasinghe/OLCOrm.svg?style=flat)](https://travis-ci.org/Lakitha Samarasinghe/OLCOrm)
[![Version](https://img.shields.io/cocoapods/v/OLCOrm.svg?style=flat)](http://cocoadocs.org/docsets/OLCOrm)
[![License](https://img.shields.io/cocoapods/l/OLCOrm.svg?style=flat)](http://cocoadocs.org/docsets/OLCOrm)
[![Platform](https://img.shields.io/cocoapods/p/OLCOrm.svg?style=flat)](http://cocoadocs.org/docsets/OLCOrm)

OLCOrm is a Lightweight Object Relational Mapping (ORM) Library for iOS

## Getting Started


### Prerequisities

* **CocoaPods** - For simple painless integration you need [CocoaPods](https://cocoapods.org/) installed in your machine.

### Installation

Basically there are two ways you can integrate this library to your project. Easy way or the Hard way ;)

### Using CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of integrating 3rd-party libraries like OLCOrm into your projects. For more info see ["Getting Started Guide"](https://github.com/AFNetworking/AFNetworking/wiki/Getting-Started-with-AFNetworking). You can install it with the following command:
```bash
$ gem install cocoapods
```
#### Podfile

To integrate OLCOrm into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod "OLCOrm"
```

### Installing Manually

Download and Add the library files found under `OLCOrm/Pod/Classes/` into your project. In your project put the somewhere like `lib/OLCOrm`

## Usage

### Initialising the Database

To initialise your database, first import import the library's umbrella header file to your AppDelegate class as or anywhere else you want to initialize the database (recommend doing it in AppDelegate):

```objective-c
#import "OLCOrm.h"
```
Then intialize the database by calling:

```objective-c
OLCOrm *db = [OLCOrm databaseName:@"db-name.sqlite" version:[NSNumber numberWithInt:1] enableDebug:NO];
```
this command will creates the SqLite databse file for your project. Here `databaseName:` let the lib know what should be the database file called. `version:` sets the database version (remeber to increase this as you add/change Model classes). `enableDebug:` enabling this will log all database operations in your xcode console. 

--- 

### Registering Model Classes

#### Extend the Model from OLCModel Class

For the library to work with your model classes you need to extend your Model(s) with `OLCModel` class.

First import OLCModel into your model using:

```objective-c
#import "OLCModel.h"
```
Then extend like:
```
@interface MyModel : OLCModel
```

#### Register the Model in OLCOrm

In you AppDelegate or wherever you have initialise the Database call the following to register the Model in your db:

```objective-c
[db makeTable:[MyCustomModel class]];
```

##### Options

```objective-c
[db makeTable:[UserObject class] withMigration:NO];
```
*registering your model like that will tell the lib to ignore migration and create an empty table*

```objective-c
[db makeTable:[UserObject class] withTableVersion:2 withMigration:NO];
```
*register your mode this way if you don't want to update the database version, and only update the table structure of the Model class*

--- 

### CRUD Operations

Following examples will guide you through on how to performe Create/Read/Update/Delete operations using the lib

#### Create:

To Create a table record simply call `save` command on model. If the insert is successful it will return **YES** and **NO** on failure.

Example:

```objective-c
TestObject *test = [[TestObject alloc] init];

test.title = [NSString stringWithFormat:@"Sample Record %d", [records count]];
test.coordinates = [NSNumber numberWithDouble:234.345345];
test.currency = [NSNumber numberWithFloat:150.00];
test.flag = [NSNumber numberWithInt:1];
test.addAt = [NSDate date];
test.link = [NSURL URLWithString:@"http://google.com"];
test.status = [NSNumber numberWithInt:1];
...
return [test save];
```

##### Options

Calling `[test saveAndGetId]` will return the inserter record's Id(Primary key) while saving the data to the database. Return of `-1` means failure to insert.

#### Update:

Call `update` on your model to update the current model data. Method will return **YES** or **NO** on success or failure.

Example:

```objective-c
[test update];
```

#### Delete:

Call `delete` on your model will permanently remove the record from db. Method will return **YES** or **NO** on success or failure.

```objective-c
[test delete];
```

#### Read:

### Querying for Data

#### Querying for All

To retrieve all the records realted to a specific model class, call the static method `all` on your model class.

Example:

```objective-c
NSArray *allRecords = [TestObject all];
```
#### Find by Primary Key

Call static method `find` on model class to find a specific record by it's primary key field.

Example:

```objective-c
[TestObject find:@1]
```

#### Filter by a specific column

Call `whereColumn:(NSString *) column byOperator:(NSString *) opt forValue:(NSString *) value accending:(BOOL) sort` static method on your model class.

Example:

```objective-c
[TestObject whereColumn:@"link" byOperator:@"=" forValue:@"http://google.com" accending:YES]
```

#### Filter by a multiple columns

Example:

```objective-c
[TestObject where:@"flag = 1 AND link != 'enabled'" sortBy:@"title" accending:NO];
```

#### Custom Query

Do what ever you want... But! make sure you spell the table name right. It should be you Model Class name.

Example:

```objective-c
[TestObject query:@"SELECT * FROM myTable WHERE STATUS = 1"]
```

## Relationships

Ahhhhh....

### One-to-One

```ruby
[self hasOne:<Model class> foreignKey:<Foreign Key>]
```

Example:

```objective-c
[test hasOne:[UserObject class] foreignKey:@"userId"]
```
Or
```
[test belongTo:[UserObject class] foreignKey:@"userId"]
```

### One-to-Many

```ruby
[self hasMany:<Model class> foreignKey:<Foreign Key>];
```

Example:

```objective-c
[user hasMany:[TestObject class] foreignKey:@"userId"];
```

### Many-to-Many
For the sake of simplicity I dropped that. Well... you'll have to figure out that your self. Go away. No support here buddy.

## Important methods

### Primary Key

You can specify the primary key property of and object by overiding the method `+ (NSString *) primaryKey` and returning the key you want, by default this is set to **Id**

```objective-c
+ (NSString *) primaryKey
{
return @"CustomPrimaryKey";
}
```

### Ignoring properties

If you wnat properties that don't need to be saved to the database but required in runtime. No worries. Ignore thoes properties by overide the method `+ (NSArray *) ignoredProperties` and return an array of property names.

```objective-c
+ (NSArray *) ignoredProperties
{
return @[@"status", @"timer"];
}
```

### Enabling debug mode for a specific Model

To enable debug mode for a specific object you can overid the method `+ (BOOL) debug` and return YES to enable it, by default this is set to NO;

```objective-c
+ (BOOL) debug
{
return YES;
}
```

### Notifications 

You can register for local notification on OLCOrm to monitor database changes. By registering for notifications on a specific model you can monitor Create/Update/Delete operations on that model.

To Register:
```objective-c
[TestObject notifyOnChanges:self withMethod:@selector(testObjNotificationListner:)];
```

To Unregistering:
```objective-c
[TestObject removeNotifyer:self];
```

## Special Thanks

* [@ccgus](https://github.com/ccgus) for the awesome [FMDB](https://github.com/ccgus/fmdb) Objective-C wrapper around SQLite library.
* [@kevinejohn](https://github.com/kevinejohn) for the neat [NSObject-KJSerializer](https://github.com/kevinejohn/NSObject-KJSerializer) utlity class .

## Contributing

Everybody is welcome! Please don't mess with my code ;)

## Authors

Lakitha Samarasinghe, lakitharav@gmail.com

## License

Copyright 2015 Lakitha Samarasinghe

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Acknowledgments

We all know the working with Core Data is major pain in the neck. Yet it is in a way bit easy you work with, if you get an hold of how it actaully work, working with only model calsses to update the database structre on the fly.

And for those who hate to use Core Data, FMDB is you best choice. But still it lack the capability of mapping objects to models. So you have to manullay create the databas and queries, ah.

So I develop this Libaray as an wrapper library to FMDB, that handle the database, table & all other CRUD function that we use daily. To make you life easire.

This libaray is still at it early stages (not even Alpha) so you are always welcome to teak thigs here and there to make this better :).

Happy Coding.
