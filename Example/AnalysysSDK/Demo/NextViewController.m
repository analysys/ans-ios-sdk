//
//  ThirdViewController.m
//  EGAnalyticsDemo
//
//  Created by analysys on 2018/2/3.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "NextViewController.h"
#import <AnalysysSDK/AnalysysAgent.h>
#import "ANSDemoViewController.h"
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerItem.h>
#import <AVFoundation/AVPlayerLayer.h>
#import <StoreKit/StoreKit.h>
#import "PageDetailViewController.h"

@interface NextViewController () <ANSAutoPageTracker, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIDocumentInteractionControllerDelegate>


@property (nonatomic,strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) AVPlayer *player;

@property (weak, nonatomic) IBOutlet UILabel *tapGestureLabel;
@property (weak, nonatomic) IBOutlet UIImageView *longGestureImage;

@property (nonatomic, strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIBarButtonItem *btn0 = [[UIBarButtonItem alloc] initWithTitle:@"相册"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(scanAction)];
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithTitle:@"打开pdf"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(loginAction)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:btn0, btn1, nil];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    self.tapGestureLabel.userInteractionEnabled = YES;
    [self.tapGestureLabel addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longTapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureAction:)];
    self.longGestureImage.userInteractionEnabled = YES;
    [self.longGestureImage addGestureRecognizer:longTapGesture];
    
    self.textView.inputAccessoryView = [self keyboardToolbar];;
}


- (void)dealloc {
    
    [self.timer invalidate];
    self.timer = nil;
}

- (void)scanAction {
    NSLog(@"scanAction");
    
    [self showSystemPhoto];
}

- (void)loginAction {
    NSLog(@"loginAction");
    UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:[[NSBundle mainBundle] URLForResource:@"PAAS iOS SDK v4.3.4使用说明" withExtension:@"pdf"]];
    documentController.delegate = self;
    [documentController presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tap {
    NSLog(@"label tapped");
    
//    if (!self.timer) {
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
//    }
}

- (void)longGestureAction:(UILongPressGestureRecognizer *)longPress {
    NSLog(@"image long press");
}

- (void)timerAction:(NSTimer *)timer {
    NSLog(@"timer aciton");
}
- (IBAction)segmentAction:(UISegmentedControl *)sender {
    NSLog(@"segment");
}
- (IBAction)stepperAction:(id)sender {
    NSLog(@"stepper");
}
- (IBAction)sliderAction:(id)sender {
    NSLog(@"slider");
}
- (IBAction)switch1Action:(id)sender {
    NSLog(@"switch 1");
}
- (IBAction)switch2Action:(id)sender {
    NSLog(@"switch 2");
}
- (IBAction)tag1BtnAction:(UIButton *)sender {
    NSLog(@"tag 1 button");
}
- (IBAction)tag2BtnAction:(UIButton *)sender {
    NSLog(@"tag 2 button");
    
    if (@available(iOS 10.3, *)) {
        [SKStoreReviewController requestReview];
    } else {
        // Fallback on earlier versions
    }
}
- (IBAction)pagecontrolAction:(id)sender {
    NSLog(@"pagecontrol");
}

- (void)nextTextField {
    NSLog(@"nextAction");
}

- (void)prevTextField {
    NSLog(@"prevTextField");
}

- (void)textFieldDone {
    NSLog(@"textFieldDone");
}

- (UIToolbar *)keyboardToolbar {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 35)];
    toolbar.tintColor = [UIColor blueColor];
    toolbar.backgroundColor = [UIColor yellowColor];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(nextTextField)];
    UIBarButtonItem *prevButton = [[UIBarButtonItem alloc] initWithTitle:@"上一步" style:UIBarButtonItemStylePlain target:self action:@selector(prevTextField)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(textFieldDone)];
    toolbar.items = @[nextButton, prevButton, space, bar];
    return toolbar;
}

- (IBAction)userAgentTest:(id)sender {
//    NSString *hybridId = @" AnalysysAgent/Hybrid";
//    NSString *agentKey = @"UserAgent";
//    UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectZero];
//    NSString *userAgent = [web stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
//    userAgent = [userAgent stringByAppendingString:hybridId];
//    NSDictionary *userAgentDict = @{agentKey: userAgent};
//    //  将字典内容注册到NSUserDefaults中
//    [[NSUserDefaults standardUserDefaults] registerDefaults:userAgentDict];
//    web = nil;
    
    PageDetailViewController *detail = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"PageDetailViewController"];
    [self presentViewController:detail animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.ignoredAutoCollection) {
        [AnalysysAgent pageView:@"page:自定义页面事件"];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - ANSAutoPageTracker

- (NSDictionary *)registerPageProperties {
//    NSMutableString *string = [NSMutableString string];
//    for (int i = 0; i < 8192; i++) {
//        [string appendString:@"a"];
//    }
    return @{@"$title": @"NextPage", @"id": @""};
}

- (NSString *)registerPageUrl {
    return @"registerPageUrl 第三页";
}

#pragma mark - other

- (IBAction)backRootVC:(id)sender {
    ANSDemoViewController *vc = [[ANSDemoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 相册

- (UIImagePickerController *)imagePickerController{
    if (_imagePickerController == nil) {
        _imagePickerController = [[UIImagePickerController alloc]init];
        _imagePickerController.delegate = self;
        _imagePickerController.allowsEditing = YES;
    }
    return _imagePickerController;
}

- (void)showSystemPhoto {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选取图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }];
    
    UIAlertAction *photosAlbumAction = [UIAlertAction actionWithTitle:@"图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    //判断是否支持相机
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alert addAction:cameraAction];
    }
    [alert addAction:photosAlbumAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
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
