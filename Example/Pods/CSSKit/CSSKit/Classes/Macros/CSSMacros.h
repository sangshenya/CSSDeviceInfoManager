//
//  CSSMacros.h
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#ifndef CSSMacros_h
#define CSSMacros_h

// 机型UI适配宏
#define kIPhoneX (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && (kScreenWidth == 375.0 && kScreenHeight == 812.0))
#define kIphoneXS (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && (kScreenWidth == 375.0 && kScreenHeight == 812.0))
#define kIphoneXR (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && (kScreenWidth == 414.0 && kScreenHeight == 896.0) && (kScreenScale == 2))
#define kIphoneXS_MAX (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && (kScreenWidth == 414.0 && kScreenHeight == 896.0) && (kScreenScale == 3))
#define kCurveScreen (kIPhoneX || kIphoneXS || kIphoneXR || kIphoneXS_MAX) // 刘海屏幕
#define kStatusBarHeight (kCurveScreen ? 44 : 20)
#define kNavBarHeight 44
#define kTopBarHeight (kStatusBarHeight + kNavBarHeight)
#define kTabBarHeight (kCurveScreen ? 83 : 49)

// 是否空对象
#define kStringIsEmpty(str)     ([str isKindOfClass:[NSNull class]] || str == nil || ![str isKindOfClass:[NSString class]] || [str length] < 1 ? YES : NO)
#define kArrayIsEmpty(array)    (array == nil || [array isKindOfClass:[NSNull class]] || ![array isKindOfClass:[NSArray class]] || array.count == 0)
#define kDictIsEmpty(dict)      (dict == nil || [dict isKindOfClass:[NSNull class]] || ![dict isKindOfClass:[NSDictionary class]] || dict.allKeys.count == 0)
#define kObjectIsEmpty(_object) (_object == nil \
|| [_object isKindOfClass:[NSNull class]] \
|| ([_object respondsToSelector:@selector(length)] && [(NSData *)_object length] == 0) \
|| ([_object respondsToSelector:@selector(count)] && [(NSArray *)_object count] == 0))

#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr, "[%s][%zd行] %s\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif

#endif /* CSSMacros_h */
