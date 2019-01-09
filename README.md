# CSSDeviceInfoManager

CSSDeviceInfoManager是一个用于获取设备信息的开源项目，它将设备的各项信息封装成属性，只需简单调用即可

## 导入CSSDeviceInfoManager

```ruby
pod 'CSSDeviceInfoManager'
```

## 引用CSSDeviceInfoManager

`引用CSSDeviceInfoManager`
```obj-c
#import <CSSDeviceInfoManager/CSSDeviceInfoManager.h>
```

## 获取CSSDeviceInfoManager中的信息

`例子：获取iOS的广告标识符idfa`
```obj-c
//获取iOS idfa
NSString *idfa = [CSSDeviceInfoManager sharedInstance].idfa;
NSLog(@"idfa:%@",idfa);
```

## 作者

sangshenya, sangshen@ecook.cn

