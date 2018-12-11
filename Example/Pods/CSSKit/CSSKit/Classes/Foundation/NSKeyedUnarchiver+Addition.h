//
//  NSKeyedUnarchiver+Addition.h
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSKeyedUnarchiver (Addition)

+ (nullable id)unarchiveObjectWithData:(NSData *)data exception:(NSException *_Nullable *_Nullable)exception;

+ (nullable id)unarchiveObjectWithFile:(NSString *)path exception:(NSException *_Nullable *_Nullable)exception;

@end

NS_ASSUME_NONNULL_END
