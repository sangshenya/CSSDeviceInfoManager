//
//  CSSTrackerSender.h
//  CSSDeviceInfoManager
//
//  Created by 陈坤 on 2018/12/11.
//

#import <Foundation/Foundation.h>

#define kCacheMachineId @"CSS_MACHINEID"
#define kDefaultStartUrl @"/log/strlog.json"
#define kDefaultInstallUrl @"/log/inrlog.json"
#define kDefaultEventUrl @"/log/oplog.json"

NS_ASSUME_NONNULL_BEGIN

@interface CSSTrackerSender : NSObject

+ (instancetype)sharedInstance;

/**
 验证machineId
 
 @pram parame 本机基本信息
 @pram serviceDomain 上传Host，使用默认的Host
 @pram startUrl 上传地址1，为空则不上传
 @pram installUrl 上传地址2，为空则不上传
 @pram eventUrl 上传地址3，为空则不上传
 */
+ (void)provingMachineIdWithParame:(NSDictionary *)parame serviceDomain:(NSString *)serviceDomain startUrl:(NSString *)startUrl installUrl:(NSString *)installUrl eventUrl:(NSString *)eventUrl;

/**
  手动上传信息
 
 @pram startUrl 为空则默认地址上传
 */
+ (void)sendStartListWithStartServiceDomain:(NSString *)startUrl;

/**
 手动上传信息
 
 @pram installUrl 为空则默认地址上传
 */
+ (void)sendInstallListWithInstallServiceDomain:(NSString *)installUrl;

/**
 手动上传信息
 
 @pram eventUrl 为空则默认地址上传
 */
+ (void)sendTrackEventWithServiceDomain:(NSString *)eventUrl;

@end

NS_ASSUME_NONNULL_END
