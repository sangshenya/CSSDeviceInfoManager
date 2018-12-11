//
//  MCLocationManager.h
//  CSSDeviceInfoTool
//
//  Created by 陈坤 on 2018/12/4.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MCLocationManager : NSObject <CLLocationManagerDelegate>

/// 国家, e.g.CN
@property (nonatomic, copy) NSString *ISOcountryCode;
/// 纬度
@property (nonatomic, assign) CGFloat latitude;
/// 经度
@property (nonatomic, assign) CGFloat longitude;
/// 坐标类型 1：全球卫星定位系统坐标系，2：国家测绘局坐标系，3：百度坐标系，4：其他坐标系
@property (nonatomic, assign) int coordinate_type;
/// 获取坐标的时间戳, 单位 ms
@property (nonatomic, assign) double coordinate_time;
/// 坐标精度, 单位 m
@property (nonatomic, assign) double coordinate_accuracy;

+ (instancetype)sharedInstance;

- (void)locateByGpsWithAuthorizationJudge:(BOOL)authorizationJudge;

@end

NS_ASSUME_NONNULL_END
