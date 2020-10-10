//
//  ANSConfigVC.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/17.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "ANSConfigVC.h"
#import "AnalysysDataCache.h"

@interface ANSConfigVC ()
- (IBAction)changeConfig:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *appkey_tf;
@property (weak, nonatomic) IBOutlet UITextField *channel_tf;
@property (weak, nonatomic) IBOutlet UITextField *upload_url_tf;
@property (weak, nonatomic) IBOutlet UITextField *debug_url_tf;
@property (weak, nonatomic) IBOutlet UITextField *config_url_tf;
@end

@implementation ANSConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"修改配置";
    
    self.appkey_tf.text = [AnalysysDataCache get_appkey]?:@"heatmaptest0916";
    self.channel_tf.text = [AnalysysDataCache get_channel]?:@"App Store";
    self.upload_url_tf.text = [AnalysysDataCache get_upload_url]?:@"http://192.168.220.105:8089";
    self.debug_url_tf.text = [AnalysysDataCache get_debug_url]?:@"ws://192.168.220.105:9091";
    self.config_url_tf.text = [AnalysysDataCache get_config_url]?:@"http://192.168.220.105:8089";
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)resetConfig:(id)sender {
    
    [AnalysysDataCache set_appkey:@"heatmaptest0916"];
    [AnalysysDataCache set_channel:@"App Store"];
    [AnalysysDataCache set_upload_url:@"http://192.168.220.105:8089"];
    [AnalysysDataCache set_debug_url:@"ws://192.168.220.105:9091"];
    [AnalysysDataCache set_config_url:@"http://192.168.220.105:8089"];
    
    self.appkey_tf.text = [AnalysysDataCache get_appkey]?:@"heatmaptest0916";
    self.channel_tf.text = [AnalysysDataCache get_channel]?:@"App Store";
    self.upload_url_tf.text = [AnalysysDataCache get_upload_url]?:@"http://192.168.220.105:8089";
    self.debug_url_tf.text = [AnalysysDataCache get_debug_url]?:@"ws://192.168.220.105:9091";
    self.config_url_tf.text = [AnalysysDataCache get_config_url]?:@"http://192.168.220.105:8089";
    
    [self showTitle:@"恢复默认配置,杀掉app，重启生效" message:[NSString stringWithFormat:@"%@",@{@"AppKey" : @"heatmaptest0916", @"Channel" : @"App Store", @"UploadURL" : @"http://192.168.220.105:8089", @"DebugURL" : @"ws://192.168.220.105:9091", @"ConfigURL" : @"http://192.168.220.105:8089"}]];
}

- (IBAction)changeConfig:(id)sender {
    if (self.appkey_tf.text.length == 0) {
        [AnalysysHUD showTitle:@"提示" message:@"请输入AppKey"];
        return;
    } else if (self.channel_tf.text.length == 0) {
        [AnalysysHUD showTitle:@"提示" message:@"请输入Channel"];
        return;
    } else if (self.upload_url_tf.text.length == 0) {
        [AnalysysHUD showTitle:@"提示" message:@"请输入UploadURL"];
        return;
    } else if (self.debug_url_tf.text.length == 0) {
        [AnalysysHUD showTitle:@"提示" message:@"请输入DebugURL"];
        return;
    } else if (self.config_url_tf.text.length == 0) {
        [AnalysysHUD showTitle:@"提示" message:@"请输入ConfigURL"];
        return;
    }
    
    [AnalysysDataCache set_appkey:self.appkey_tf.text];
    [AnalysysDataCache set_channel:self.channel_tf.text];
    [AnalysysDataCache set_upload_url:self.upload_url_tf.text];
    [AnalysysDataCache set_debug_url:self.debug_url_tf.text];
    [AnalysysDataCache set_config_url:self.config_url_tf.text];
    
    
    [AnalysysHUD showTitle:@"提示" message:@"配置修改成功,杀掉app，重启生效"];
    [self.navigationController popViewControllerAnimated:YES];
    
}
@end
