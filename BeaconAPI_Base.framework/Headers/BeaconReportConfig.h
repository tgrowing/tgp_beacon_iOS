//
//  BeaconReportConfig.h
//  BeaconAPI_Base
//
//  Created by jackhuali on 2014/4/8.
//  Copyright © 2014 tencent.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
  基础策略配置:通过此配置类可以灯塔基础配置项进行硬编码设置,如果进行云配置可联系对接人.
 */
@interface BeaconReportConfig : NSObject

/// 开启或者关闭事件上报功能，默认为YES可进行上报，如果有给用户提供关闭事件上报的接口等情况，可设置为NO
@property (nonatomic, assign) BOOL eventReportEnabled;

/// 开启或者关闭策略请求功能，默认为YES进行策略请求，如果需要关闭，可设置为NO
/// 策略请求功能已停用，不支持开启
@property (nonatomic, assign, readonly) BOOL configQueryEnabled;

/// 本地数据库的最大容量（超过限额不予存储），默认10000条，保护区间是100～100000条，云端优先级高于本地设置
@property (nonatomic, assign) NSInteger maxDBCount;

/// 实时事件上报的轮询间隔，默认2s，允许区间是[0.1,20]s
@property (nonatomic, assign) NSInteger realTimeEventPollingInterval;
/// 普通事件上报的轮询间隔，默认5s，允许区间是[1,50]s
@property (nonatomic, assign) NSInteger normalEventPollingInterval;

/// 事件上报服务的域名
/// 默认为SASS上报服务的域名，私有化部署需要特殊设置
@property (nonatomic, copy, nullable) NSString *uploadURL;

/// 事件轮询上传开关,默认打开. 关闭后业务生成的事件会入库,但不上传到服务端,达到DB上限后丢弃剩余事件.
@property (nonatomic, assign) BOOL eventUploadEnabled;

/// 网络服务上报，默认打开
@property (nonatomic, assign) BOOL eventUploadNetEnabled;

/// 配置服务的域名，一般不需要设置，有特殊需求时找SDK同学对接
/// 策略请求功能已停用，不支持配置地址
@property (nonatomic, copy, nullable) NSString *configURL __attribute__((deprecated("此方法已废弃，不支持配置策略地址")));

@end

NS_ASSUME_NONNULL_END
