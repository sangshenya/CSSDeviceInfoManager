//
//  NSArray+Addition.m
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import "NSArray+Addition.h"

@implementation NSArray (Addition)

- (id)objectOrNilAtIndex:(NSUInteger)index {
    if (index >= self.count) return nil;
    
    id obj = [self objectAtIndex:index];
    if ([obj isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return obj;
}

@end

@implementation NSMutableArray (Addition)

- (void)reverse {
    NSUInteger count = self.count;
    int mid = floor(count / 2.0);
    for (NSUInteger i = 0; i < mid; i ++) {
        [self exchangeObjectAtIndex:i withObjectAtIndex:(count - (i + 1))];
    }
}

- (void)shuffle {
    for (NSUInteger i = self.count; i > 1; i --) {
        [self exchangeObjectAtIndex:(i - 1) withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
    }
}

@end
