//
//  CSSDeviceInfoManager.h
//  Pods
//
//  Created by 陈坤 on 2018/12/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSSDeviceInfoManager : NSObject

@property (nonatomic, readonly, assign) CGFloat screenWidth; ///< 屏幕宽度
@property (nonatomic, readonly, assign) CGFloat screenHeight; ///< 屏幕高度
@property (nonatomic, readonly, copy) NSString *imsi; ///< 运营商
@property (nonatomic, readonly, assign) double machineId; ///< machineId, iOS
@property (nonatomic, readonly, assign) int machineType; ///< 机器类型, iOS
@property (nonatomic, readonly, copy) NSString *ua; ///< 浏览器的user-agent
@property (nonatomic, readonly, copy) NSString *networkType; ///< 网络类型
@property (nonatomic, readonly, assign) NSInteger sdScreendpi; ///< 屏幕密度
@property (nonatomic, readonly, copy) NSString *osVersion; ///< 操作系统版本
@property (nonatomic, readonly, copy) NSString *vendor; ///< 手机生产厂商
@property (nonatomic, readonly, copy) NSString *modelNo; ///< 手机型号(转化过后)
@property (nonatomic, readonly, copy) NSString *rawModelNo; ///< 手机型号
@property (nonatomic, readonly, copy) NSString *idfa; ///< 广告标识符
@property (nonatomic, readonly, copy) NSString *openUdid; ///<
@property (nonatomic, readonly, copy) NSString *lat; ///< 纬度1
@property (nonatomic, readonly, copy) NSString *lng; ///< 经度1
@property (nonatomic, readonly, copy) NSString *ip; ///< ip地址1
@property (nonatomic, readonly, assign) NSInteger deviceType; ///< 设备类型, ipad,手机等1
@property (nonatomic, readonly, copy) NSString *idfv;
@property (nonatomic, readonly, copy) NSString *language; ///< 设备语言设置
@property (nonatomic, readonly, copy) NSString *orientation; ///< 横屏竖屏
@property (nonatomic, readonly, assign) int battery; ///< 电池电量
@property (nonatomic, readonly, assign) int isroot; ///< 是否越狱
@property (nonatomic, readonly, copy) NSString *country; ///< 所处国家
@property (nonatomic, readonly, assign) int coordinateType; ///< 坐标类型
@property (nonatomic, readonly, assign) double locaAccuracy; ///< 坐标精度
@property (nonatomic, readonly, assign) double coordTime; ///< 坐标经纬度时间戳
@property (nonatomic, readonly, copy) NSString *bssId; ///< wifi地址
@property (nonatomic, readonly, copy) NSString *mcc; ///< 运营商国家代码1
@property (nonatomic, readonly, copy) NSString *ssid; ///< wifi名称
@property (nonatomic, readonly, assign) int cpuType; ///< cpu类型
@property (nonatomic, readonly, assign) int cpuSubtype; ///< cpu子类型


+ (instancetype)sharedInstance;

// 磁盘总内存 单位:B
- (int64_t)getTotalDiskSpace;

// 磁盘使用空间 单位:B
- (int64_t)getUsedDiskSpace;

// 空闲空间 单位:B
- (int64_t)getFreeDiskSpace;

@end

NS_ASSUME_NONNULL_END
