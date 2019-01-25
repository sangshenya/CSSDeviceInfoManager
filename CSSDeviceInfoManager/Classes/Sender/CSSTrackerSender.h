//
//  CSSTrackerSender.h
//  CSSDeviceInfoManager
//
//  Created by 陈坤 on 2018/12/11.
//

#import <Foundation/Foundation.h>

#define kCacheMachineId @"CSS_MACHINEID"

NS_ASSUME_NONNULL_BEGIN

@interface CSSTrackerSender : NSObject

/**
 验证machineId
 */
+ (void)provingMachineIdWithParame:(NSDictionary *)parame serviceDomain:(NSString *)serviceDomain;

+ (void)sendStartListWithStartServiceDomain:(NSString *)startUrl;

+ (void)sendInstallListWithInstallServiceDomain:(NSString *)installUrl;

@end

NS_ASSUME_NONNULL_END
