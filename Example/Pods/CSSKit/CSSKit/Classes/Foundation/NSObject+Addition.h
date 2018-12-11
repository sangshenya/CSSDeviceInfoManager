//
//  NSObject+Addition.h
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Addition)

#pragma mark - Swap method (Swizzling)

+ (BOOL)swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel;

+ (BOOL)swizzleClassMethod:(SEL)originalSel with:(SEL)newSel;

/**
 Put the object serialization into json data
 
 @param error error description
 @return return jsonData
 */
- (NSData *)css_serializationToJsonDataWithError:(NSError **)error;

/**
 Put the object serialization into Dictionary
 
 @return dict
 */
- (NSMutableDictionary *)css_toDic;

@end

NS_ASSUME_NONNULL_END
