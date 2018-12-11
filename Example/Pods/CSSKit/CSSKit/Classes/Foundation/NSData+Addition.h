//
//  NSData+Addition.h
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Addition)

#pragma mark - Encode and Decode

/**
 UTF8编码
 */
- (nullable NSString *)utf8String;

/**
 Base64编码
 */
- (nullable NSString *)base64EncodedString;

/**
 Base64解码
 
 @param base64EncodedString The encoded string.
 */
+ (nullable NSData *)dataWithBase64EncodedString:(NSString *)base64EncodedString;

/**
 Json解析
 如果失败,返回 nil
 */
- (nullable id)jsonValueDecodedWithError:(NSError **)error;

#pragma mark - Hash

/**
 MD5编码
 */
- (NSString *)md5String;

@end

NS_ASSUME_NONNULL_END
