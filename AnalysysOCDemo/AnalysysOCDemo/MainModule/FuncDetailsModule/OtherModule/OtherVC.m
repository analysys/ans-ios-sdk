//
//  OtherVC.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/20.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "OtherVC.h"

static NSString *const analysys_version = @"当前SDK版本";
static NSString *const analysys_network = @"上数网络环境";
static NSString *const analysys_debug_mode = @"上数调试模式";
static NSString *const analysys_encrypt_type = @"数据加密类型";
static NSString *const analysys_interval_time = @"设置上传间隔";
static NSString *const analysys_max_event_size = @"设置最大上传事件条数";
static NSString *const analysys_max_cache_size = @"设置最大缓存条数";
static NSString *const analysys_allow_time_check = @"是否允许时间校准";
static NSString *const analysys_max_diff_time_interval = @"最大时间误差";
static NSString *const analysys_track_device_id = @"是否上报设备标识";
static NSString *const analysys_crash = @"制造崩溃";
static NSString *const analysys_crash_switch = @"崩溃自动收集开关(打开/关闭)";
static NSString *const analysys_page_switch = @"页面自动收集开关(打开/关闭)";
static NSString *const analysys_all_bury_switch = @"全埋点事件自动收集开关(打开/关闭)";
static NSString *const analysys_heat_map_switch = @"热图事件自动收集开关(打开/关闭)";
static NSString *const analysys_get_preset_properties = @"获取预制属性";
static NSString *const analysys_clear_db = @"清理数据库";
static NSString *const analysys_reset = @"清除本地设置";

static NSInteger encrypt_type_switch = 0;
static NSInteger time_check = 0;
static NSInteger device_id_switch = 0;
static NSInteger crash_switch = 0;
static NSInteger page_switch = 0;
static NSInteger all_bury_switch = 0;
static NSInteger heat_map_switch = 0;

@interface OtherVC ()

@end

@implementation OtherVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *str = [self.data objectAtIndex:indexPath.row];
    
    if ([str isEqualToString:analysys_version]) {
        
        NSString *sdk_version = [AnalysysAgent SDKVersion];
        [self showTitle:str message:[NSString stringWithFormat:@"version : %@",sdk_version]];
        
    } else if ([str isEqualToString:analysys_network]) {
        
        [self showActionSheet:str];
        
    } else if ([str isEqualToString:analysys_debug_mode]) {
        
        [self showDebugMode:str];
        
    } else if ([str isEqualToString:analysys_encrypt_type]) {
        
        encrypt_type_switch += 1;
        if (encrypt_type_switch%2==0) {
            AnalysysConfig.encryptType = AnalysysEncryptAES;
            [self showTitle:str message:@"AnalysysEncryptAES"];
        } else {
            AnalysysConfig.encryptType = AnalysysEncryptAESCBC128;
            [self showTitle:str message:@"AnalysysEncryptAESCBC128"];
        }
        
    } else if ([str isEqualToString:analysys_max_diff_time_interval]) {
        
        AnalysysConfig.maxDiffTimeInterval = 60;
        [self showTitle:str message:@"60秒"];
        
    } else if ([str isEqualToString:analysys_interval_time]) {
        
        [AnalysysAgent setIntervalTime:30];
        [self showTitle:str message:@"30秒"];
        
    } else if ([str isEqualToString:analysys_max_event_size]) {
        
        [AnalysysAgent setMaxEventSize:20];
        [self showTitle:str message:@"20条"];
        
    } else if ([str isEqualToString:analysys_max_cache_size]) {
        
        [AnalysysAgent setMaxCacheSize:200];
        [self showTitle:str message:@"200条"];
        
    } else if ([str isEqualToString:analysys_allow_time_check]) {
        
        time_check += 1;
        if (time_check%2 == 0) {
            AnalysysConfig.allowTimeCheck = false;
            [self showTitle:str message:@"不允许"];
        } else {
            AnalysysConfig.allowTimeCheck = true;
            [self showTitle:str message:@"允许"];
        }
        
    } else if ([str isEqualToString:analysys_track_device_id]) {
        
        device_id_switch += 1;
        if (device_id_switch%2 == 0) {
            AnalysysConfig.autoTrackDeviceId = false;
            [self showTitle:str message:@"不上报"];
        } else {
            AnalysysConfig.autoTrackDeviceId = true;
            [self showTitle:str message:@"上报"];
        }
        
    } else if ([str isEqualToString:analysys_crash]) {
        
        NSMutableArray *arr = [NSMutableArray array];
        [arr objectAtIndex:2];
        
    } else if ([str isEqualToString:analysys_crash_switch]) {
        
        crash_switch += 1;
        AnalysysConfig.autoTrackCrash = (crash_switch % 2);
        [self showTitle:str message:(crash_switch % 2)?@"打开":@"关闭"];
        
    } else if ([str isEqualToString:analysys_page_switch]) {
        
        page_switch += 1;
        [AnalysysAgent setAutomaticCollection:(page_switch % 2)];
        [self showTitle:str message:(page_switch % 2)?@"打开":@"关闭"];
        
    } else if ([str isEqualToString:analysys_all_bury_switch]) {
        
        all_bury_switch += 1;
        [AnalysysAgent setAutoTrackClick:(all_bury_switch % 2)];
        [self showTitle:str message:(all_bury_switch % 2)?@"打开":@"关闭"];
        
    } else if ([str isEqualToString:analysys_heat_map_switch]) {
        
        heat_map_switch += 1;
        [AnalysysAgent setAutomaticHeatmap:(heat_map_switch % 2)];
        [self showTitle:str message:(heat_map_switch % 2)?@"打开":@"关闭"];
        
    } else if ([str isEqualToString:analysys_get_preset_properties]) {
        
        NSDictionary *dic = [AnalysysAgent getPresetProperties];
        [self showTitle:str message:[AnalysysJson convertToStringWithObject:dic]];
        
    } else if ([str isEqualToString:analysys_clear_db]) {
        
        [AnalysysAgent cleanDBCache];
        [self showTitle:str message:@""];
        
    } else if ([str isEqualToString:analysys_reset]) {
        
        [AnalysysAgent reset];
        [self showTitle:str message:@""];
        
    }
}

- (void)showActionSheet:(NSString *)str {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"cancle" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *a1 = [UIAlertAction actionWithTitle:@"NONE" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [AnalysysAgent setUploadNetworkType:AnalysysNetworkNONE];
        [self showTitle:str message:@"NONE"];
    }];
    UIAlertAction *a2 = [UIAlertAction actionWithTitle:@"WWAN" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [AnalysysAgent setUploadNetworkType:AnalysysNetworkWWAN];
        [self showTitle:str message:@"WWAN"];
        
    }];
    UIAlertAction *a3 = [UIAlertAction actionWithTitle:@"WIFI" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [AnalysysAgent setUploadNetworkType:AnalysysNetworkWIFI];
        [self showTitle:str message:@"WIFI"];
        
    }];
    UIAlertAction *a4 = [UIAlertAction actionWithTitle:@"ALL" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [AnalysysAgent setUploadNetworkType:AnalysysNetworkALL];
        [self showTitle:str message:@"ALL"];
        
    }];
    
    [alertController addAction:cancle];
    [alertController addAction:a1];
    [alertController addAction:a2];
    [alertController addAction:a3];
    [alertController addAction:a4];
    
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)showDebugMode:(NSString *)str {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"cancle" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *a1 = [UIAlertAction actionWithTitle:@"AnalysysDebugOff" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [AnalysysAgent setDebugMode:AnalysysDebugOff];
        [self showTitle:str message:@"AnalysysDebugOff"];
    }];
    UIAlertAction *a2 = [UIAlertAction actionWithTitle:@"AnalysysDebugOnly" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [AnalysysAgent setDebugMode:AnalysysDebugOnly];
        [self showTitle:str message:@"AnalysysDebugOnly"];
        
    }];
    UIAlertAction *a3 = [UIAlertAction actionWithTitle:@"AnalysysDebugButTrack" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [AnalysysAgent setDebugMode:AnalysysDebugButTrack];
        [self showTitle:str message:@"AnalysysDebugButTrack"];
        
    }];
    
    [alertController addAction:cancle];
    [alertController addAction:a1];
    [alertController addAction:a2];
    [alertController addAction:a3];
    
    [self presentViewController:alertController animated:true completion:nil];
}

- (NSArray *)getModuleData {
    //获取文件路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"main_module" ofType:@"json"];
    //获取文件内容
    NSString *jsonStr  = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    //将文件内容转成数据
    NSData *jaonData   = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    //将数据转成数组
    NSMutableArray *arr = [NSJSONSerialization JSONObjectWithData:jaonData options:NSJSONReadingMutableContainers error:nil];
    
    __block NSMutableArray * ret;
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([(NSString *)obj.allKeys.firstObject isEqualToString:Other]) {
            ret = [NSMutableArray arrayWithArray:[obj objectForKey:Other]];
            *stop = YES;
        }
    }];
    return ret;
}

@end
