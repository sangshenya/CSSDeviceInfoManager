# CSSDeviceInfoManager

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

## Author

sangshenya, sangshen@ecook.cn

## License

CSSDeviceInfoManager is available under the MIT license. See the LICENSE file for more info.
