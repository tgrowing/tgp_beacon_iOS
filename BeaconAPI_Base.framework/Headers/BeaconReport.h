//
//  Beacon.h
//  BeaconAPI_Base
//
//  Created by jackhuali on 2020/4/6.
//  Copyright © 2020 tencent.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BeaconResult.h"
#import "BeaconEvent.h"
#import "BeaconBaseInfoModel.h"
#import "BeaconReportConfig.h"

NS_ASSUME_NONNULL_BEGIN
/// BeaconMttProtocal穿上甲日志协议
@protocol BeaconMttProtocal <NSObject>
/// 适配穿山甲日志
- (void)mttLog:(NSString *)message
          file:(const char *)file
      function:(const char *)function
          line:(NSUInteger)line
      threadID:(NSInteger)threadID
        module:(NSString *)module
        folder:(int)folder level:(int)level;

@end

extern BOOL BeaconHasStarted;

/**
  上报模块的接口类:提供SDK对外API
 */
@interface BeaconReport : NSObject

/// 原来使用的设备标识符，通过OMGID SDK获取
@property (copy, nullable) NSString *omgId;

/// 渠道ID
@property (copy, nullable) NSString *channelId;

/// 是否开启严苛模式，默认为NO，严苛模式开启时用于上线前排查问题, SDK会主动触发crash, 上线务必关闭!!!
@property (assign) BOOL strictMode;

/// 设置本地调试时控制台输出的日志级别：1 fetal, 2 error, 3 warn, 4 info, debug, 5 debug, 10 all, 默认为0，不打印日志
/// 线上正式环境，必须设置为0关闭此日志
@property (nonatomic, assign) int logLevel;

/// 是否采集WiFiMac地址，参数为NO时不采集，默认采集，如果需要关闭则需要在初始化前设置为NO
@property (assign) BOOL collectMacEnable;

/// 是否采集idfa,参数为NO时不采集，默认采集，如果需要关闭则需要在初始化前设置为NO
@property (assign) BOOL collectIdfaEnable;

/// 是否采集idfv，默认采集
@property (nonatomic, assign) BOOL collectIdfvEnable;

/// 穿山甲日志代理
@property (nonatomic, weak) id<BeaconMttProtocal> mttDelegate;


+ (BeaconReport *)sharedInstance;

/// 初始化接口，开启灯塔服务，会向服务器查询策略，初始化各个模块的默认数据上传器等
/// 此接口一般在主APP（主通道）初始化时调用，多次调用的话，只有首次的调用才有效
/// @param appKey 各业务在灯塔平台申请的业务唯一标识
/// @param config 全局配置，可配置一些开关和策略等
- (void)startWithAppkey:(NSString *)appKey config:(nullable BeaconReportConfig *)config;

/// 上报事件
/// @param event 事件，包括所有用户行为事件、APP启动事件等，事件的具体定义参考BeaconEvent模型类
/// @return 返回事件上报结果，此同步返回的结果只代表事件符合上报要求，可以进行上报，
///         但不一定代表事件当前已成功上报到服务端，有可能存在事件在本地缓存并等待上报等情况
- (BeaconReportResult *)reportEvent:(BeaconEvent *)event;

/// 给指定的appKey设置附加参数，此appKey的所有事件都会带上这些参数
/// @param additionalParams 附加参数
/// @param appKey 各业务在灯塔平台申请的业务唯一标识
/// @return 返回设置参数结果,参数非法将返回NO, 设置成功返回 YES. (参数类型要求是:NSNumber 和 NSString)
- (BOOL)setAdditionalParams:(NSDictionary *)additionalParams forAppKey:(NSString *)appKey;

/// 给指定的appKey设置userId
/// @param userId 用户唯一标识符
/// @param appKey 各业务在灯塔平台申请的业务唯一标识
- (void)setUserId:(NSString *)userId forAppKey:(NSString *)appKey;

/// 给指定的appKey设置openid
/// @param openId 小程序、H5设置的开放平台的id
/// @param appKey 各业务在灯塔平台申请的业务唯一标识
- (void)setOpenId:(NSString *)openId forAppKey:(NSString *)appKey;

/// 恢复上报
- (void)resumeReport;

/// 停止上报，调用后会暂停轮询任务
///  @param immediately 如果为true则会马上中断正在进行的任务，false则会等待任务完成后再停止轮询
- (void)stopReport:(BOOL)immediately;

///
/**
 * 初始化O16和O36参数
 * 公有 saas 版本内部维护 uuid 逻辑
 */
- (void)initOstar;


/// 获取所有灯塔已默认采集的公参
- (BeaconBaseInfoModel *)getCommonParams;

///Socket上报开启/关闭接口，默认NO，如果需要关闭则需要设置为NO
- (void)setSocketOnOff:(BOOL)yesOrNo;
 
@end
NS_ASSUME_NONNULL_END


#define BEACON_SDK_VERSION @"V2.2.0"

/// 智能增长的灯塔SDK版本
#define TGP_SDK_VERSION @"V2.2.0"
