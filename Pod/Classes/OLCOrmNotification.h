//
//  OLCOrmNotification.h
//  Pods
//
//  Created by Lakitha Samarasinghe on 4/29/15.
//
//

#import <Foundation/Foundation.h>

@interface OLCOrmNotification : NSNotification

typedef enum{
    Insert,
    Update,
    Delete
} Operations;

- (id)initWithObject:(id) context;

@property (nonatomic) NSInteger selection;
@property (nonatomic) Operations type;

@end
