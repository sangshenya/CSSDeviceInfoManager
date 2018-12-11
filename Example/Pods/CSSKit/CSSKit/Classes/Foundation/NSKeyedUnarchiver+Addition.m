//
//  NSKeyedUnarchiver+Addition.m
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import "NSKeyedUnarchiver+Addition.h"

@implementation NSKeyedUnarchiver (Addition)

+ (nullable id)unarchiveObjectWithData:(NSData *)data exception:(__autoreleasing NSException **)exception {
    id object = nil;
    @try {
        object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } @catch (NSException *e) {
        if (exception) *exception = e;
    } @finally {
        
    }
    return object;
}

+ (nullable id)unarchiveObjectWithFile:(NSString *)path exception:(__autoreleasing NSException **)exception {
    id object = nil;
    @try {
        object = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    } @catch (NSException *e) {
        if (exception) *exception = e;
    } @finally {
        
    }
    return object;
}

@end
