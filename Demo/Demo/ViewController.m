//
//  ViewController.m
//  DEMO
//
//  Created by yiqiwang on 2021/3/8.
//  Copyright © 2021 yiqiwang. All rights reserved.
//

#import "ViewController.h"
#import <BeaconAPI_Base/BeaconReport.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *appkeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *uploadURLTextField;
@property (weak, nonatomic) IBOutlet UITextField *eventNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *eventParamsTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
    [self.view addGestureRecognizer:tap];
    
    self.appkeyTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"appkey"];
    self.uploadURLTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"uploadurl"];
}

- (void)onTap {
    [self.appkeyTextField resignFirstResponder];
    [self.uploadURLTextField resignFirstResponder];
    [self.eventNameTextField resignFirstResponder];
    [self.eventParamsTextField resignFirstResponder];
}

- (IBAction)onSaveClick:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.appkeyTextField.text forKey:@"appkey"];
    [[NSUserDefaults standardUserDefaults] setObject:self.uploadURLTextField.text forKey:@"uploadurl"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"保存成功"
                                                                   message:@"点击确认，重启后即可生效"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
        exit(0);
    }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)onDirectReportClick:(UIButton *)sender {
    NSString *eventName = self.eventNameTextField.text;
    NSString *eventParamsStr = self.eventParamsTextField.text;
    NSDictionary *params = [self getDictionaryFromJson:eventParamsStr];
    
    // 上报实时事件，BeaconEvent对象没有设置appkey参数时，事件上报到调用start初始化接口时传入的appkey
    BeaconEvent *realTimeEvent = [BeaconEvent realTimeEventWithCode:eventName params:params];
    [BeaconReport.sharedInstance reportEvent:realTimeEvent];
}

- (IBAction)onUndirectReportClick:(UIButton *)sender {
    NSString *eventName = self.eventNameTextField.text;
    NSString *eventParamsStr = self.eventParamsTextField.text;
    NSDictionary *params = [self getDictionaryFromJson:eventParamsStr];
    // 上报普通事件,BeaconEvent对象没有设置appkey参数时，事件上报到调用start初始化接口时传入的appkey
    BeaconEvent *normalEvent = [BeaconEvent normalEventWithCode:eventName params:params];
    [BeaconReport.sharedInstance reportEvent:normalEvent];
}

- (NSDictionary *)getDictionaryFromJson:(NSString *)jsonStr {
    if (jsonStr.length == 0) {
        return [NSDictionary new];
    }
    NSError *error;
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:data
                                                           options:NSJSONReadingMutableContainers
                                                             error:&error];
    if (error) {
        self.errorLabel.text = error.localizedDescription;
        return [NSDictionary new];
    } else {
        self.errorLabel.text = nil;
    }
    return retDic;
}

@end
