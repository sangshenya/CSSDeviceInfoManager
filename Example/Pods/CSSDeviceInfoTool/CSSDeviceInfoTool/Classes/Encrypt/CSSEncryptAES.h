//
//  CSSEncryptAES.h
//  CSSDeviceInfoTool
//
//  Created by 陈坤 on 2018/12/4.
//

#import <Foundation/Foundation.h>

NSString *KCSSTAESEncryptString(NSString *content, NSString *key);
NSString *KCSSTAESDecryptString(NSString *content, NSString *key);

NSData *KCSSTAESEncryptData(NSData *data, NSData *key);
NSData *KCSSTAESDecryptData(NSData *data, NSData *key);
