//
//  MyViewController.m
//  EGAnalyticsDemo
//
//  Created by analysys on 2018/2/6.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "EGDemoController.h"

#import <AnalysysAgent/AnalysysAgent.h>
#import "NextViewController.h"
#import "DemoCollectionViewCell.h"
#import "DemoCollectionHeaderView.h"
#import "UIColor+Transform.h"

#import "EGWebViewController.h"
#import "EGWKWebViewController.h"

static NSString *const kCategory = @"category";
static NSString *const kInterface = @"interface";
static NSString *const kSubArray = @"subArray";
static NSString *const kBackgroundColor = @"backgroundColor";

@interface EGDemoController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *headerArray;
@property (nonatomic, strong) NSArray *dataSourceArray;

@end

@implementation EGDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createDataSource];
    
    [self setHeaderView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.collectionView.collectionViewLayout = layout;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"DemoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"DemoCollectionViewCell"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"DemoCollectionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createDataSource {
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"DataSource.plist"];
    self.dataSourceArray = [NSArray arrayWithContentsOfFile:path];
//    NSLog(@"%@",self.dataSourceArray);
}

- (void)setHeaderView {
    
    CGFloat width = self.view.frame.size.width;
    UILabel *tipLabel = [[UILabel alloc] init];
    UIFont *font = [UIFont systemFontOfSize:18];
    tipLabel.font = font;
    tipLabel.numberOfLines = 0;
    tipLabel.textColor = [UIColor redColor];
    tipLabel.backgroundColor = [UIColor colorWithRed:159/255.0 green:255/255.0 blue:204/255.0 alpha:1.0];
    NSString *str = @"紫色功能表示接口调用立即触发上传；灰色按钮表示只进行设置，不触发上传。";
    tipLabel.text = str;
    NSDictionary *attr = @{NSFontAttributeName:font};
    CGRect textRect = [str boundingRectWithSize:CGSizeMake(width - 5*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];
    CGFloat textHeight = textRect.size.height;
    CGFloat viewHeight = textHeight + 5*2;
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, -viewHeight, self.view.frame.size.width, viewHeight)];
    tipLabel.frame = CGRectMake(10, 5, self.view.frame.size.width - 10*2, textHeight);
    [topView addSubview:tipLabel];
    [self.collectionView addSubview:topView];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(viewHeight, 0, 0, 0);
}

#pragma mark *** UICollectionViewDelegateFlowLayout ***

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake((self.view.frame.size.width - 30)/2.0, 40);
    return size;
}


#pragma mark *** Header 设置 ***

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.view.frame.size.width - 20, 40);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        DemoCollectionHeaderView *collectionHeader = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView" forIndexPath:indexPath];
        NSDictionary *dic = self.dataSourceArray[indexPath.section];
        collectionHeader.categoryLabel.text = dic[kCategory];
        
        reusableView = collectionHeader;
    }
    
    return reusableView;
}

#pragma mark *** tips ***

- (void)showAlertView:(NSString *)tips {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"tips" message:tips delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}

#pragma mark *** UICollectionViewDataSource ***
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSDictionary *dic = self.dataSourceArray[section];
    NSArray *subTypeArray = dic[kSubArray];
    return subTypeArray.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSourceArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DemoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DemoCollectionViewCell" forIndexPath:indexPath];
    NSDictionary *dic = self.dataSourceArray[indexPath.section];
    NSArray *subTypeArray = dic[kSubArray];
    NSDictionary *subTypeDic = subTypeArray[indexPath.row];
    cell.titleLabel.text = subTypeDic[kInterface];
    cell.titleLabel.backgroundColor = [UIColor colorWithHexString:subTypeDic[kBackgroundColor]];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                //  获取SDK版本号
                NSString *version = [AnalysysAgent SDKVersion];
                [self showAlertView:[NSString stringWithFormat:@"当前SDK版本号:%@",version]];
                break;
            }
            case 1: {
                //  设置debug模式
                NSInteger debugMode = arc4random() % 3;
                [AnalysysAgent setDebugMode:debugMode];
                if (debugMode == 0) {
                    [self showAlertView:@"非debug模式"];
                } else if (debugMode == 1) {
                    [self showAlertView:@"debugOnly模式"];
                } else {
                    [self showAlertView:@"debugTrack模式"];
                }
                break;
            }
            case 2: {
                //  自定义服务器地址
                //  可用于调试，请谨慎设置，或设置错误可能导致上传失败
                NSString *serverUrl = @"https://serverDomain";
                [AnalysysAgent setUploadURL:serverUrl];
                [self showAlertView:[NSString stringWithFormat:@"修改上传服务器地址:%@",serverUrl]];
                break;
            }
            case 3: {
                //  设置上传间隔时间
                NSInteger flushInterval = arc4random() % 10 + 5;
                [AnalysysAgent setIntervalTime:flushInterval];
                [self showAlertView:[NSString stringWithFormat:@"上传间隔:%ld",flushInterval]];
                break;
            }
            case 4: {
                //  设置触发上传的事件累积条数
                NSInteger bulkSize = arc4random() % 10 + 5;
                [AnalysysAgent setMaxEventSize:bulkSize];
                [self showAlertView:[NSString stringWithFormat:@"累积触发条数:%ld",bulkSize]];
                break;
            }
            case 5: {
                //  设置本地最多缓存数据的条数
                NSInteger cacheSize = arc4random() % 1000 + 5;
                [AnalysysAgent setMaxCacheSize:cacheSize];
                [self showAlertView:[NSString stringWithFormat:@"最多缓存条数:%ld",cacheSize]];
                break;
            }
            case 6: {
                //  立即上传数据接口  flush
                [AnalysysAgent track:[NSString stringWithFormat:@"randomEvent_%d",arc4random()%100]];
                [AnalysysAgent flush];
                [self showAlertView:@"测试 随机上传一条数据"];
                break;
            }
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {
                //  设置多个通用属性。VIP用户、hobby作为当前所有事件的通用属性
                [AnalysysAgent registerSuperProperties:@{@"VIPLevel":@"Silver",
                                                          @"Hobby":@[@"Singing",@"Reading",@"Dacing"]
                                                          }];
                [self showAlertView:[NSString stringWithFormat:@"当前通用属性:\n%@",[AnalysysAgent getSuperProperties]]];
                break;
            }
            case 1: {
                //  获取已设置的通用属性
                id value = [AnalysysAgent getSuperProperty:@"Hobby"];
                [self showAlertView:[NSString stringWithFormat:@"通用属性:VIPLevel \n 值:%@",value]];
                break;
            }
            case 2: {
                //  设置单个通用属性
                [AnalysysAgent registerSuperProperty:@"Birthday" value:@"2000-01-01"];
                [self showAlertView:@"追加通用属性:Birthday \n 值:2000-01-01"];
                break;
            }
            case 3: {
                //  删除已经设置的用户年龄属性
                [AnalysysAgent unRegisterSuperProperty:@"Birthday"];
                [self showAlertView:@"删除通用属性:Birthday"];
                break;
            }
            case 4: {
                //  清除所有已经设置的通用属性
                [AnalysysAgent clearSuperProperties];
                [self showAlertView:@"清除所有通用属性"];
                break;
            }
            case 5: {
                [self showAlertView:[NSString stringWithFormat:@"当前通用属性:\n%@",[AnalysysAgent getSuperProperties]]];
                break;
            }
            default:
                break;
        }
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0: {
                if ([AnalysysAgent isViewAutoTrack]) {
                    //  关闭页面自动采集
                    [AnalysysAgent setAutomaticCollection:NO];
                    [self showAlertView:@"已关闭页面自动采集功能"];
                } else {
                    //  打开页面自动采集
                    [AnalysysAgent setAutomaticCollection:YES];
                    [self showAlertView:@"已打开页面自动采集功能"];
                }
                break;
            }
            case 1: {
                //  忽略“NextViewController”页面的自动采集
                [AnalysysAgent setIgnoredAutomaticCollectionControllers:@[@"NextViewController"]];
                [self showAlertView:@"忽略 NextViewController 页面自动采集"];
                break;
            }
            case 2: {
                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                NextViewController * nextVC = [sb instantiateViewControllerWithIdentifier:@"NextViewController"];
                nextVC.hidesBottomBarWhenPushed = YES;
                if (![AnalysysAgent isViewAutoTrack]) {
                    nextVC.ignoredAutoCollection = YES;
                }
                [self.navigationController pushViewController:nextVC animated:YES];
                break;
            }
            default:
                break;
        }
    } else if (indexPath.section == 3) {
        //  为了方便查看现使用随机事件做Demo
        NSString *event = [NSString stringWithFormat:@"buy_%d",arc4random()%100];
        switch (indexPath.row) {
            case 0: {
                [AnalysysAgent track:event];
                [self showAlertView:[NSString stringWithFormat:@"产生事件:%@",event]];
                break;
            }
            case 1: {
                //  追踪用户收藏、加入购物车、购买等事件
                NSInteger productId = 1234;   //  商品标识
                NSString *productCategory = @"iPhone X";  //  商品类型
                BOOL hasStocks = YES;    //  是否有库存
                CGFloat price = 5288.0; //  价格
                NSDictionary *properties = @{@"productId": [NSNumber numberWithInteger:productId],
                                             @"productCategory": productCategory,
                                             @"hasStocks": [NSNumber numberWithBool:hasStocks],
                                             @"price": [NSNumber numberWithFloat:price]
                                             };
                [AnalysysAgent track:event properties:properties];
                [self showAlertView:[NSString stringWithFormat:@"当前事件:%@ 属性:%@",event,properties]];
                break;
            }
            case 2: {
                //  用户打开新闻详情页面
                [AnalysysAgent pageView:@"NewsDetailViewController"];
                [self showAlertView:@"当前页面:NewsDetailViewController"];
                break;
            }
            case 3: {
                //  新闻产品，可以追踪用户浏览新闻页面
                UInt64 newsId = 1024;   //  新闻标识
                NSArray *tags = @[@"科技", @"苹果", @"工程师"];  //  新闻标签
                CGFloat pageDur = 10.0; //  页面浏览时长
                NSDictionary *properties = @{@"newsId": [NSNumber numberWithUnsignedInteger:newsId],
                                             @"tags": tags,
                                             @"pageDur": [NSNumber numberWithFloat:pageDur]
                                             };
                //  记录当前打开页面的基本信息，如新闻标签、新闻标识、页面浏览时长等属性
                [AnalysysAgent pageView:@"NewsDetailViewController" properties:properties];
                [self showAlertView:[NSString stringWithFormat:@"当前页面:pageOne 属性:%@",properties]];
                break;
            }
            default:
                break;
        }
    } else if (indexPath.section == 4) {
        switch (indexPath.row) {
            case 0: {
                //  为了方便查看现使用随机id做Demo
                NSString *distinct_id = [NSString stringWithFormat:@"userName_%d",arc4random()%1000];
                [AnalysysAgent identify:distinct_id];
                [self showAlertView:[NSString stringWithFormat:@"当前标识:%@",distinct_id]];
                break;
            }
            case 1: {
                //  一班同学升学时,调换班级到三班,
                [AnalysysAgent alias:@"sanban" originalId:@"yiban"];
                [self showAlertView:@"当前身份标识：sanban 原身份标识:yiban"];
                break;
            }
            case 2: {
                //  清除本地现有的设置,包括id和通用属性
                [AnalysysAgent reset];
                [self showAlertView:@"已清除本地所有distinct_id、alias_id、superProperties"];
                break;
            }
            default:
                break;
        }
    } else if (indexPath.section == 5) {
        switch (indexPath.row) {
            case 0: {
                //  $开头字符为预定义字段
                //  统计用户昵称和爱好信息
                NSDictionary *properties = @{@"nickName":@"小叮当",@"hobby":@[@"Singing", @"Dancing"]};
                [AnalysysAgent profileSet:properties];
                [self showAlertView:[NSString stringWithFormat:@"设置profile为:\n%@",properties]];
                break;
            }
            case 1: {
                //  设置用户的 Job 是 Engineer
                [AnalysysAgent profileSet:@"Job" propertyValue:@"Engineer"];
                [self showAlertView:@"Job: Engineer"];
                break;
            }
            case 2: {
                //  统计应用激活时间和首次登陆时间
                NSDictionary *properties = @{@"activationTime": @"1521594686781", @"loginTime": @"1521594792345"};
                [AnalysysAgent profileSetOnce:properties];
                [self showAlertView:[NSString stringWithFormat:@"首次安装启动日期：%@",properties]];
                break;
            }
            case 3: {
                //  统计用户的出生日期
                [AnalysysAgent profileSetOnce:@"Birthday" propertyValue:@"1995-01-01"];
                [self showAlertView:@"Birthday: 1995-01-01"];
                break;
            }
            case 4: {
                //   增加用户登录次数/积分
                NSDictionary *dic = @{@"UseCount": [NSNumber numberWithInt:1],@"Point": [NSNumber numberWithInt:10]};
                [AnalysysAgent profileIncrement:dic];
                [self showAlertView:[NSString stringWithFormat:@"%@",dic]];
                break;
            }
            case 5: {
                //  增加用户消费金额
                [AnalysysAgent profileIncrement:@"Consume" propertyValue:@10];
                [self showAlertView:@"Consume: 10"];
                break;
            }
            case 6: {
                //  增加用户购买过的书籍，属性 "Books" 为: ["西游记", "三国演义"]，属性 "Drinks" 为："orange juice"
                [AnalysysAgent profileAppend:@{@"Books": @[@"西游记", @"三国演义"],@"Drinks": @"orange juice"}];
//                [AnalysysAgent profileAppend:@"Drinks" value:@"orange juice"];
                [self showAlertView:@"Books: 西游记,三国演义；Drinks：orange juice"];
                break;
            }
            case 7: {
                //  再次设定该属性，属性 "Books" 为: ["西游记", "三国演义", "红楼梦", "水浒传"]
                [AnalysysAgent profileAppend:@"Books" propertyValue:[NSSet setWithObjects:@"红楼梦", @"水浒传", nil]];
                [self showAlertView:@"Books: 红楼梦,水浒传"];
                break;
            }
            case 8: {
                //  删除用户的 hobby 属性
                [AnalysysAgent profileUnset:@"hobby"];
                [self showAlertView:@"删除 hobby 属性"];
                break;
            }
            case 9: {
                //  清除已设置的所有用户属性
                [AnalysysAgent profileDelete];
                [self showAlertView:@"删除profile"];
                break;
            }
            default:
                break;
        }
    }  else if (indexPath.section == 6) {
        switch (indexPath.row) {
            case 0: {
                EGWebViewController *webView = [[EGWebViewController alloc] initWithNibName:@"EGWebViewController" bundle:nil];
                webView.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:webView animated:YES];
                break;
            }
            case 1: {
                EGWKWebViewController *wkWebView = [[EGWKWebViewController alloc] initWithNibName:@"EGWKWebViewController" bundle:nil];
                wkWebView.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:wkWebView animated:YES];
                break;
            }
            default:
                break;
        }
    }
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
