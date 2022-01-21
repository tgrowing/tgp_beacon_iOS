//
//  WebViewController.m
//  Demo
//
//  Created by zacardfang on 2021/10/20.
//  Copyright © 2021 yiqiwang. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
#import <BeaconAPI_Base/BeaconJsReport.h>

@interface WebViewController ()

@property (weak, nonatomic) IBOutlet UITextField *urlTextView;
@property (weak, nonatomic) IBOutlet UIButton *openUrlBtn;
@property (weak, nonatomic) IBOutlet UIView *content;
@property(nonatomic,strong) WKWebView *webView;

@property (nonatomic) BeaconJsReport *jsReport;

// 解决iOS12, iOS12.1 无法设置UserAgent的问题
@property(nonatomic,strong) WKWebView *fakeWebView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // WKWebView 无法支持11.0之前的版本在Storyboard中布局，考虑兼容性统一使用代码添加
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.content.frame.size.width, self.content.frame.size.height)];
    [self.content addSubview:self.webView];
    
    // 设置App标识 for js SDK
//    [self.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
//        NSString *newUserAgent = [NSString stringWithFormat:@"%@ %@", result, @"isApp"];
//        [self.webView setCustomUserAgent:newUserAgent];
//      }];
    
    // 解决iOS12, iOS12.1 无法设置UserAgent的问题
    self.fakeWebView = [[WKWebView alloc] init];
    [self.fakeWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
        self.fakeWebView = nil;
        
        // 设置App标识 for js SDK
        NSString *newUserAgent = [NSString stringWithFormat:@"%@ %@", result, @"isApp"];
        [self.webView setCustomUserAgent:newUserAgent];
      }];
    
    _jsReport = [BeaconJsReport new];

    // 开启 App与H5 打通。如果有必要，你可以在生命周期中调用开关；
    [_jsReport enableBridge:_webView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)openUrl:(id)sender {
    // [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://10.64.118.52:8080"]]];
    
    NSString *url = _urlTextView.text ? _urlTextView.text : @"";
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    [_urlTextView resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    // 开启 App与H5 打通
    // [_jsReport enableBridge];
}

- (void)viewDidDisappear:(BOOL)animated {
    // 关闭 App与H5 打通
    // [_jsReport disableBridge];
}

- (void)dealloc {
    NSLog(@"clearCookies");
    [self clearCookies];
}

-(void)clearCookies {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] removeCookiesSinceDate:NSDate.distantPast];
        [[WKWebsiteDataStore defaultDataStore] fetchDataRecordsOfTypes:WKWebsiteDataStore.allWebsiteDataTypes completionHandler:^(NSArray<WKWebsiteDataRecord *> * records) {
            for (WKWebsiteDataRecord* record in records) {
                [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes forDataRecords:@[record] completionHandler:^{
                }];
            }
        }];
    });
}

@end
