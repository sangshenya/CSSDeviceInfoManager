//
//  CSSDeviceInfoTool.m
//  CSSDeviceInfoTool
//
//  Created by 陈坤 on 2018/12/4.
//

#import "CSSDeviceInfoTool.h"
#import <CSSKit/CSSMacros.h>
#import <AdSupport/ASIdentifierManager.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CommonCrypto/CommonDigest.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <netinet/in.h>
#import <sys/sysctl.h>
#import <sys/stat.h>
#import <mach/mach.h>
#import <mach/machine.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

static NSString *const KCSSTDirectoryName = @"com.ecook.tracker";

static inline CTTelephonyNetworkInfo * KCSSTTelephonyNetworkInfo() {
    static CTTelephonyNetworkInfo *networkInfo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    });
    return networkInfo;
}

NSString * KCSSTIMSI() {
#if TARGET_OS_SIMULATOR
    return nil;
#else
    CTTelephonyNetworkInfo *telephonyInfo = KCSSTTelephonyNetworkInfo();
    CTCarrier *carrier = [telephonyInfo subscriberCellularProvider];
    NSString *mobileNetworkCode = [carrier mobileNetworkCode];
    NSString *mobileCountryCode = [carrier mobileCountryCode];
    if (!mobileNetworkCode || mobileCountryCode.length <= 0) {
        return nil;
    }
    if (!mobileCountryCode || mobileCountryCode.length <= 0) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@%@",mobileCountryCode, mobileNetworkCode];
#endif
}

NSString *KCSSTMCC() {
#if TARGET_OS_SIMULATOR
    return nil;
#else
    CTTelephonyNetworkInfo *telephonyInfo = KCSSTTelephonyNetworkInfo();
    CTCarrier *carrier = [telephonyInfo subscriberCellularProvider];
    NSString *mobileCountryCode = [carrier mobileCountryCode];
    return mobileCountryCode;
#endif
}

NSString * KCSSTNetworkType() {
    static SCNetworkReachabilityRef ref;
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct sockaddr_in zero_addr;
        bzero(&zero_addr, sizeof(zero_addr));
        zero_addr.sin_len = sizeof(zero_addr);
        zero_addr.sin_family = AF_INET;
        ref = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zero_addr);
        
        dic = @{CTRadioAccessTechnologyGPRS : @"2G",  // 2.5G   171Kbps
                CTRadioAccessTechnologyEdge : @"2G",  // 2.75G  384Kbps
                CTRadioAccessTechnologyWCDMA : @"3G", // 3G     3.6Mbps/384Kbps
                CTRadioAccessTechnologyHSDPA : @"3G", // 3.5G   14.4Mbps/384Kbps
                CTRadioAccessTechnologyHSUPA : @"3G", // 3.75G  14.4Mbps/5.76Mbps
                CTRadioAccessTechnologyCDMA1x : @"3G", // 2.5G
                CTRadioAccessTechnologyCDMAEVDORev0 : @"3G",
                CTRadioAccessTechnologyCDMAEVDORevA : @"3G",
                CTRadioAccessTechnologyCDMAEVDORevB : @"3G",
                CTRadioAccessTechnologyeHRPD : @"3G",
                CTRadioAccessTechnologyLTE : @"4G"}; // LTE:3.9G 150M/75M  LTE-Advanced:4G 300M/150M
    });
    
    SCNetworkReachabilityFlags flags = 0;
    SCNetworkReachabilityGetFlags(ref, &flags);
    
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        return @"";
    }
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
        (flags & kSCNetworkReachabilityFlagsTransientConnection)) {
        return @"";
    }
    
    if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
        CTTelephonyNetworkInfo *networkStatus = KCSSTTelephonyNetworkInfo();  //创建一个
        NSString *currentStatus = networkStatus.currentRadioAccessTechnology; //获取当前网络描述
        
        if (kStringIsEmpty(currentStatus)) {
            return @"";
        }
        NSString *currentType = dic[currentStatus];
        if (kStringIsEmpty(currentType)) {
            return @"";
        }
        return currentType;
    }
    
    return @"wifi";
}

NSString *KCSSTNetworkIP(BOOL preferIPv4) {
#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [CSSDeviceInfoTool getIPAddresses];
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         //筛选出IP地址格式
         if([CSSDeviceInfoTool isValidatIP:address]) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

BOOL KCSSTNetworkAgent(void) {
    CFDictionaryRef proxySettings = CFNetworkCopySystemProxySettings();
    NSDictionary *dictProxy = (__bridge_transfer id)proxySettings;
    
    return [[dictProxy objectForKey:@"HTTPEnable"] boolValue];
}

NSString * KCSSTSystemVersion() {
    static NSString *version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [UIDevice currentDevice].systemVersion;
    });
    return version;
}

NSString * KCSSTIDFA() {
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    if (kStringIsEmpty(idfa)) {
        return @"";
    }
    return idfa;
}

NSString * KCSSTIDFV(void) {
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    if (kStringIsEmpty(idfv)) {
        return @"";
    }
    return idfv;
}

#define kOpenUDIDErrorNone          0
#define kOpenUDIDErrorOptedOut      1
#define kOpenUDIDErrorCompromised   2
static NSString * kOpenUDIDSessionCache = nil;
static NSString * const kOpenUDIDDescription = @"OpenUDID_with_iOS6_Support";
static NSString * const kOpenUDIDKey = @"OpenUDID";
static NSString * const kOpenUDIDSlotKey = @"OpenUDID_slot";
static NSString * const kOpenUDIDAppUIDKey = @"OpenUDID_appUID";
static NSString * const kOpenUDIDTSKey = @"OpenUDID_createdTS";
static NSString * const kOpenUDIDOOTSKey = @"OpenUDID_optOutTS";
static NSString * const kOpenUDIDDomain = @"org.OpenUDID";
static NSString * const kOpenUDIDSlotPBPrefix = @"org.OpenUDID.slot.";
static int const kOpenUDIDRedundancySlots = 100;

NSString * KCSSTOpenUDID(NSError **error) {
    if (kOpenUDIDSessionCache!=nil) {
        if (error!=nil)
            *error = [NSError errorWithDomain:kOpenUDIDDomain
                                         code:kOpenUDIDErrorNone
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"OpenUDID in cache from first call",@"description", nil]];
        return kOpenUDIDSessionCache;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString * appUID = [defaults objectForKey:kOpenUDIDAppUIDKey];
    if(appUID == nil)
    {
        // generate a new uuid and store it in user defaults
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        appUID = (NSString *) CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
        CFRelease(uuid);
    }
    
    NSString* openUDID = nil;
    NSString* myRedundancySlotPBid = nil;
    NSDate* optedOutDate = nil;
    BOOL optedOut = NO;
    BOOL saveLocalDictToDefaults = NO;
    BOOL isCompromised = NO;
    
    id localDict = [defaults objectForKey:kOpenUDIDKey];
    if ([localDict isKindOfClass:[NSDictionary class]]) {
        localDict = [NSMutableDictionary dictionaryWithDictionary:localDict]; // we might need to set/overwrite the redundancy slot
        openUDID = [localDict objectForKey:kOpenUDIDKey];
        myRedundancySlotPBid = [localDict objectForKey:kOpenUDIDSlotKey];
        optedOutDate = [localDict objectForKey:kOpenUDIDOOTSKey];
        optedOut = optedOutDate!=nil;
    }
    
    NSString* availableSlotPBid = nil;
    NSMutableDictionary* frequencyDict = [NSMutableDictionary dictionaryWithCapacity:kOpenUDIDRedundancySlots];
    for (int n=0; n<kOpenUDIDRedundancySlots; n++) {
        NSString* slotPBid = [NSString stringWithFormat:@"%@%d",kOpenUDIDSlotPBPrefix,n];
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        UIPasteboard* slotPB = [UIPasteboard pasteboardWithName:slotPBid create:NO];
#else
        NSPasteboard* slotPB = [NSPasteboard pasteboardWithName:slotPBid];
#endif
        if (slotPB==nil) {
            if (availableSlotPBid==nil) availableSlotPBid = slotPBid;
        } else {
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
            id item = [slotPB dataForPasteboardType:kOpenUDIDDomain];
#else
            id item = [slotPB dataForType:kOpenUDIDDomain];
#endif
            if (item) {
                @try {
                    item = [NSKeyedUnarchiver unarchiveObjectWithData:item];
                } @catch (NSException *exception) {
                    item = nil;
                }
            }
            NSDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:(item == nil || [item isKindOfClass:[NSDictionary class]]) ? item : nil];
            
            NSString* oudid = [dict objectForKey:kOpenUDIDKey];
            if (oudid==nil) {
                if (availableSlotPBid==nil) availableSlotPBid = slotPBid;
            } else {
                int count = [[frequencyDict valueForKey:oudid] intValue];
                [frequencyDict setObject:[NSNumber numberWithInt:++count] forKey:oudid];
            }
            NSString* gid = [dict objectForKey:kOpenUDIDAppUIDKey];
            if (gid!=nil && [gid isEqualToString:appUID]) {
                myRedundancySlotPBid = slotPBid;
                if (optedOut) {
                    optedOutDate = [dict objectForKey:kOpenUDIDOOTSKey];
                    optedOut = optedOutDate!=nil;
                }
            }
        }
    }
    
    NSArray* arrayOfUDIDs = [frequencyDict keysSortedByValueUsingSelector:@selector(compare:)];
    NSString* mostReliableOpenUDID = (arrayOfUDIDs!=nil && [arrayOfUDIDs count]>0)? [arrayOfUDIDs lastObject] : nil;
    
    if (openUDID==nil) {
        if (mostReliableOpenUDID==nil) {
            NSString *temp_openUDID = nil;
            if (temp_openUDID == nil) {
                CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
                CFStringRef cfstring = CFUUIDCreateString(kCFAllocatorDefault, uuid);
                const char *cStr = CFStringGetCStringPtr(cfstring,CFStringGetFastestEncoding(cfstring));
                unsigned char result[16];
                CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
                CFRelease(uuid);
                CFRelease(cfstring);
                
                temp_openUDID = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%08lx",
                                 result[0], result[1], result[2], result[3],
                                 result[4], result[5], result[6], result[7],
                                 result[8], result[9], result[10], result[11],
                                 result[12], result[13], result[14], result[15],
                                 (unsigned long)(arc4random() % NSUIntegerMax)];
            }
            openUDID = temp_openUDID;
        } else {
            openUDID = mostReliableOpenUDID;
        }
        
        if (localDict==nil) {
            localDict = [NSMutableDictionary dictionaryWithCapacity:4];
            [localDict setObject:openUDID forKey:kOpenUDIDKey];
            [localDict setObject:appUID forKey:kOpenUDIDAppUIDKey];
            [localDict setObject:[NSDate date] forKey:kOpenUDIDTSKey];
            if (optedOut) [localDict setObject:optedOutDate forKey:kOpenUDIDTSKey];
            saveLocalDictToDefaults = YES;
        }
    }
    else {
        if (mostReliableOpenUDID!=nil && ![mostReliableOpenUDID isEqualToString:openUDID])
            isCompromised = YES;
    }
    
    if (availableSlotPBid!=nil && (myRedundancySlotPBid==nil || [availableSlotPBid isEqualToString:myRedundancySlotPBid])) {
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        UIPasteboard* slotPB = [UIPasteboard pasteboardWithName:availableSlotPBid create:YES];
        [slotPB setPersistent:YES];
#else
        NSPasteboard* slotPB = [NSPasteboard pasteboardWithName:availableSlotPBid];
#endif
        
        if (localDict) {
            [localDict setObject:availableSlotPBid forKey:kOpenUDIDSlotKey];
            saveLocalDictToDefaults = YES;
        }
        
        if (openUDID && localDict)
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
            [slotPB setData:[NSKeyedArchiver archivedDataWithRootObject:localDict] forPasteboardType:kOpenUDIDDomain];
#else
        [slotPB setData:[NSKeyedArchiver archivedDataWithRootObject:localDict] forType:kOpenUDIDDomain];
#endif
    }
    
    if (localDict && saveLocalDictToDefaults)
        [defaults setObject:localDict forKey:kOpenUDIDKey];
    
    if (optedOut) {
        if (error!=nil) *error = [NSError errorWithDomain:kOpenUDIDDomain
                                                     code:kOpenUDIDErrorOptedOut
                                                 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Application with unique id %@ is opted-out from OpenUDID as of %@",appUID,optedOutDate],@"description", nil]];
        
        kOpenUDIDSessionCache = [NSString stringWithFormat:@"%040x",0];
        return kOpenUDIDSessionCache;
    }
    
    if (error!=nil) {
        if (isCompromised)
            *error = [NSError errorWithDomain:kOpenUDIDDomain
                                         code:kOpenUDIDErrorCompromised
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Found a discrepancy between stored OpenUDID (reliable) and redundant copies; one of the apps on the device is most likely corrupting the OpenUDID protocol",@"description", nil]];
        else
            *error = [NSError errorWithDomain:kOpenUDIDDomain
                                         code:kOpenUDIDErrorNone
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"OpenUDID succesfully retrieved",@"description", nil]];
    }
    kOpenUDIDSessionCache = openUDID;
    return kOpenUDIDSessionCache;
}

NSString * KCSSTCacheDirectory(void) {
    NSArray<NSURL *> *urlPaths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *urlPath = [urlPaths[0] absoluteString];
    urlPath = [urlPath substringFromIndex:7]; //remove prefix: @"file://"
    
    NSString *sdkDirectory = [NSString stringWithFormat:@"%@%@", urlPath, KCSSTDirectoryName];
    return [NSString stringWithFormat:@"%@/%@", sdkDirectory, @"cache"];
}

NSString * KCSSTAPPBundleID(void) {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

NSString * KCSSTAPPVersion(void) {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

NSString * KCSSTDateString(NSDate *date, NSString *format) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setLocale:[NSLocale currentLocale]];
    return [formatter stringFromDate:date];
}

NSString * KCSSTWebviewUA() {
    static NSString *userAgent;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 保证在主线程中初始化
        if ([NSThread isMainThread]) {
            UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectZero];
            userAgent = [webview stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        } else {
            dispatch_semaphore_t signal = dispatch_semaphore_create(1);
            dispatch_sync(dispatch_get_main_queue(), ^{
                UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectZero];
                userAgent = [webview stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
                dispatch_semaphore_signal(signal);
            });
        }
    });
    return userAgent;
}

NSString *KCSSTRandomStringOfLength(NSInteger length) {
    static NSString *strTable = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (NSInteger i = 0; i < length; i ++) {
        [randomString appendFormat:@"%C", [strTable characterAtIndex:(NSInteger)arc4random_uniform((uint32_t)[strTable length])]];
    }
    return randomString;
}

NSInteger KCSSTDeviceType(void) {
    UIUserInterfaceIdiom faceIdiom = [UIDevice currentDevice].userInterfaceIdiom;
    NSInteger device = -1;
    if (faceIdiom == UIUserInterfaceIdiomPad) {
        device = 5;
    } else if (faceIdiom == UIUserInterfaceIdiomPhone) {
        device = 4;
    }
    
    if (@available(iOS 9.0, *)) {
        if (faceIdiom == UIUserInterfaceIdiomTV) {
            device = 3;
        }
    }
    return device;
}

NSString * KCSSTDeviceLanguage(void) {
    NSString *language = [NSLocale preferredLanguages].firstObject;
    if (kStringIsEmpty(language)) {
        return @"";
    }
    return language;
}

NSString * KCSSTDeviceOrientation(void) {
    NSString *orientation = @"1";
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        orientation = @"0";
    }
    return orientation;
}

int KCSSTDeviceBattery(void) {
    float battery = [[UIDevice currentDevice] batteryLevel];
    int realBattery =  (int)(battery * 100);
    return realBattery;
}

BOOL KCSSTDeviceJailbroken(void) {
#if TARGET_OS_SIMULATOR
    return NO;
#endif
    
    NSArray *paths = @[@"/Applications/Cydia.app",
                       @"/private/var/lib/apt/",
                       @"/private/var/lib/cydia",
                       @"/private/var/stash"];
    for (NSString *path in paths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) return YES;
    }
    
    FILE *bash = fopen("/bin/bash", "r");
    if (bash != NULL) {
        fclose(bash);
        return YES;
    }
    
    //攻击者可能会hook NSFileManager 的方法，让你的想法不能如愿。
    //那么，你可以回避 NSFileManager，使用stat系列函数检测Cydia等工具
    struct stat stat_info;
    if (0 == stat("Applications/Cydia.app", &stat_info)) {
        return YES;
    }
    
    NSString *path = [NSString stringWithFormat:@"/private/%@", KCSSTDeviceUUID()];
    if ([@"test" writeToFile : path atomically : YES encoding : NSUTF8StringEncoding error : NULL]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        return YES;
    }
    
    return NO;
}

NSString * KCSSTDeviceUUID(void) {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (__bridge_transfer NSString *)string;
}

/// 设备cpu类型
int KCSSTDeviceCPUType(void) {
    size_t size;
    cpu_type_t type;
    size = sizeof(type);
    sysctlbyname("hw.cputype", &type, &size, NULL, 0);
    
    return type;
}

/// 设备cpu子类型
int KCSSTDeviceCPUSubType(void) {
    size_t size;
    cpu_subtype_t subtype;
    size = sizeof(subtype);
    sysctlbyname("hw.cpusubtype", &subtype, &size, NULL, 0);
    
    return subtype;
}

@implementation CSSDeviceInfoTool

+ (NSString *)rawDeviceModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

+ (NSString *)deviceModel {
    NSString *platform = [self rawDeviceModel];
    
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6 (A1549/A1586)";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone10,1"])   return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,4"])   return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([platform isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G (A1491)";
    
    if ([platform isEqualToString:@"i386"])         return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"iPhone Simulator";
    
    return platform;
}

+ (NSInteger)devicePPI {
    NSString *platform = [self deviceModel];
    
    if ([platform isEqualToString:@"iPhone 2G (A1203)"])                    return 163;
    if ([platform isEqualToString:@"iPhone 3G (A1241/A1324)"])              return 163;
    if ([platform isEqualToString:@"iPhone 3GS (A1303/A1325)"])             return 163;
    if ([platform isEqualToString:@"iPhone 4 (A1332)"])                     return 326;
    if ([platform isEqualToString:@"iPhone 4 (A1332)"])                     return 326;
    if ([platform isEqualToString:@"iPhone 4 (A1349)"])                     return 326;
    if ([platform isEqualToString:@"iPhone 4S (A1387/A1431)"])              return 326;
    if ([platform isEqualToString:@"iPhone 5 (A1428)"])                     return 326;
    if ([platform isEqualToString:@"iPhone 5 (A1429/A1442)"])               return 326;
    if ([platform isEqualToString:@"iPhone 5c (A1456/A1532)"])              return 326;
    if ([platform isEqualToString:@"iPhone 5c (A1507/A1516/A1526/A1529)"])  return 326;
    if ([platform isEqualToString:@"iPhone 5s (A1453/A1533)"])              return 326;
    if ([platform isEqualToString:@"iPhone 5s (A1457/A1518/A1528/A1530)"])  return 326;
    if ([platform isEqualToString:@"iPhone 6 Plus (A1522/A1524)"])          return 401;
    if ([platform isEqualToString:@"iPhone 6 (A1549/A1586)"])               return 326;
    if ([platform isEqualToString:@"iPhone 6s"])                            return 306;
    if ([platform isEqualToString:@"iPhone 6s Plus"])                       return 401;
    if ([platform isEqualToString:@"iPhone SE"])                            return 306;
    if ([platform isEqualToString:@"iPhone 7 Plus"])                        return 401;
    if ([platform isEqualToString:@"iPhone 7"])                             return 326;
    if ([platform isEqualToString:@"iPhone10,1"])                           return 326;
    if ([platform isEqualToString:@"iPhone10,4"])                           return 326;
    if ([platform isEqualToString:@"iPhone10,2"])                           return 401;
    if ([platform isEqualToString:@"iPhone10,5"])                           return 401;
    if ([platform isEqualToString:@"iPhone10,3"])                           return 458;
    if ([platform isEqualToString:@"iPhone10,6"])                           return 458;
    
    if ([platform isEqualToString:@"iPod Touch 1G (A1213)"])                return 326;
    if ([platform isEqualToString:@"iPod Touch 2G (A1288)"])                return 326;
    if ([platform isEqualToString:@"iPod Touch 3G (A1318)"])                return 326;
    if ([platform isEqualToString:@"iPod Touch 4G (A1367)"])                return 326;
    if ([platform isEqualToString:@"iPod Touch 5G (A1421/A1509)"])          return 326;
    
    if ([platform isEqualToString:@"iPad 1G (A1219/A1337)"])                return 326;
    
    if ([platform isEqualToString:@"iPad 2 (A1395)"])                       return 326;
    if ([platform isEqualToString:@"iPad 2 (A1396)"])                       return 326;
    if ([platform isEqualToString:@"iPad 2 (A1397)"])                       return 326;
    if ([platform isEqualToString:@"iPad 2 (A1395+New Chip)"])              return 326;
    if ([platform isEqualToString:@"iPad Mini 1G (A1432)"])                 return 326;
    if ([platform isEqualToString:@"iPad Mini 1G (A1454)"])                 return 326;
    if ([platform isEqualToString:@"iPad Mini 1G (A1455)"])                 return 326;
    
    if ([platform isEqualToString:@"iPad 3 (A1416)"])                       return 326;
    if ([platform isEqualToString:@"iPad 3 (A1403)"])                       return 326;
    if ([platform isEqualToString:@"iPad 3 (A1430)"])                       return 326;
    if ([platform isEqualToString:@"iPad 4 (A1458)"])                       return 326;
    if ([platform isEqualToString:@"iPad 4 (A1459)"])                       return 326;
    if ([platform isEqualToString:@"iPad 4 (A1460)"])                       return 326;
    
    if ([platform isEqualToString:@"iPad Air (A1474)"])                     return 326;
    if ([platform isEqualToString:@"iPad Air (A1475)"])                     return 326;
    if ([platform isEqualToString:@"iPad Air (A1476)"])                     return 326;
    if ([platform isEqualToString:@"iPad Mini 2G (A1489)"])                 return 326;
    if ([platform isEqualToString:@"iPad Mini 2G (A1490)"])                 return 326;
    if ([platform isEqualToString:@"iPad Mini 2G (A1491)"])                 return 326;
    
    if ([platform isEqualToString:@"iPhone Simulator"])                     return 326;
    if ([platform isEqualToString:@"iPhone Simulator"])                     return 326;
    
    return 326;
}

+ (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            return YES;
        }
    }
    return NO;
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

/// 越狱
+ (BOOL)isPirated {
#if TARGET_OS_SIMULATOR
    return YES;
#endif
    
    if (getgid() <= 10) return YES; // process ID shouldn't be root
    
    if ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"SignerIdentity"]) {
        return YES;
    }
    
    if (![self __fileExistInMainBundle:@"_CodeSignature"]) {
        return YES;
    }
    
    if (![self __fileExistInMainBundle:@"SC_Info"]) {
        return YES;
    }
    
    //if someone really want to crack your app, this method is useless..
    //you may change this method's name, encrypt the code and do more check..
    return NO;
}

+ (BOOL)__fileExistInMainBundle:(NSString *)name {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *path = [NSString stringWithFormat:@"%@/%@", bundlePath, name];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)isBeingDebugged {
    size_t size = sizeof(struct kinfo_proc);
    struct kinfo_proc info;
    int ret = 0, name[4];
    memset(&info, 0, sizeof(struct kinfo_proc));
    
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID; name[3] = getpid();
    
    if (ret == (sysctl(name, 4, &info, &size, NULL, 0))) {
        return ret != 0;
    }
    return (info.kp_proc.p_flag & P_TRACED) ? YES : NO;
}

+ (NSString *)wifiBSSID {
    NSString *bssid = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"BSSID"]) {
            bssid = info[@"BSSID"];
        }
    }
    
    if (kStringIsEmpty(bssid)) return @"";
    return bssid;
}

+ (NSString *)wifiSSID {
    NSString *ssid = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"SSID"]) {
            ssid = info[@"SSID"];
        }
    }
    
    if (kStringIsEmpty(ssid)) return @"";
    return ssid;
}

+ (NSString *)md5WithString:(NSString *)string{
    const char *cStr = [string UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
#pragma mark - 磁盘总内存
+ (int64_t)getTotalDiskSpace {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space =  [[attrs objectForKey:NSFileSystemSize] longLongValue];
    if (space < 0) space = -1;
    return space;
}

#pragma mark - 磁盘使用空间
+ (int64_t)getUsedDiskSpace {
    int64_t totalDisk = [self getTotalDiskSpace];
    int64_t freeDisk = [self getFreeDiskSpace];
    if (totalDisk < 0 || freeDisk < 0) return -1;
    int64_t usedDisk = totalDisk - freeDisk;
    if (usedDisk < 0) usedDisk = -1;
    return usedDisk;
}
#pragma mark - 磁盘空闲空间

+ (int64_t)getFreeDiskSpace {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space =  [[attrs objectForKey:NSFileSystemFreeSize] longLongValue];
    if (space < 0) space = -1;
    return space;
}

@end
