//
//  ObjectParser.h
//  FMDB Database Tutorial
//
//  Created by Lakitha Samarasinghe on 8/6/14.
//  Copyright (c) 2014 Fidenz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCLObjectParser : NSObject

- (NSArray *) scanModel:(Class) model;
- (NSArray *) parseModel:(Class) model;
- (NSArray *) parseObject: (NSObject *) object;

@end
