//
//  CSSHTTPOperation.m
//  CSSKit
//
//  Created by 陈坤 on 2018/12/4.
//

#import "CSSHTTPOperation.h"

@implementation CSSHTTPOperation {
    NSURLRequest *_URLRequest;
    NSURLSessionDataTask *_task;
}

@synthesize executing = _isExecuting;
@synthesize finished = _isFinished;

+ (instancetype)operationWithRequest:(NSURLRequest *)urlRequest{
    CSSHTTPOperation *operation = [[[self class] alloc] init];
    operation->_URLRequest = urlRequest;
    return operation;
}

- (void)setCompletion:(CSSHTTPOperationCompletionBlock)completionBlock{
    if (!completionBlock) {
        [super setCompletionBlock:nil];
    } else {
        __weak typeof(self) weakSelf = self;
        [super setCompletionBlock:^{
            typeof(self) strongSelf = weakSelf;
            if (strongSelf) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!strongSelf.isCancelled) {
                        completionBlock(strongSelf, strongSelf->_data, strongSelf->_error);
                    }
                    [strongSelf setCompletionBlock:nil];
                });
            }
        }];
    }
}

#pragma mark - NSOperation Overrides

- (BOOL)isAsynchronous {
    return YES;
}

- (void)cancel {
    [_task cancel];
    [super cancel];
}

- (void)start {
    if (self.isCancelled) {
        [self finish];
        return;
    }
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    _task = [[NSURLSession sharedSession] dataTaskWithRequest:_URLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        _response = (NSHTTPURLResponse *)response;
        if (error) {
            _error = error;
        } else {
            _data = data;
        }
        [self finish];
    }];
    [_task resume];
}

- (void)finish {
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    _isExecuting = NO;
    _isFinished = YES;
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isFinished {
    return _isFinished;
}

- (BOOL)isExecuting {
    return _isExecuting;
}

@end
