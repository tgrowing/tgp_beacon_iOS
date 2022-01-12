# 私有化版本

### 集成SDK

#### 1.手动引入

SDK包：BeaconAPI_Base.framework —基础上报SDK，必选 

选择拷贝需要的framework到您的应用目录下，在Xcode中需要添加的Target中选择 ”Build Phases”->“Link Binary With Libraries”->“Add”->“Add Other”→选择framework目录。

在Other linker flag里加入-ObjC标志 cocoapods导入 支持使用cocoapods进行包依赖管理集成灯塔上报framework。 

#### 2.cocoapods引入【推荐】
使用cocoapods的方式，需要在Podfile文件添加腾讯的podspec源，并pod 依赖灯塔SDK，参考如下：

```
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

target 'Demo' do
use_frameworks! 

pod 'tgp_beacon', '~> 1.0.2'

end
```

### 初始化SDK及上报

#### 引入头文件
```
#import <BeaconAPI_Base/BeaconReport.h>
```

#### 初始化SDK
 
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [BeaconReport.sharedInstance initOstar];    // startWithAppkey 之前必须调用
    // 填写上述从灯塔官网申请的appkey，使用实时联调2.0时，可以填写AppKey：LOGDEBUGKEY00001
    [BeaconReport.sharedInstance startWithAppkey:"申请的Appkey" config:nil];
    return YES;
}
```

#### 至此，SDK已初始化完成，可以开始上报事件
```
NSDictionary *params = @{@"key1" : @"event_value1", @"key2" : @"event_value2"};

// 上报实时事件
BeaconEvent *realTimeEvent = [BeaconEvent realTimeEventWithCode:@"real_time_event_code_test" params:params];
[BeaconReport.sharedInstance reportEvent:realTimeEvent];

// 上报普通事件
BeaconEvent *noralEvent = [BeaconEvent normalEventWithCode:@"normal_event_code_test" params:params];
[BeaconReport.sharedInstance reportEvent:normalEvent];
```

#### 初始化接口进阶

设置上报配置：BeaconReportConfig

```
BeaconReportConfig *config = [BeaconReportConfig new];
// 开发调试阶段，打开严苛模式，可以发现一些致命的基础问题，上线时必须关闭
config.strictMode = YES;
// 开启实时联调模式，可以在实时联调后台查看验证事件是否成功上报到后台
config.debugMode = NO;
// 设置本地调试时控制台输出的日志级别：1 fetal, 2 error, 3 warn, 4 info, debug, 5 debug, 10 all, 默认为0，不打印日志
config.logLevel = 10;
BeaconReport.sharedInstance.config = config;
// 私有化部署
config.uploadURL = @"自定义上报域名";
//其余相关配置参考BeaconReportConfig接口说明
```

设置一些全局的ID

```
// 设置用户唯一标识符，用以通过userId标识和分类异常用户信息
BeaconReport.sharedInstance.userId = @"userId";
// 原来使用的设备标识符，通过OMGID SDK获取
BeaconReport.sharedInstance.omgId = @"omgId";
// 小程序、H5设置的开放平台的id
BeaconReport.sharedInstance.openId = @"openId";
```

初始化接口tunnelInfo参数进阶：

- (void)startWithTunnelInfo:(BeaconTunnelInfo )tunnelInfo config:(nullable BeaconReportConfig )config

```
BeaconTunnelInfo *mainTunnelInfo = [BeaconTunnelInfo tunnelInfoWithAppKey:@"LOGDEBUGKEY00001"];//填写上述从灯塔官网申请的appkey,// 使用实时联调2.0时可以填写：LOGDEBUGKEY00001
// 各业务自己定义的通道版本，主APP一般采用APP的版本，其他业务或者SDK可自行定义
mainTunnelInfo.version = @"1.0";
// 当前通道登录用户的ID
mainTunnelInfo.userId = @"userId_test";
// 渠道ID
mainTunnelInfo.channelId = @"chainId_test";
// 初始化时机，添加上报的事件的附加参数,同一个appkey通道的每个事件都会上报这些参数
mainTunnelInfo.additionalParams = @{@"additionalKey1" : @"additional_value1", @"additionalKey2" : @"additional_value2"};
[BeaconReport.sharedInstance startWithTunnelInfo:mainTunnelInfo config:nil];
```

非初始化时机需要追加附加参数
```
NSString *appKey = @"LOGDEBUGKEY00001"; 
[BeaconReport.sharedInstance addAdditionalParams:@{@"addKey1" : @"addValue1"} forAppKey:appKey];
```

#### 上报功能进阶-多通道

注册子通道
```
// 注册子通道上报
BeaconTunnelInfo *tunnelInfo = [BeaconTunnelInfo tunnelInfoWithAppKey:@"LOGDEBUGKEY00002"];
[BeaconReport.sharedInstance registerSubTunnel:tunnelInfo];
```

上报事件到子通道
```
BeaconEvent *event = [[BeaconEvent alloc] initWithAppKey:@"LOGDEBUGKEY00002" code:@"subTunnel_real_time_event_test" type:BeaconEventTypeRealTime success:YES params:@{@"k":@"v"}];
[BeaconReport.sharedInstance reportEvent:event];
```
### 上报接口的返回码
```
typedef NS_ENUM(NSInteger, BeaconResultType) {
    BeaconResultTypeSuccess = 0,                // 成功
    BeaconResultTypeIllegalParameters,          // 参数非法，一般是接口入参校验不通过
    BeaconResultTypeConfigOff,                  // 配置关闭，导致上报失败或者不需要上报
    BeaconResultTypeParamsExceededLength,       // 参数长度过长
    BeaconResultTypeSDKNotStarted,              // SDK未初始化就进行上报
    BeaconResultTypeUnknow,                     // 未知错误
};
```
