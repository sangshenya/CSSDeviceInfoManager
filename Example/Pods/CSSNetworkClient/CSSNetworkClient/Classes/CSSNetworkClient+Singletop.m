//
//  CSSNetworkClient+Singletop.m
//  CSSKit
//
//  Created by 陈坤 on 2018/12/5.
//

#import "CSSNetworkClient+Singletop.h"

@implementation CSSNetworkClient (Singletop)

+ (instancetype)css_sharedClient{
    static CSSNetworkClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[CSSNetworkClient alloc] initWithBaseURL:nil];
    });
    return client;
}

@end
