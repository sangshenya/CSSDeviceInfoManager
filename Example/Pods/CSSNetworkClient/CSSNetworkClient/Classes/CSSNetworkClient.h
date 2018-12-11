//
//  CSSNetworkClient.h
//  CSSKit
//
//  Created by 陈坤 on 2018/12/4.
//

#import <Foundation/Foundation.h>

@class CSSHTTPOperation;
typedef void (^CSSNetworkCompletionBlock)(CSSHTTPOperation *operation, id result, NSError *error);

NS_ASSUME_NONNULL_BEGIN

@interface CSSNetworkClient : NSObject

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

- (instancetype)initWithBaseURL:(NSURL *)baseURL;

- (void)GET:(NSString *)URLString
 parameters:(NSDictionary *)params
 completion:(CSSNetworkCompletionBlock)completion;

- (void)POST:(NSString *)URLString
  parameters:(NSObject *)params
  completion:(CSSNetworkCompletionBlock)completion;

- (void)POST:(NSString *)URLString
        data:(NSData *)data
     headers:(NSDictionary *)headers
  completion:(CSSNetworkCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
