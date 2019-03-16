//
//  CSSTrackerPersistence.h
//  CSSDeviceInfoManager
//
//  Created by 陈坤 on 2019/3/16.
//

#import <Foundation/Foundation.h>
#import "CSSTrackerEventModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSSTrackerPersistence : NSObject

+ (instancetype)sharedInstance;

/**
 唯一机器码
 */
@property (nonatomic, readwrite, assign) double machineId;

/**
 事件添加到持久层
 
 @param info 事件模型
 */
- (void)persistCustomEvent:(CSSTrackerEventModel *)info;

/**
 从文件读取数据,并组合成正确格式
 
 @param filePath 文件路径
 @return 二进制数据流
 */
- (NSData *)uploadCustomEventsDataWithPath:(NSString *)filePath;

/**
 获取本地序列化文件路径
 
 @return 文件路劲
 */
- (NSString *)nextArchivedCustomEventsPath;

/**
 根据路径清除本地文件
 
 @param filePath 指定文件路径
 @param error 错误信息
 */
- (void)clearFile:(NSString *)filePath error:(NSError **)error;

/**
 根据路径清除本地文件
 
 @param filePaths 文件路径集合
 */
- (void)clearFiles:(NSArray<NSString *> *)filePaths;

@end

NS_ASSUME_NONNULL_END
