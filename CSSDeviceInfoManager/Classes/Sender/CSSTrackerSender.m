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

@interface CSSTrackerSender ()

@property (nonatomic, copy) NSString *machineUrlString;
@property (nonatomic, copy) NSString *startUrlString;
@property (nonatomic, copy) NSString *installUrlString;

@end

@implementation CSSTrackerSender

+ (NSString *)sdkVersion{
    return @"1.0.0";
}

+ (void)provingMachineIdWithParame:(NSDictionary *)parame serviceDomain:(NSString *)serviceDomain {
    
    double machineId = [self machineId];
    if (machineId > 0) {
        //本地已存在machineId，则上传启动列表和安装列表，不存在则请求获取machineId，成功再上传
        [self sendStartListWithStartServiceDomain:nil];
        [self sendInstallListWithInstallServiceDomain:nil];
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
            // 缓存机器码到本地
            [[NSUserDefaults standardUserDefaults] setDouble:resultMachineId forKey:kCacheMachineId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //发送启动列表
            [self sendStartListWithStartServiceDomain:nil];
            [self sendInstallListWithInstallServiceDomain:nil];
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
    
    NSString *urlString = @"/log/strlog.json";
    if (!kStringIsEmpty(startUrl)) {
        urlString = startUrl;
    }
    
    //
    [[CSSNetworkClient css_sharedClient] POST:urlString data:inputData headers:@{@"Content-Type":@"application/x-www-form-urlencoded"} completion:^(CSSHTTPOperation *operation, id result, NSError *error) {
        
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
    
    NSString *urlString = @"/log/inrlog.json";
    if (!kStringIsEmpty(installUrl)) {
        urlString = installUrl;
    }
    
    [[CSSNetworkClient css_sharedClient] POST:urlString data:inputData headers:@{@"Content-Type":@"application/x-www-form-urlencoded"} completion:^(CSSHTTPOperation *operation, id result, NSError *error) {
        
    }];
}

@end
