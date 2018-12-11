//
//  CSSNetworkClient+Singletop.h
//  CSSKit
//
//  Created by 陈坤 on 2018/12/5.
//

#import "CSSNetworkClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSSNetworkClient (Singletop)

+ (instancetype)css_sharedClient;

@end

NS_ASSUME_NONNULL_END
