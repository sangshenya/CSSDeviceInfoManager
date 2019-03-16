//
//  CSSTrackerEventModel.m
//  CSSDeviceInfoManager
//
//  Created by 陈坤 on 2019/3/16.
//

#import "CSSTrackerEventModel.h"
#import <CSSDeviceInfoTool/CSSDeviceInfoTool.h>

@implementation CSSTrackerEventModel

- (int)machineType {
    return 2;
}

- (NSString *)packageName{
    return KCSSTAPPBundleID();
}

- (NSString *)versionNo {
    return KCSSTAPPVersion();
}

@end
