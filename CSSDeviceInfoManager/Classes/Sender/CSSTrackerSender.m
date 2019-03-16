//
//  CSSTrackerSender.m
//  CSSDeviceInfoManager
//
//  Created by 陈坤 on 2018/12/11.
//

#import "CSSTrackerSender.h"
#import <CSSNetworkClient/CSSNetworkClient+Singletop.h>
#import <CSSDeviceInfoTool/CSSDeviceInfoTool.h>
#import <CSSDeviceInfoTool/CSSEncryptAES.h>
#import <CSSDeviceInfoTool/CSSEncryptRSA.h>
#import <CSSKit/CSSMacros.h>
#import <CSSKit/NSDictionary+Addition.h>
#import "UIApplication+Tracker.h"
#import "UIViewController+Tracker.h"
#import "CSSTrackerPersistence.h"

@interface CSSTrackerSender ()

@property (nonatomic, copy) NSString *machineUrlString;
@property (nonatomic, copy) NSString *startUrlString;
@property (nonatomic, copy) NSString *installUrlString;

@end

@implementation CSSTrackerSender

+ (NSString *)sdkVersion{
    return @"1.0.1";
}

+ (void)provingMachineIdWithParame:(NSDictionary *)parame serviceDomain:(NSString *)serviceDomain startUrl:(NSString *)startUrl installUrl:(NSString *)installUrl eventUrl:(NSString *)eventUrl{
    
    double machineId = [self machineId];
    if (machineId > 0) {
        //本地已存在machineId，则上传启动列表和安装列表，不存在则请求获取machineId，成功再上传
        CSSTrackerPersistence *presistance = [CSSTrackerPersistence sharedInstance];
        presistance.machineId = [self machineId];
        [UIApplication startTracker];
        [UIViewController startTracker];
//        if (!kStringIsEmpty(eventUrl)) {
//            [self sendTrackEventWithServiceDomain:eventUrl];
//        }
        
        if (!kStringIsEmpty(startUrl)) {
            [self sendStartListWithStartServiceDomain:startUrl];
        }
        //发送启动列表
        if (!kStringIsEmpty(installUrl)) {
            [self sendInstallListWithInstallServiceDomain:installUrl];
        }
//        return;
    }
    [parame setValue:[NSNumber numberWithLongLong:(long long)machineId] forKey:@"machineId"];
    [parame setValue:[self sdkVersion] forKey:@"sdkVersion"];
    NSString *urlString = @"/log/malog.json";
    if (!kStringIsEmpty(serviceDomain)) {
        urlString = serviceDomain;
    }
    @weakify(self);
    [[CSSNetworkClient css_sharedClient] POST:urlString parameters:parame completion:^(CSSHTTPOperation *operation, id result, NSError *error) {
        @strongify(self);
        BOOL success = [[result objectOrNilForKey:@"success"] boolValue];
        if (success) {
            double resultMachineId = [[result objectOrNilForKey:@"data"] doubleValue];
            if (resultMachineId) {
                // 缓存机器码到本地
                [[NSUserDefaults standardUserDefaults] setDouble:resultMachineId forKey:kCacheMachineId];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (!kStringIsEmpty(startUrl)) {
                    [self sendStartListWithStartServiceDomain:startUrl];
                }
                //发送启动列表
                if (!kStringIsEmpty(installUrl)) {
                    [self sendInstallListWithInstallServiceDomain:installUrl];
                }
                
                CSSTrackerPersistence *presistance = [CSSTrackerPersistence sharedInstance];
                presistance.machineId = [self machineId];
                [UIApplication startTracker];
                [UIViewController startTracker];
                if (!kStringIsEmpty(eventUrl)) {
                    [self sendTrackEventWithServiceDomain:eventUrl];
                }
            }
        } else {
            //
        }
    }];
}

+ (double)machineId{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kCacheMachineId];
}

/**
 上报启动列表信息
 */
+ (void)sendStartListWithStartServiceDomain:(NSString *)startUrl {
    double machineId = [self machineId];
    if (machineId <= 0) {
        return;
    }
    
    NSMutableDictionary *parame = [NSMutableDictionary dictionary];
    
    [parame setValue:KCSSTAPPBundleID() forKey:@"packageName"];
    [parame setValue:[NSNumber numberWithLongLong:(long long)machineId] forKey:@"machineId"];
    [parame setValue:KCSSTDateString([NSDate date], @"yyyy-MM-dd HH:mm:ss") forKey:@"startTime"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@[parame] options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *dict = [self getEncryptDict:jsonString];
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    NSData *contentJsonData = [NSJSONSerialization dataWithJSONObject:contentDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *base64ContentJsonString = [contentJsonData base64EncodedStringWithOptions:0];
    NSString *inputString = [@"jsons=" stringByAppendingFormat:@"%@", base64ContentJsonString];
    inputString = [inputString stringByAppendingFormat:@"&terminal=%@",@"ios"];
    inputString = [inputString stringByAppendingFormat:@"&machineId=%@",[NSString stringWithFormat:@"%lld",(long long)machineId]];
    inputString = [inputString stringByAppendingFormat:@"&sdkVersion=%@",[self sdkVersion]];
    NSData *inputData = [inputString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *urlString = kDefaultStartUrl;
    if (!kStringIsEmpty(startUrl)) {
        urlString = startUrl;
    }
    
    //
    [[CSSNetworkClient css_sharedClient] POST:urlString data:inputData headers:@{@"Content-Type":@"application/x-www-form-urlencoded"} completion:^(CSSHTTPOperation *operation, id result, NSError *error) {
        NSLog(@"hhhhhh%@,%@",result,error);
    }];
}

+ (NSDictionary *)getEncryptDict:(NSString *)jsonString{
    NSString *aeskey = KCSSTRandomStringOfLength(16);
    NSString *aesContent = KCSSTAESEncryptString(jsonString, aeskey);
    NSString *aeskeyOfRSA = [CSSEncryptRSA encryptString:aeskey publicKey:@"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC9AnMx0xJR5Oy/7k0MPedEsYLv3U3iRue/+GyqBEH4rQB6rKp54NeKr8B5kZWx0KvRjlnEyz44pMc495ZTsr2gJwjPRPIUVfmLQuB6qXOngf5O2E5X9YpXPKURi2UWzpVabHiD1nD7tJoyE8HMYCa7zQOaG45oJOXLBOPpFdppPQIDAQAB"];
    if (kStringIsEmpty(aesContent) || kStringIsEmpty(aeskeyOfRSA)) {
        return nil;
    }
    return @{@"content":aesContent, @"key":aeskeyOfRSA,@"terminal": @"ios",@"machineId":[NSString stringWithFormat:@"%f",[self machineId]]};
}

+ (void)sendInstallListWithInstallServiceDomain:(NSString *)installUrl{
    double machineId = [self machineId];
    if (machineId <= 0) {
        return;
    }
    
    NSMutableDictionary *parame = [NSMutableDictionary dictionary];
    [parame setValue:KCSSTAPPBundleID() forKey:@"packageName"];
    [parame setValue:[NSNumber numberWithLongLong:(long long)machineId]  forKey:@"machineId"];
    
    [parame setValue:KCSSTAPPBundleName() forKey:@"applyName"];
    [parame setValue:KCSSTAPPVersion() forKey:@"versionNo"];
    [parame setValue:@"unknow" forKey:@"versionName"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@[parame] options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *dict = [self getEncryptDict:jsonString];
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    NSData *contentJsonData = [NSJSONSerialization dataWithJSONObject:contentDic options:NSJSONWritingPrettyPrinted error:nil];
    //    NSString *base64ContentJsonString = [contentJsonData base64EncodedStringWithOptions:0];
    NSString *base64ContentJsonString = [contentJsonData base64EncodedStringWithOptions:0];
    NSString *inputString = [@"jsons=" stringByAppendingFormat:@"%@", base64ContentJsonString];
    inputString = [inputString stringByAppendingFormat:@"&terminal=%@",@"ios"];
    inputString = [inputString stringByAppendingFormat:@"&machineId=%@",[NSString stringWithFormat:@"%lld",(long long)machineId]];
    inputString = [inputString stringByAppendingFormat:@"&sdkVersion=%@",[self sdkVersion]];
    NSData *inputData = [inputString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *urlString = kDefaultInstallUrl;
    if (!kStringIsEmpty(installUrl)) {
        urlString = installUrl;
    }
    
    [[CSSNetworkClient css_sharedClient] POST:urlString data:inputData headers:@{@"Content-Type":@"application/x-www-form-urlencoded"} completion:^(CSSHTTPOperation *operation, id result, NSError *error) {
        NSLog(@"hhhhhh%@,%@",result,error);
    }];
}

/**
 上报用户点击行为
 */
+ (void)sendTrackEventWithServiceDomain:(NSString *)eventUrl{
    double machineId = [self machineId];
    if (machineId <= 0) {
        return;
    }
    CSSTrackerPersistence *presistance = [CSSTrackerPersistence sharedInstance];
    presistance.machineId = [self machineId];
    NSString *filePath = [presistance nextArchivedCustomEventsPath];
    if (!filePath) {
        return;
    }
    NSData *data = [presistance uploadCustomEventsDataWithPath:filePath];
    if (!data.length) {
        //TODO:描述错误
        return;
    }
    
    NSString *urlString = kDefaultEventUrl;
    if (!kStringIsEmpty(eventUrl)) {
        urlString = eventUrl;
    }
    
    [[CSSNetworkClient css_sharedClient] POST:urlString data:data headers:nil completion:^(CSSHTTPOperation *operation, id result, NSError *error) {
        if (!error) {
            NSLog(@"hhhhhh%@,%@",result,error);
            [presistance clearFile:filePath error:nil];
//            [strongSelf sendCustomEvents];
        } else {
            
        }
    }];
}


@end
