# 基础知识
##### 1. 事件模型（Event Model）
事件模型（Event Model）是以事件为基本研究对象，用来定义和描述一个用户在某个时间通过某种方式完成某个行为。事件的划分和定义，可以反映上报日志的名称和内在数据结构，需要业务根据自身情况需求进行合理设置
在事件模型中，定义的事件包括以下类型的信息。
![image.png](https://tencent-growth-platform-1251316161.cos.ap-beijing.myqcloud.com/datainsight/test/images/step12.png)

What： 描述用户所做的这个事件的具体内容。在平台中，会通过日志里的 eventCode 来区分用户的不同行为，例如登录、播放、购买、页面访问等。

Who： 即触发这次事件的用户。在平台中，会通过日志里的UIN字段默认分配一个设备唯一ID来标识当前用户，即设备ID。当然，也可以通过自定义其他字段来上报其他类型UID，例如imei、mac、guid、QQ号、OpenID、业务账号UID等。

When： 即这个事件发生的实际时间。在平台中，使用 event_time 字段来记录精确到毫秒的触发时间。如果由于网络问题延迟上报，事件原始触发时间不会发生变化。但是这条日志进入的分区可能会延后到第二天，因此分区时间ds可能包含少量不在当天触发的事件。建议尽量使用 event_time 事件触发时间来进行分析，更加反应事件的客观情况。

以上的 What、Who、When 是一条事件的3个基本要素，在事件定义中缺一不可。

Params： 即用户从事这个事件的方式。这个概念比较广，包括用户所在的地理位置、使用的设备、使用的浏览器、使用的 App 版本、操作系统版本、进入的渠道、跳转过来时的 referer 、当前行为的类别等。这些参数字段能够详细记录用户触发事件的具体情况属性，以便于进行灵活精准地数据分析工作。

在 Params 扩展属性参数这部分中，如果使用平台SDK上报，平台会预置一些参数字段作为接口供业务上报。预置字段能够使数据上报更加规范、减少由于对名称理解不一所导致的误解，因此建议尽量使用预置的字段上报对应信息，如果没有相应的预置字段，可以通过定义自定义参数字段来扩展上报。
##### 2.定义事件的 event code 和显示名
（一）定义事件event code的核心问题是如何把握事件的颗粒度。
理论上可以随意定义事件名称，然后交由开发按特定规则进行拼接、解析、统计。但是平台定位于自动敏捷分析，中间无人工参与，因此为了确保最终业务的分析使用效率，请重视这个环节。这个环节重要但是不复杂。
如果颗粒度过粗，例如命名为“页面访问事件”“点击事件”“内容曝光事件”，那么分析用户行为时，非常宽泛且没有针对性，并且总是需要结合多个参数字段，去筛选出特定的某项操作；
如果颗粒度过细，例如“首页点击播放音乐”“列表页点击播放音乐”“歌单页点击播放音乐”，便显得重复累赘，数量过多不便维护。
（二）具体怎么把握事件的划分呢？
通常一个App产品的事件数量， 不多于500个，不少于10个为宜 。（按产品功能复杂度有所调整，这个数字只是个参考。除非你的App是个类似QQ浏览器、手机QQ等，集成了复杂业务形态的超级App；或者是个手电筒App交互足够简单的工具App）



# 接入说明

### 集成SDK

#### 1.手动引入

SDK包：BeaconAPI_Base.framework —基础上报SDK，必选 
![image.png](https://tencent-growth-platform-1251316161.cos.ap-beijing.myqcloud.com/datainsight/test/images/step1.png)

选择拷贝需要的framework到您的应用目录下，在Xcode中需要添加的Target中选择 ”Build Phases”->“Link Binary With Libraries”->“Add”->“Add Other”→选择framework目录。

在Other linker flag里加入-ObjC标志 cocoapods导入 支持使用cocoapods进行包依赖管理集成灯塔上报framework。 

#### 2.cocoapods引入
使用cocoapods的方式，需要在Podfile文件添加腾讯的podspec源，并pod 依赖灯塔SDK，参考如下：

```objc
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

target 'Demo' do
use_frameworks! 

pod 'tgp_beacon', '~> 1.0.6'

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
Appkey获取渠道之一：
- 一DataInsight官网地址 [https://growth.qq.com](https://growth.qq.com/)
![image.png](https://tencent-growth-platform-1251316161.cos.ap-beijing.myqcloud.com/datainsight/test/images/step3.png)


#### 至此，SDK已初始化完成，可以开始上报事件
平台 SDK 上报格式默认为 K-V 对形式。其中，Key 值有唯一含义，不需要通过其它解析标志其含义；Value 值有唯一含义，不需要通过其它解析标志其含义。
后端对接可支持 K-V 对形式及宽表结构数据。K-V 对格式要求如上，宽表结构数据要求每一列有明确的含义，不需要通过其它解析标志其含义

```objc
NSDictionary *params = @{@"key1" : @"event_value1", @"key2" : @"event_value2"};


// 上报实时事件
// 实时事件，间隔 2 秒启动上报，2 秒内的其他实时事件会合并到当前队列一起上报
BeaconEvent *realTimeEvent = [BeaconEvent realTimeEventWithCode:@"real_time_event_code_test" params:params];
[BeaconReport.sharedInstance reportEvent:realTimeEvent];

// 上报普通事件
// 普通事件会缓存在内存一段时间后写入数据库，间隔 5 秒启动上报
BeaconEvent *noralEvent = [BeaconEvent normalEventWithCode:@"normal_event_code_test" params:params];
[BeaconReport.sharedInstance reportEvent:normalEvent];

```
#### 上报事件代码展示
- 进入到应用
![image.png](https://tencent-growth-platform-1251316161.cos.ap-beijing.myqcloud.com/datainsight/test/images/step4.png)
- 登记事件（创建登记事件或查看登记事件）
![image.png](https://tencent-growth-platform-1251316161.cos.ap-beijing.myqcloud.com/datainsight/test/images/step5.png)
- 上报代码demo展示
```objc
// 参数
NSDictionary *params = @{"button_name": "report_button1"};
// 事件code
NSString *normal_event_code_test = @"testDemoButtonClick"; 
// 上报实时事件
BeaconEvent *realTimeEvent = [BeaconEvent realTimeEventWithCode:normal_event_code_test params:params];
[BeaconReport.sharedInstance reportEvent:realTimeEvent];

// 上报普通事件
BeaconEvent *noralEvent = [BeaconEvent normalEventWithCode:normal_event_code_test params:params];
[BeaconReport.sharedInstance reportEvent:normalEvent];
```
### 查看上报数据
- 填写上报式例
![image.png](https://tencent-growth-platform-1251316161.cos.ap-beijing.myqcloud.com/datainsight/test/images/step14.png)

- 查看上报
![image.png](https://tencent-growth-platform-1251316161.cos.ap-beijing.myqcloud.com/datainsight/test/images/step9.png)

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
### 本地启动demo操作流程
1、进入到Demo目录下
![image.png](https://tencent-growth-platform-1251316161.cos.ap-beijing.myqcloud.com/datainsight/test/images/step6.png)
2、在Demo目录下，执行pod install,安装完成如下图展示
![image.png](https://tencent-growth-platform-1251316161.cos.ap-beijing.myqcloud.com/datainsight/test/images/step7.png)
3、双击（打开）生成的Demo.xcworkspace，运行即可
![image.png](https://tencent-growth-platform-1251316161.cos.ap-beijing.myqcloud.com/datainsight/test/images/step8.png)


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
```objc
- (void)startWithTunnelInfo:(BeaconTunnelInfo )tunnelInfo config:(nullable BeaconReportConfig )config
```
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



