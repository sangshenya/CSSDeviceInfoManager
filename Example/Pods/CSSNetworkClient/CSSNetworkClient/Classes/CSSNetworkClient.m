//
//  CSSNetworkClient.m
//  CSSKit
//
//  Created by 陈坤 on 2018/12/4.
//

#import "CSSNetworkClient.h"
#import "CSSHTTPOperation.h"
#import <CSSKit/NSObject+Addition.h>
#import <CSSKit/CSSMacros.h>

#define kMCTNetworkBaseURL [NSURL URLWithString:@"http://47.97.243.214"] //正式
//#define kMCTNetworkBaseURL [NSURL URLWithString:@"http://192.168.199.179:8085"] //测试

@implementation CSSNetworkClient

- (instancetype)initWithBaseURL:(NSURL *)baseURL {
    if (self = [super init]) {
        _baseURL = kStringIsEmpty(baseURL.absoluteString) ? kMCTNetworkBaseURL : baseURL;
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 3;
    }
    return self;
}

- (void)GET:(NSString *)URLString
 parameters:(NSDictionary *)params
 completion:(CSSNetworkCompletionBlock)completion{
    NSParameterAssert(URLString);
    if (params.count) {
        URLString = [URLString stringByAppendingFormat:@"?%@", [self queryStringFromParameters:params withEncoding:NSUTF8StringEncoding]];
    }
    NSURL *url = [NSURL URLWithString:URLString relativeToURL:_baseURL];
    NSParameterAssert(url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [self sendRequest:request completion:completion];
}

- (void)POST:(NSString *)URLString
  parameters:(NSObject *)params
  completion:(CSSNetworkCompletionBlock)completion{
    NSError *error;
    NSData *data = [params css_serializationToJsonDataWithError:&error];
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(nil, nil, error);
        });
        return;
    }
    [self POST:URLString data:data headers:@{@"Content-Type": @"application/json"} completion:completion];
}

- (void)POST:(NSString *)URLString
        data:(NSData *)data
     headers:(NSDictionary *)headers
  completion:(CSSNetworkCompletionBlock)completion{
    NSURL *url = [NSURL URLWithString:URLString relativeToURL:_baseURL];
    NSParameterAssert(url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    
    if (headers) {
        [headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
            NSAssert([key isKindOfClass:[NSString class]], @"headers can only be string-string pairs");
            NSAssert([value isKindOfClass:[NSString class]], @"headers can only be string-string pairs");
            [request setValue:value forHTTPHeaderField:key];
        }];
    } else {
        if ([headers valueForKey:@"Content-Type"] == nil) {
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
    }
    [self sendRequest:request completion:completion];
}


- (void)sendRequest:(NSMutableURLRequest *)request completion:(CSSNetworkCompletionBlock)completion {
    CSSHTTPOperation *operation = [self operationWithURLRequest:request completion:^(CSSHTTPOperation *operation, NSData *data, NSError *error) {
        if (data.length <= 0 || error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(operation, nil, error);
            });
            return;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error;
            id jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    if (completion) completion(operation, nil, error);
                } else {
                    if (completion) completion(operation, jsonData, nil);
                }
            });
        });
    }];
    [self.operationQueue addOperation:operation];
}

- (CSSHTTPOperation *)operationWithURLRequest:(NSURLRequest *)request completion:(CSSNetworkCompletionBlock)completion {
    CSSHTTPOperation *operation = [CSSHTTPOperation operationWithRequest:request];
    [operation setCompletion:completion];
    return operation;
}

- (NSString *)queryStringFromParameters:(NSDictionary *)params withEncoding:(NSStringEncoding)encoding {
    NSMutableString *queryString = [NSMutableString new];
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        NSAssert([key isKindOfClass:[NSString class]], @"Query parameters can only be string-string pairs");
        NSAssert([value isKindOfClass:[NSString class]], @"Query parameters can only be string-string pairs");
        
        [queryString appendFormat:queryString.length > 0 ? @"&%@=%@" : @"%@=%@", key, value];
    }];
    return queryString;
}

@end
