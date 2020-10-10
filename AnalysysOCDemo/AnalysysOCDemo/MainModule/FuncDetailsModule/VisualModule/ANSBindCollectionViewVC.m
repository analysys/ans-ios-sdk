//
//  ANSBindCollectionViewVC.m
//  AnalysysSDKDemo
//
//  Created by xiao xu on 2020/2/11.
//  Copyright © 2020 shaochong du. All rights reserved.
//

#import "ANSBindCollectionViewVC.h"
#import "ANSBindCollectionCell.h"
#import "ANSBindCollectionHeaderFooterView.h"
@interface ANSBindCollectionViewVC () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic,weak) UICollectionView *ans_collection;
@end

@implementation ANSBindCollectionViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view from its nib.
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    UICollectionView *ans_collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:layout];
    ans_collection.allowsMultipleSelection = YES;
    ans_collection.backgroundColor = [UIColor whiteColor];
    ans_collection.delegate = self;
    ans_collection.dataSource = self;
    [ans_collection registerNib:[UINib nibWithNibName:@"ANSBindCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"ANSBindCollectionCell"];
    [ans_collection registerNib:[UINib nibWithNibName:@"ANSBindCollectionHeaderFooterView" bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ANSBindCollectionHeaderFooterView"];
    
    [self.view addSubview:ans_collection];
    self.ans_collection = ans_collection;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 30;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.view.frame.size.width - 20, 40);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        ANSBindCollectionHeaderFooterView *collectionHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ANSBindCollectionHeaderFooterView" forIndexPath:indexPath];
        collectionHeader.sectionLab.text = [NSString stringWithFormat:@"Section:%ld",indexPath.section];
        reusableView = collectionHeader;
    }
    
    return reusableView;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ANSBindCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ANSBindCollectionCell" forIndexPath:indexPath];
    cell.titleLab.text = [NSString stringWithFormat:@"section:%ld-row:%ld",indexPath.section,indexPath.row];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake(100, 100);
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
//    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

@end
