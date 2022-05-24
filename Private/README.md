# 私有化版本

### 集成SDK

#### 1.手动引入

SDK包：BeaconAPI_Base.framework —基础上报SDK，必选 

![image.png](https://tencent-growth-platform-1251316161.cos.ap-beijing.myqcloud.com/sdk/images/github-readme-images/step18.png)

选择拷贝需要的framework到您的应用目录下，在Xcode中需要添加的Target中选择 ”Build Phases”->“Link Binary With Libraries”->“Add”->“Add Other”→选择framework目录。

在Other linker flag里加入-ObjC标志 cocoapods导入 支持使用cocoapods进行包依赖管理集成灯塔上报framework。 

#### 2.cocoapods引入【推荐】
使用cocoapods的方式，需要在Podfile文件添加腾讯的podspec源，并pod 依赖灯塔SDK，参考如下：

```objc
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

target 'Demo' do
use_frameworks! 

pod 'tgp_beacon', '~> 2.0.1'

end
```

### 初始化SDK及上报

#### 引入头文件
```objc
#import <BeaconAPI_Base/BeaconReport.h>
```

#### 初始化SDK

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [BeaconReport.sharedInstance initOstar];    // startWithAppkey 之前必须调用
    // 填写上述从灯塔官网申请的appkey，使用实时联调2.0时，可以填写AppKey：LOGDEBUGKEY00001
    [BeaconReport.sharedInstance startWithAppkey:"申请的Appkey" config:nil];
    return YES;
}
```

#### 至此，SDK已初始化完成，可以开始上报事件
```objc
NSDictionary *params = @{@"key1" : @"event_value1", @"key2" : @"event_value2"};

// 上报实时事件
BeaconEvent *realTimeEvent = [BeaconEvent realTimeEventWithCode:@"real_time_event_code_test" params:params];
[BeaconReport.sharedInstance reportEvent:realTimeEvent];

// 上报普通事件
BeaconEvent *noralEvent = [BeaconEvent normalEventWithCode:@"normal_event_code_test" params:params];
[BeaconReport.sharedInstance reportEvent:normalEvent];
```
#### 停止上报、恢复上报(2.0.1版本新增功能！！！）
```objc
/// 停止上报, immediately为YES则会马上中断正在进行的任务，NO则会等待任务完成后再停止轮询
/// 停止上报
[BeaconReport.sharedInstance stopReport:YES];
/// 立即停止上报
[BeaconReport.sharedInstance stopReport:NO];
//恢复上报
[BeaconReport.sharedInstance resumeReport];
```
#### 初始化接口进阶

设置上报配置：BeaconReportConfig(**以下配置都可以不设置，不设置会走默认配置**)

```objc
BeaconReportConfig *config = [BeaconReportConfig new];
// 开发调试阶段，打开严苛模式，严苛模式开启时用于上线前排查问题, SDK会主动触发crash,可以发现一些致命的基础问题，上线时必须关闭!!!
config.strictMode = YES;
// 开启实时联调模式，可以在实时联调后台查看验证事件是否成功上报到后台
config.debugMode = NO;
// 设置本地调试时控制台输出的日志级别：1 fetal, 2 error, 3 warn, 4 info, debug, 5 debug, 10 all, 默认为0，不打印日志
// 线上正式环境，必须设置为0关闭此日志
config.logLevel = 0;
// 开启或者关闭事件上报功能，默认为YES可进行上报，如果有给用户提供关闭事件上报的接口等情况，可设置为NO
config.eventReportEnabled = YES;
// 本地数据库的最大容量（超过限额不予存储），默认10000条，保护区间是100～100000条，云端优先级高于本地设置
config.maxDBCount = 10000;
// 实时事件上报的轮询间隔，默认2s，允许区间是[0.1,20]s
config.realTimeEventPollingInterval = 2;
// 普通事件上报的轮询间隔，默认5s，允许区间是[1,50]s
config.normalEventPollingInterval = 5;
// 是否采集WiFiMac地址，参数为NO时不采集，默认采集，如果需要关闭则需要在初始化前设置为NO
config.collectMacEnable = YES;
// 是否采集idfa,参数为NO时不采集，默认采集，如果需要关闭则需要在初始化前设置为NO
config.collectIdfaEnable = YES;
// 是否采集idfv，默认采集
config.collectIdfvEnable = YES;

BeaconReport.sharedInstance.config = config;
//其余相关配置参考BeaconReportConfig接口说明
```

设置一些全局的ID

```objc
// 设置用户唯一标识符，用以通过userId标识和分类异常用户信息
BeaconReport.sharedInstance.userId = @"userId";
// 原来使用的设备标识符，通过OMGID SDK获取
BeaconReport.sharedInstance.omgId = @"omgId";
// 小程序、H5设置的开放平台的id
BeaconReport.sharedInstance.openId = @"openId";
```

初始化接口tunnelInfo参数进阶：

- (void)startWithTunnelInfo:(BeaconTunnelInfo )tunnelInfo config:(nullable BeaconReportConfig )config

```objc
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
```objc
NSString *appKey = @"LOGDEBUGKEY00001"; 
[BeaconReport.sharedInstance addAdditionalParams:@{@"addKey1" : @"addValue1"} forAppKey:appKey];
```

#### 上报功能进阶-多通道

注册子通道
```objc
// 注册子通道上报
BeaconTunnelInfo *tunnelInfo = [BeaconTunnelInfo tunnelInfoWithAppKey:@"LOGDEBUGKEY00002"];
[BeaconReport.sharedInstance registerSubTunnel:tunnelInfo];
```

上报事件到子通道
```objc
BeaconEvent *event = [[BeaconEvent alloc] initWithAppKey:@"LOGDEBUGKEY00002" code:@"subTunnel_real_time_event_test" type:BeaconEventTypeRealTime success:YES params:@{@"k":@"v"}];
[BeaconReport.sharedInstance reportEvent:event];
```
### 上报接口的返回码
```objc
typedef NS_ENUM(NSInteger, BeaconResultType) {
    BeaconResultTypeSuccess = 0,                // 成功
    BeaconResultTypeIllegalParameters,          // 参数非法，一般是接口入参校验不通过
    BeaconResultTypeConfigOff,                  // 配置关闭，导致上报失败或者不需要上报
    BeaconResultTypeParamsExceededLength,       // 参数长度过长
    BeaconResultTypeSDKNotStarted,              // SDK未初始化就进行上报
    BeaconResultTypeUnknow,                     // 未知错误
};
```

###扩展功能

#### App 打通 H5

集成了 Web JS SDK 的 H5 页面，在嵌入到 App 后，H5 内的事件可以通过 App 进行发送，事件发送前会添加上 App 采集到的预置属性。该功能默认是关闭状态，如果需要开启，需要在 App 和 H5 端同时进行开启。

```objc
// 在嵌入WKWebView的页面中，创建JsReport对象
JsReport *jsReport = [JsReport new];

// 开启内嵌H5通过App上报的通路
[jsReport enableBridge:wkWebView];

// 关闭内嵌H5通过App上报的通路
[jsReport disableBridge];
```




#SDK更新日志
## 2022年05月24日
### V2.0.1 
- 停止上报, immediately为YES则会马上中断正在进行的任务，NO则会等待任务完成后再停止轮询
- 恢复上报
-  添加重试策略，上报失败后开启重试请求策略，请求的时间间隔会逐渐增加
- 支持设置上报最大存储条数，默认是10000条，区间是10000～50000