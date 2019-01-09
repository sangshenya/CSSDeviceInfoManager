//
//  CSSDeviceInfoManager.m
//  Pods
//
//  Created by 陈坤 on 2018/12/10.
//

#import "CSSDeviceInfoManager.h"
#import <MCLocationManager/MCLocationManager.h>
#import <CSSKit/CSSMacros.h>
#import <CSSKit/CSSCGUtilities.h>
#import <CSSDeviceInfoTool/CSSDeviceInfoTool.h>
#import <CSSKit/NSObject+Addition.h>
#import <CSSNetworkClient/CSSNetworkClient+Singletop.h>
#import <CSSKit/NSDictionary+Addition.h>
#import "CSSTrackerSender.h"

#define kCSSTParameterUnknown @"unknown"

@implementation CSSDeviceInfoManager

+ (instancetype)sharedInstance{
    static CSSDeviceInfoManager *deviceManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deviceManager = [[CSSDeviceInfoManager alloc] init];
    });
    return deviceManager;
}

- (id)init {
    if (self = [super init]) {
        _screenWidth = kScreenWidth;
        _screenHeight = kScreenHeight;
        _ua = KCSSTWebviewUA(); //耗时操作
        _imsi = kStringIsEmpty(KCSSTIMSI()) ? kCSSTParameterUnknown : KCSSTIMSI();
        _machineType = 2;
        _sdScreendpi = [CSSDeviceInfoTool devicePPI];
        _osVersion = KCSSTSystemVersion();
        _vendor = @"apple";
        _modelNo = [CSSDeviceInfoTool deviceModel];
        _rawModelNo = [CSSDeviceInfoTool rawDeviceModel];
        _idfa = KCSSTIDFA();
        _openUdid = KCSSTOpenUDID(nil); //耗时操作
        _deviceType = KCSSTDeviceType();
        _idfv = KCSSTIDFV();
        _language = KCSSTDeviceLanguage();
        _isroot = KCSSTDeviceJailbroken() ? 1 : 0;
        _mcc = KCSSTMCC();
        _cpuType = KCSSTDeviceCPUType();
        _cpuSubtype = KCSSTDeviceCPUSubType();
        
        NSMutableDictionary *param = [self css_toDic];
        [param setValue:[NSNumber numberWithFloat:([self getTotalDiskSpace]/1024/1024.0)] forKey:@"AllDiskSpace"];
        [param setValue:[NSNumber numberWithFloat:([self getUsedDiskSpace]/1024/1024.0)] forKey:@"UserDiskSpace"];
        [param setValue:[NSNumber numberWithFloat:([self getFreeDiskSpace]/1024/1024.0)] forKey:@"FreeDiskSpace"];
//        NSLog(@"param: %@",param);
        [CSSTrackerSender provingMachineIdWithParame:param];
    }
    return self;
}

- (NSString *)networkType {
    return KCSSTNetworkType();
}


- (NSString *)lat {
    return [NSString stringWithFormat:@"%.2f", [MCLocationManager sharedInstance].latitude];
    //    return @"136.2";
}

- (NSString *)lng {
    return [NSString stringWithFormat:@"%.2f", [MCLocationManager sharedInstance].longitude];
    //    return @"46.8";
}

- (NSString *)ip {
    NSString *ip = kStringIsEmpty(KCSSTNetworkIP(YES)) ? kCSSTParameterUnknown : KCSSTNetworkIP(YES);
    return ip;
}

- (NSString *)orientation {
    return KCSSTDeviceOrientation();
}

- (int)battery {
    return KCSSTDeviceBattery();
}

- (NSString *)country {
    return [MCLocationManager sharedInstance].ISOcountryCode;
    //    return @"CN";
}

- (int)coordinateType {
    return [MCLocationManager sharedInstance].coordinate_type;
    //    return 1;
}

- (double)locaAccuracy {
    return [MCLocationManager sharedInstance].coordinate_accuracy;
    //    return 4262537523745;
}

- (double)coordTime {
    return [MCLocationManager sharedInstance].coordinate_time;
    //    return 354343453435;
}

- (NSString *)bssId {
    return [CSSDeviceInfoTool wifiBSSID];
}

- (NSString *)ssid {
    return [CSSDeviceInfoTool wifiSSID];
}

- (double)machineId{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kCacheMachineId];
}

//手机磁盘空间
// 磁盘总内存 单位:B
- (int64_t)getTotalDiskSpace{
    return [CSSDeviceInfoTool getTotalDiskSpace];
}

// 磁盘使用空间 单位:B
- (int64_t)getUsedDiskSpace{
    return [CSSDeviceInfoTool getUsedDiskSpace];
}

// 空闲空间 单位:B
- (int64_t)getFreeDiskSpace{
    return [CSSDeviceInfoTool getFreeDiskSpace];
}


@end
