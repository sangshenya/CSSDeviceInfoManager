//
//  NSDictionary+Addition.h
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<__covariant KeyType, __covariant ObjectType> (Addition)

- (ObjectType)objectOrNilForKey:(KeyType)aKey;

@end

@interface NSMutableDictionary (Addition)

- (void)css_setValidValue:(id)value forKey:(id<NSCopying>)key;

@end
NS_ASSUME_NONNULL_END
