//
//  NSString+Addition.h
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Addition)

#pragma mark - Utilities

/**
 返回一个新的UUID
 */
+ (nullable NSString *)stringWithUUID;

/**
 简单验证是否是手机号码,1开头,11位
 */
- (BOOL)isTelephoneNumberSimple;

/**
 是否有中文
 */
- (BOOL)containsChinese;

/**
 不是空字符串, nil, @"", @"  ", @"\n", @"\t" 返回NO, 否则返回YES
 */
- (BOOL)isNotBlank;

/**
 用UTF-8编码成NSData类型
 */
- (nullable NSData *)dataValue;

#pragma mark - Encode and decode

/**
 Base64编码
 */
- (nullable NSString *)base64EncodedString;

/**
 Base64解码
 
 @param base64EncodedString The encoded string
 */
+ (nullable NSString *)stringWithBase64EncodedString:(NSString *)base64EncodedString;

/**
 Json解析
 如果失败,返回 nil
 
 e.g. NSString: @"{"name":"a","count":2}"  => NSDictionary: @[@"name":@"a",@"count":@2]
 */
- (nullable id)jsonValueDecodedWithError:(NSError **)error;

/**
 URL编码, utf-8
 */
- (NSString *)stringByURLEncode;

/**
 URL解码, utf-8
 */
- (NSString *)stringByURLDecode;

#pragma mark - Hash

/**
 MD5字符串
 */
- (nullable NSString *)md5String;

#pragma mark - Drawing

/**
 Returns the size of the string if it were rendered with the specified constraints.
 
 @param font          The font to use for computing the string size.
 
 @param size          The maximum acceptable size for the string. This value is
 used to calculate where line breaks and wrapping would occur.
 
 @param lineBreakMode The line break options for computing the size of the string.
 For a list of possible values, see NSLineBreakMode.
 
 @return              The width and height of the resulting string's bounding box.
 These values may be rounded up to the nearest whole number.
 */
- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode;

/**
 Returns the width of the string if it were to be rendered with the specified
 font on a single line.
 
 @param font  The font to use for computing the string width.
 
 @return      The width of the resulting string's bounding box. These values may be
 rounded up to the nearest whole number.
 */
- (CGFloat)widthForFont:(UIFont *)font;

/**
 Returns the height of the string if it were rendered with the specified constraints.
 
 @param font   The font to use for computing the string size.
 
 @param width  The maximum acceptable width for the string. This value is used
 to calculate where line breaks and wrapping would occur.
 
 @return       The height of the resulting string's bounding box. These values
 may be rounded up to the nearest whole number.
 */
- (CGFloat)heightForFont:(UIFont *)font width:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
