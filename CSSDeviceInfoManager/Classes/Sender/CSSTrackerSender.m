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

@implementation CSSTrackerSender

/**
 上报启动列表信息
 */
+ (void)sendStartList{
    double machineId = [self machineId];
    if (machineId <= 0) {
        return;
    }
    NSMutableDictionary *parame = [NSMutableDictionary dictionary];
    [parame setValue:KCSSTAPPBundleID() forKey:@"packageName"];
    [parame setValue:@(machineId) forKey:@"machineId"];
    [parame setValue:KCSSTDateString([NSDate date], @"yyyy-MM-dd HH:mm:ss") forKey:@"startTime"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@[parame] options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *aeskey = KCSSTRandomStringOfLength(16);
    NSString *aesContent = KCSSTAESEncryptString(jsonString, aeskey);
    
    NSString *aeskeyOfRSA = [CSSEncryptRSA encryptString:aeskey publicKey:@"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC9AnMx0xJR5Oy/7k0MPedEsYLv3U3iRue/+GyqBEH4rQB6rKp54NeKr8B5kZWx0KvRjlnEyz44pMc495ZTsr2gJwjPRPIUVfmLQuB6qXOngf5O2E5X9YpXPKURi2UWzpVabHiD1nD7tJoyE8HMYCa7zQOaG45oJOXLBOPpFdppPQIDAQAB"];
    
    if (kStringIsEmpty(aesContent) || kStringIsEmpty(aeskeyOfRSA)) {
        return;
    }
    
    // 转成 @"jsons=XXXXXXX"的字符串方式,用formdata上传
    NSDictionary *contentDic = @{@"content":aesContent, @"key":aeskeyOfRSA, @"terminal": @"ios",@"machineId":[NSString stringWithFormat:@"%f",machineId]};
    NSData *contentJsonData = [NSJSONSerialization dataWithJSONObject:contentDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *base64ContentJsonString = [contentJsonData base64EncodedStringWithOptions:0];
    NSString *inputString = [@"jsons=" stringByAppendingFormat:@"%@", base64ContentJsonString];
    NSData *inputData = [inputString dataUsingEncoding:NSUTF8StringEncoding];
    
    [[CSSNetworkClient css_sharedClient] POST:@"/log/strlog.json" data:inputData headers:@{@"Content-Type":@"application/x-www-form-urlencoded"} completion:^(CSSHTTPOperation *operation, id result, NSError *error) {
        
    }];
    
}

+ (void)provingMachineIdWithParame:(NSDictionary *)parame {
    double machineId = [self machineId];
    if (machineId > 0) {
        //本地已存在machineId
        [self sendStartList];
        return;
    }
    
    @weakify(self);
    [[CSSNetworkClient css_sharedClient] POST:@"/log/malog.json" parameters:parame completion:^(CSSHTTPOperation *operation, id result, NSError *error) {
        @strongify(self);
        BOOL success = [[result objectOrNilForKey:@"success"] boolValue];
        NSLog(@"success:%d",success);
        if (success) {
            double resultMachineId = [[result objectOrNilForKey:@"data"] doubleValue];
            // 缓存机器码到本地
            [[NSUserDefaults standardUserDefaults] setDouble:resultMachineId forKey:kCacheMachineId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //发送启动列表
            [self sendStartList];
        } else {
            //
        }
    }];
}

+ (double)machineId{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kCacheMachineId];
}

@end
