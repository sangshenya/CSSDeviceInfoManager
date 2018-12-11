//
//  NSDictionary+Addition.m
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import "NSDictionary+Addition.h"

@implementation NSDictionary (Addition)

- (id)objectOrNilForKey:(NSString *)aKey {
    if (![self isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if (!aKey) return nil;
    
    id value = self[aKey];
    if (!value || value == [NSNull null]) return nil;
    
    return value;
}

@end

@implementation NSMutableDictionary (Addition)

- (void)css_setValidValue:(id)value forKey:(id<NSCopying>)key {
    if (value != nil) {
        [self setObject:value forKey:key];
    }
}

@end
