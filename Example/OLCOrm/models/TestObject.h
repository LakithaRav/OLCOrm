//
//  TestObject.h
//  OLCOrm
//
//  Created by Lakitha Samarasinghe on 8/10/14.
//  Copyright (c) 2014 Lakitha Samarasinghe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCLModel.h"

@class UserObject;

@interface TestObject : OCLModel

//@property (nonatomic, retain) NSNumber* Id;
//@property (nonatomic, retain) NSString* title;
//@property (nonatomic, retain) NSNumber* coordinates;
//@property (nonatomic, retain) NSNumber* currency;
//@property (nonatomic, retain) NSNumber* flag;
//@property (nonatomic, retain) NSDate* addAt;
//@property (nonatomic, retain) NSDate* updateAt;
//@property (nonatomic, retain) NSData* data;
//@property (nonatomic, retain) NSURL* link;
//@property (nonatomic, retain) NSNumber* userId;
//@property (nonatomic, retain) NSNumber* status;
//@property (nonatomic, retain) NSSet *stuff;
//@property (nonatomic, retain) NSArray *stuffArry;
//@property (nonatomic, retain) UIImage *image;

@property NSNumber* Id;
@property NSString* title;
@property NSNumber* coordinates;
@property NSNumber* currency;
@property NSNumber* flag;
@property NSDate* addAt;
@property NSDate* updateAt;
@property NSData* data;
@property NSURL* link;
@property NSNumber* userId;
@property NSNumber* status;
@property NSSet *stuff;
@property NSArray *stuffArry;
@property UIImage *image;

- (UserObject *) hasUser;

@end
