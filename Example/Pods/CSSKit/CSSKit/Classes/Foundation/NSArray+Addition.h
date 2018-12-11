//
//  NSArray+Addition.h
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<__covariant ObjectType> (Addition)

- (nullable ObjectType)objectOrNilAtIndex:(NSUInteger)index;

@end

@interface NSMutableArray<ObjectType> (Addition)

/**
 Reverse the index of object in this array.
 Example: Before @[@1, @2, @3], After @[@3, @2, @1].
 */
- (void)reverse;

/**
 Sort the object in this array randomly
 */
- (void)shuffle;

@end

NS_ASSUME_NONNULL_END
