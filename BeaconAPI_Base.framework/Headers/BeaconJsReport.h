//
//  JsReport.h
//  BeaconAPI_Base
//
//  Created by zacardfang on 2022/1/5.
//  Copyright © 2022 tencent.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BeaconJsReport : NSObject

/// 开启内嵌H5通过App上报埋点的通路，并设置javaScriptEnabled = YES
- (void)enableBridge:(WKWebView *)wkWebView;

/// 关闭内嵌H5通过App上报埋点的通路
- (void)disableBridge;

@end

NS_ASSUME_NONNULL_END
