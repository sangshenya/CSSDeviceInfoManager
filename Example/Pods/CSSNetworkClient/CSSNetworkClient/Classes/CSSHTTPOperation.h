//
//  CSSHTTPOperation.h
//  CSSKit
//
//  Created by 陈坤 on 2018/12/4.
//

#import <Foundation/Foundation.h>

@class CSSHTTPOperation;
typedef void (^CSSHTTPOperationCompletionBlock)(CSSHTTPOperation *operation, NSData *data, NSError *error);

NS_ASSUME_NONNULL_BEGIN

@interface CSSHTTPOperation : NSOperation

@property (nonatomic, readonly) NSURLRequest *URLRequest;
@property (nonatomic, readonly) NSHTTPURLResponse *response;
@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSError *error;

+ (instancetype)operationWithRequest:(NSURLRequest *)urlRequest;

/**
 the completion is only called if the operation wasn't cancelled
 */
- (void)setCompletion:(CSSHTTPOperationCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
