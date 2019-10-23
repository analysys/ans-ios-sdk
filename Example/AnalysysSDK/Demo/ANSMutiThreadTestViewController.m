//
//  ANSMutiThreadTestViewController.m
//  AnalysysSDK-iOS
//
//  Created by SoDo on 2019/7/25.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSMutiThreadTestViewController.h"
#import <AnalysysSDK/AnalysysAgent.h>
#import "UnitTestCase.h"

@interface ANSMutiThreadTestViewController ()
@end

@implementation ANSMutiThreadTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)mutiThreadTest:(id)sender {
     [self asyncTest];
}

static bool asyncRun = false;
- (void)asyncTest {
    if (tempKeys == nil) {
        tempKeys = [NSMutableArray array];
        for (int i = 0; i< 20; i++) {
            [tempKeys addObject:[NSString stringWithFormat:@"key_%d", i]];
        }
    }
    asyncRun = !asyncRun;
    NSString * msg = nil;
    if (asyncRun) {
        msg = @"已开启多线程测试";
    }else {
        msg = @"已关闭多线程测试";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"tips" message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
    [alert show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        for ( ; ; ) {
            if (!asyncRun) {
                break;
            }
            [NSThread detachNewThreadSelector:@selector(testCase) toTarget:self withObject:nil];
            sleep(1.8);
        }
    });
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        for ( ; ; ) {
//            if (!asyncRun) {
//                break;
//            }
//            [NSThread detachNewThreadSelector:@selector(testCase) toTarget:self withObject:nil];
//            sleep(2.3);
//        }
//    });
}

__strong NSMutableArray *tempKeys  = nil;
- (void)testCase {
    
    // -------------------- AnalysysAgent SDK配置信息 --------------------//
    [NSThread detachNewThreadSelector:@selector(startWithConfig) toTarget:self withObject:nil];
    
    
    [NSThread detachNewThreadSelector:@selector(getPresetProperties) toTarget:self withObject:nil];
    
    
    
    // -------------------- superproperty --------------------//
    
    NSString *key = tempKeys[arc4random()%20];
    [NSThread detachNewThreadSelector:@selector(superProperty) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(regSuperProperty2) toTarget:self withObject:nil];
    
    [NSThread detachNewThreadSelector:@selector(getSuperProperty) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(getSuperProperty:) toTarget:self withObject:key];
    
    [NSThread detachNewThreadSelector:@selector(unRegisterSuperProperty:) toTarget:self withObject:key];
    
    // -------------------- track --------------------//
    NSString *trackAction = [NSString stringWithFormat:@"trackAction_%d", arc4random()%10];
    [AnalysysAgent track:trackAction];
    
    [NSThread detachNewThreadSelector:@selector(trackCase) toTarget:self withObject:nil];
    
    // -------------------- identify --------------------//
    
    [NSThread detachNewThreadSelector:@selector(identify) toTarget:self withObject:nil];
    
    [NSThread detachNewThreadSelector:@selector(getDistinctID) toTarget:self withObject:nil];
    
    // -------------------- page --------------------//
    [NSThread detachNewThreadSelector:@selector(pageViewCase) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(autoPage) toTarget:self withObject:nil];
    
    // -------------------- other --------------------//
    
    if (arc4random() % 10 == 0) {
        [AnalysysAgent reset];
    }
    if (arc4random() % 3 == 0) {
        [AnalysysAgent clearSuperProperties];
    }
    if (arc4random() % 3 == 1) {
        [AnalysysAgent flush];
    }
    
    
    
    
    
    
    // -------------------- alias --------------------//
    [NSThread detachNewThreadSelector:@selector(aliasCase) toTarget:self withObject:nil];
    
    
    // -------------------- profile --------------------//
    
    [NSThread detachNewThreadSelector:@selector(profileSet) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(profileSetOnce) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(profileIncrement) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(profileAppend) toTarget:self withObject:nil];
    
    [NSThread detachNewThreadSelector:@selector(profileUnset) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(profileDelete) toTarget:self withObject:nil];
    
    
    // -------------------- other --------------------//
    [NSThread detachNewThreadSelector:@selector(registSuperThread_0) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(registSuperThread_1) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(trackThread_0) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(pageViewThread_0) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(aliasThread_0) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(distinctThread_0) toTarget:self withObject:nil];
}

- (void)startWithConfig {
    [AnalysysAgent setDebugMode:2];
    
    NSString *appkey = @"sdktest201907";
    NSString *uploadUrl = @"https://arksdk.analysys.cn:4089";
//    int environment = arc4random() % 10;
//    if (environment == 0) {
//        appkey = @"ca715e78ae929a48";
//        uploadUrl = @"https://arksdktest.analysys.cn:4069";
//    } else if (environment == 1) {
//        appkey = @"";
//        uploadUrl = @"";
//    }
    [AnalysysAgent setUploadURL:uploadUrl];
    
    AnalysysConfig.appKey = appkey;
    AnalysysConfig.channel = arc4random() % 2 == 0 ? nil : @"App Store";
    //    AnalysysConfig.baseUrl = @"arkpaastest.analysys.cn";
    AnalysysConfig.autoProfile = arc4random()%2;
    AnalysysConfig.autoInstallation = arc4random()%2;
    AnalysysConfig.encryptType = arc4random()%3;
    //  使用配置信息初始化SDK
    [AnalysysAgent startWithConfig:AnalysysConfig];
    
    [AnalysysAgent setVisitorDebugURL:@"wss://arksdk.analysys.cn:4091"];
    [AnalysysAgent setVisitorConfigURL:@"https://arksdk.analysys.cn:4089"];
    
    [AnalysysAgent setAutomaticHeatmap:arc4random()%2];
    
    [AnalysysAgent setAutomaticCollection:arc4random()%2];
    
    if (arc4random() % 5 == 0) {
        [AnalysysAgent setIgnoredAutomaticCollectionControllers:@[@"ANSDemoController",@"NextViewController"]];
    } else {
        [AnalysysAgent setIgnoredAutomaticCollectionControllers:@[]];
    }
    
    [AnalysysAgent setIntervalTime:10];
    [AnalysysAgent setMaxEventSize:5];

//    [AnalysysAgent setMaxCacheSize:10];
    
    AnalysysDebugMode mode = [AnalysysAgent debugMode];
    int cacheSize = [AnalysysAgent maxCacheSize];
    NSString *version = [AnalysysAgent SDKVersion];
    [AnalysysAgent flush];
}

- (void)getPresetProperties {
    [AnalysysAgent getPresetProperties];
}


#pragma mark - superproperty

- (void)superProperty {
    NSMutableArray *keys = [NSMutableArray array];
    for (int i = 0; i< 20; i++) {
        [keys addObject:[NSString stringWithFormat:@"key_%d", i]];
    }
    NSString *key = keys[arc4random()%20];
    NSDictionary *superProperties = @{key: @"bbb"};
    [AnalysysAgent registerSuperProperties:superProperties];
    
    
//    [UnitTestCase superProperty_0];
}

- (void)regSuperProperty2 {
    [UnitTestCase superProperty_1];
}

- (void)getSuperProperty {
    [UnitTestCase superProperty_2];
}

- (void)getSuperProperty:(NSString *)key{
    [UnitTestCase superProperty_4:key];
}

- (void)unRegisterSuperProperty:(NSString *)key{
    [UnitTestCase superProperty_3:key];
}

#pragma mark - track

- (void)trackCase {
    [UnitTestCase track_0];
//    [UnitTestCase track_1];
    [UnitTestCase track_2];
//    [UnitTestCase track_3];
//    [UnitTestCase track_4];
//    [UnitTestCase track_5];
//    [UnitTestCase track_6];
//    [UnitTestCase track_7];
//    [UnitTestCase track_8];
}

#pragma mark - PageView

- (void)pageViewCase {
    [UnitTestCase pageView_0];
//    [UnitTestCase pageView_1];
    [UnitTestCase pageView_2];
//    [UnitTestCase pageView_3];
//    [UnitTestCase pageView_4];
//    [UnitTestCase pageView_5];
//    [UnitTestCase pageView_6];
//    [UnitTestCase pageView_7];
}

- (void)autoPage {
    BOOL autoPageTrack = [AnalysysAgent isViewAutoTrack];
}

#pragma mark - id

- (void)aliasCase {
//    [UnitTestCase alias_0];
//    [UnitTestCase alias_1];
    [UnitTestCase alias_2];
}

- (void)identify {
    [UnitTestCase alias_3];
//    [UnitTestCase alias_4];
}

- (void)getDistinctID {
    NSString *distinctID = [AnalysysAgent getDistinctId];
}

#pragma mark - profileset

- (void)profileSet {
//    [UnitTestCase profileSet_0];
//    [UnitTestCase profileSet_1];
//    [UnitTestCase profileSet_2];
    [UnitTestCase profileSet_3];
//    [UnitTestCase profileSet_4];
//    [UnitTestCase profileSet_5];
//    [UnitTestCase profileSet_6];
}

- (void)profileSetOnce {
//    [UnitTestCase profileSetOnce_0];
//    [UnitTestCase profileSetOnce_1];
//    [UnitTestCase profileSetOnce_2];
    [UnitTestCase profileSetOnce_3];
//    [UnitTestCase profileSetOnce_4];
//    [UnitTestCase profileSetOnce_5];
//    [UnitTestCase profileSetOnce_6];
}

- (void)profileAppend {
//    [UnitTestCase profileAppend_0];
//    [UnitTestCase profileAppend_1];
//    [UnitTestCase profileAppend_2];
    [UnitTestCase profileAppend_3];
//    [UnitTestCase profileAppend_4];
//    [UnitTestCase profileAppend_5];
//    [UnitTestCase profileAppend_6];
}

- (void)profileIncrement {
//    [UnitTestCase profileIncrement_0];
//    [UnitTestCase profileIncrement_1];
//    [UnitTestCase profileIncrement_2];
    [UnitTestCase profileIncrement_3];
//    [UnitTestCase profileIncrement_4];
//    [UnitTestCase profileIncrement_5];
//    [UnitTestCase profileIncrement_6];
}

- (void)profileDelete {
    [AnalysysAgent profileDelete];
}

- (void)profileUnset {
    [AnalysysAgent profileUnset:@""];
    
    [AnalysysAgent profileUnset:@"Hobby"];
}

#pragma mark - 其他线程case

- (void)registSuperThread_0 {
    [AnalysysAgent registerSuperProperties:@{@"dddd": @"aaa"}];
}

- (void)registSuperThread_1 {
    NSArray *hobby = @[@"a", @"b"];
    [AnalysysAgent registerSuperProperty:@"kkkk" value:hobby];
    id obj = [AnalysysAgent getSuperProperty:@"kkk"];
    NSLog(@"%@", obj);
}

- (void)trackThread_0 {
    [AnalysysAgent track:@"thread" properties:nil];
}

- (void)pageViewThread_0 {
    [AnalysysAgent pageView:nil properties:@{@"page": @"HomePage"}];
}

- (void)aliasThread_0 {
    [AnalysysAgent alias:@"lisi" originalId:@"zhangsan"];
}

- (void)distinctThread_0 {
    [AnalysysAgent identify:[[NSUUID UUID] UUIDString]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
