//
//  NSObject+Addition.m
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import "NSObject+Addition.h"
#import <objc/runtime.h>

@implementation NSObject (Addition)

+ (BOOL)swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel {
    Method originalMethod = class_getInstanceMethod(self, originalSel);
    Method newMethod = class_getInstanceMethod(self, newSel);
    if (!originalMethod || !newMethod) return NO;
    
    class_addMethod(self,
                    originalSel,
                    class_getMethodImplementation(self, originalSel),
                    method_getTypeEncoding(originalMethod));
    class_addMethod(self,
                    newSel,
                    class_getMethodImplementation(self, newSel),
                    method_getTypeEncoding(newMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(self, originalSel),
                                   class_getInstanceMethod(self, newSel));
    
    return YES;
}

+ (BOOL)swizzleClassMethod:(SEL)originalSel with:(SEL)newSel {
    Class class = object_getClass(self);
    Method originalMethod = class_getInstanceMethod(class, originalSel);
    Method newMethod = class_getInstanceMethod(class, newSel);
    if (!originalMethod || !newMethod) return NO;
    method_exchangeImplementations(originalMethod, newMethod);
    return YES;
}

- (NSData *)css_serializationToJsonDataWithError:(NSError **)error {
    id jsonObj;
    if ([self isKindOfClass:[NSDictionary class]] || [self isKindOfClass:[NSArray class]]) {
        jsonObj = self;
    } else if ([self isKindOfClass:[NSData class]]) {
        return (NSData *)self;
    } else {
        jsonObj = [self css_toDic];
    }
    NSData *data;
    @try {
        data = [NSJSONSerialization dataWithJSONObject:jsonObj options:0 error:error];
    } @catch (NSException *exception) {
        //TODO:描述错误
    } @finally {
        return data;
    }
}

- (NSMutableDictionary *)css_toDic {
    Class class = self.class;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    while (class != NSObject.class) {
        [dic addEntriesFromDictionary:[self toDicForClass:class]];
        class = class_getSuperclass(class);
    }
    return dic;
}

- (NSMutableDictionary *)toDicForClass:(Class)class {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    
    objc_property_t *props = class_copyPropertyList(class, &propsCount);
    
    for(int i = 0;i < propsCount; i++) {
        
        objc_property_t prop = props[i];
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        id value = [self valueForKey:propName];
        if(value != nil) {
            value = [self getObjectInternal:value];
            [dic setObject:value forKey:propName];
        }
    }
    
    if (props) {
        free(props);
    }
    return dic;
}

- (id)getObjectInternal:(id)obj {
    
    if([obj isKindOfClass:[NSString class]]
       ||
       [obj isKindOfClass:[NSNumber class]]
       ||
       [obj isKindOfClass:[NSNull class]]) {
        
        return obj;
        
    }
    if([obj isKindOfClass:[NSArray class]]) {
        
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        
        for(int i = 0; i < objarr.count; i++) {
            
            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        return arr;
    }
    if([obj isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        
        for(NSString *key in objdic.allKeys) {
            
            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }
        return dic;
    }
    return [self css_toDic];
}

@end
