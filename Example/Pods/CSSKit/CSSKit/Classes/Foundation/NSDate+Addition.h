//
//  NSDate+Addition.h
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Addition)

@property (nonatomic, readonly, assign) NSInteger year; ///< 年份
@property (nonatomic, readonly, assign) NSInteger month; ///< 月份 (1~12)
@property (nonatomic, readonly, assign) NSInteger day; ///< 日份 (1~31)
@property (nonatomic, readonly, assign) NSInteger hour; ///< 小时 (0~23)
@property (nonatomic, readonly, assign) NSInteger minute; ///< 分钟 (0~59)
@property (nonatomic, readonly, assign) NSInteger second; ///< 秒 (0~59)
@property (nonatomic, readonly, assign) NSInteger nanosecond; ///< 纳秒
@property (nonatomic, readonly, assign) NSInteger weekday; ///< 星期几 (1~7, 周一:2 周二:3 周三:4 周四:5 周五:6 周六:7 周日:1)
@property (nonatomic, readonly, assign) NSInteger weekdayOrdinal; ///< 以7天为单位，范围为1-5 （1-7号为第1个7天，8-14号为第2个7天...）
@property (nonatomic, readonly, assign) NSInteger weekOfMonth; ///< 在当前月中的第几个星期 (1~5)
@property (nonatomic, readonly, assign) NSInteger weekOfYear; ///< 在当前年终的第几个星期 (1~53)
@property (nonatomic, readonly, assign) NSInteger yearForWeekOfYear; ///< 年份(isEqualTo: self.year)
@property (nonatomic, readonly, assign) NSInteger quarter; ///< 季度 (不太明确,数值总是得到0)
@property (nonatomic, readonly, assign) BOOL isLeapMonth; ///< 是否为闰月
@property (nonatomic, readonly, assign) BOOL isLeapYear; ///< 是否为闰年
@property (nonatomic, readonly, assign) BOOL isToday; //是否是今天 (取决于当前locale, 本地化信息,主要体现在"语言"和"区域格式"这两个设置项)
@property (nonatomic, readonly, assign) BOOL isYesterday; //是否为昨天 (取决于当前locale, 本地化信息,主要体现在"语言"和"区域格式"这两个设置项)

#pragma mark - Date Modify

/**
 增加几年后得到的新date
 */
- (nullable NSDate *)dateByAddingYears:(NSInteger)years;

/**
 增加几个月后得到的新date
 */
- (nullable NSDate *)dateByAddingMonths:(NSInteger)months;

/**
 增加几周后得到的新date
 */
- (nullable NSDate *)dateByAddingWeeks:(NSInteger)weeks;

/**
 增加几天后得到的新date
 */
- (nullable NSDate *)dateByAddingDays:(NSInteger)days;

/**
 增加几小时后得到的新date
 */
- (nullable NSDate *)dateByAddingHours:(NSInteger)hours;

/**
 增加几分钟后得到的新date
 */
- (nullable NSDate *)dateByAddingMinutes:(NSInteger)minutes;

/**
 增加几秒钟后得到的新date
 */
- (nullable NSDate *)dateByAddingSeconds:(NSInteger)seconds;

#pragma mark - Date Format

/**
 返回对应格式的date字符串
 @param format 代表所需的日期格式的字符串, example: @"yyyy-MM-dd HH:mm:ss"
 */
- (nullable NSString *)stringWithFormat:(NSString *)format;

/**
 返回对应格式与设置的date字符串
 @param format 代表所需的日期格式的字符串, example: @"yyyy-MM-dd HH:mm:ss"
 @param timeZone 时区
 @param locale 本地化信息,主要体现在"语言"和"区域格式"这两个设置项
 */
- (nullable NSString *)stringWithFormat:(NSString *)format
                               timeZone:(NSTimeZone *)timeZone
                                 locale:(NSLocale *)locale;

/**
 返回ISO8601格式的date字符串
 @return example: @"2017-02-05T23:13:56+0800"
 */
- (nullable NSString *)stringWithISOFormat;

/**
 把字符串根据对应格式转换后的NSDate对象, 如果无法转换,会返回nil
 @param dateString 需要转换的字符串
 @param format 代表所需的日期格式的字符串, example: @"yyyy-MM-dd HH:mm:ss"
 */
+ (nullable NSDate *)dateWithString:(NSString *)dateString format:(NSString *)format;

/**
 把字符串根据对应格式与设置转换后的NSDate对象, 如果无法转换,会返回nil
 @param dateString 需要转换的字符串
 @param format 代表所需的日期格式的字符串, example: @"yyyy-MM-dd HH:mm:ss"
 @param timeZone 时区
 @param locale 本地化信息,主要体现在"语言"和"区域格式"这两个设置项
 */
+ (nullable NSDate *)dateWithString:(NSString *)dateString
                             format:(NSString *)format
                           timeZone:(NSTimeZone *)timeZone
                             locale:(NSLocale *)locale;


/**
 把ISO格式的时间字符串转换成NSDate对象, 如果无法转换,会返回nil
 */
+ (nullable NSDate *)dateWithISOFormatString:(NSString *)dateString;

@end

NS_ASSUME_NONNULL_END
