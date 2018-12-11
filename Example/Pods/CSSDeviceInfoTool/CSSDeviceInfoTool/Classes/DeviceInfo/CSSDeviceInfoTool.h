//
//  CSSDeviceInfoTool.h
//  CSSDeviceInfoTool
//
//  Created by 陈坤 on 2018/12/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Get device IMSI, e.g. @"46001", may be nil if not match
NSString * KCSSTIMSI(void);

/// Get device mobileCountryCode, e.g. @"460", may be nil if not match
NSString * KCSSTMCC(void);

/// Get network type, e.g. @"2G", @"3G", @"4G", @"wifi", may be @"" if not match
NSString * KCSSTNetworkType(void);

/// Get network ip, e.g. @"192.168.199.223", may be @"" if not match
NSString *KCSSTNetworkIP(BOOL preferIPv4);

/// Is there a agent
BOOL KCSSTNetworkAgent(void);

/// Get device idfa
NSString * KCSSTIDFA(void);

/// Get device idfv;
NSString * KCSSTIDFV(void);

/// Get device udid
NSString * KCSSTOpenUDID(NSError **error);

/// Get device system version (e.g. 8.1)
NSString * KCSSTSystemVersion(void);

/// Get sdk cacheDirectory, e.g. /Users/chenkun/Library/Developer/CoreSimulator/Devices/429CCC95-F321-4144-851F-CBC1EA622A3A/data/Containers/Data/Application/920755F5-5D21-414F-82AA-88DC2AF2E17F/Documents/com.ecook.tracker/cache
NSString * KCSSTCacheDirectory(void);

/// Get app bundle id
NSString * KCSSTAPPBundleID(void);

/// Get app version
NSString * KCSSTAPPVersion(void);

/// Change date to String with formatter
NSString * KCSSTDateString(NSDate *date, NSString *format);

/// Get webview User-Agent
NSString * KCSSTWebviewUA(void);

/// 多少长度内的随机字符串
NSString * KCSSTRandomStringOfLength(NSInteger length);

/// 设备类型 1：手机/平板，2：个人计算机，3：联网电视 4：手机，5：平板，6：联网装置，7：机顶盒(所有手机端全部使用类型 4)
NSInteger KCSSTDeviceType(void);

/// 设备的语言设置
NSString * KCSSTDeviceLanguage(void);

/// 横屏竖屏。0：竖屏，1：横屏
NSString * KCSSTDeviceOrientation(void);

/// 电池电量
int KCSSTDeviceBattery(void);

/// 设备是否越狱
BOOL KCSSTDeviceJailbroken(void);

/// 设备UUID
NSString * KCSSTDeviceUUID(void);

/// 设备cpu类型
int KCSSTDeviceCPUType(void);

/// 设备cpu子类型
int KCSSTDeviceCPUSubType(void);

@interface CSSDeviceInfoTool : NSObject

/// Get device model, may be nil
+ (NSString *)deviceModel;

/// Get raw device model
+ (NSString *)rawDeviceModel;

/// Get device PPI, defalut is 326 if can not match
+ (NSInteger)devicePPI;

/// Whether effective IP
+ (BOOL)isValidatIP:(NSString *)ipAddress;

/// Obtain IP collection
+ (NSDictionary *)getIPAddresses;

+ (BOOL)isBeingDebugged;

+ (BOOL)isPirated;

+ (NSString *)wifiBSSID;

+ (NSString *)wifiSSID;

+ (NSString *)md5WithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
