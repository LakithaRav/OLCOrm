//
//  OLCOrmNotification.h
//  Pods
//
//  Created by Lakitha Samarasinghe on 4/29/15.
//
//

#import <Foundation/Foundation.h>

@interface OLCOrmNotification : NSNotification

/*!
 @brief         CRUD Operation Enum
 @discussion    Enum hold the Insert, Update, Delete
 */
typedef enum{
    Insert,
    Update,
    Delete
} Operations;

/*!
 @brief         CRUD Operation Enum
 */
@property (nonatomic) NSInteger selection;
@property (nonatomic) Operations type;

- (id)initWithObject:(id) context;

@end
