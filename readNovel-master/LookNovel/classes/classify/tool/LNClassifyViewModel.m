//
//  LNClassifyViewModel.m
//  LookNovel
//
//  Created by wangchengshan on 2019/5/15.
//  Copyright © 2019 wcs Co.,ltd. All rights reserved.
//

#import "LNClassifyViewModel.h"
#import "LNAPI.h"
#import "LNClassifyListViewController.h"
#import "LNSearchViewController.h"

@implementation LNClassifyViewModel

- (void)getAllClassify
{
//    [self loadapi];
    [MBProgressHUD showWaitingViewText:nil detailText:nil inView:nil];
    [LNAPI getAllClassifyListComplete:^(NSDictionary *result, BOOL cache, NSError *error) {
        NSMutableArray *dataArray = [NSMutableArray array];
        NSMutableArray *rightArray = [NSMutableArray array];
        NSArray *maleArr = [result objectForKey:@"male"];
        if (maleArr.count) {
            LNClassifyGroupModel *group = [[LNClassifyGroupModel alloc] init];
            group.name = [self nameForKey:@"male"];
            group.key = @"male";
            [rightArray addObject:[NSArray modelArrayWithClass:[LNClassifyModel class] json:maleArr]];
            group.selected = NO;
            [dataArray addObject:group];
        }
        NSArray *femaleArr = [result objectForKey:@"female"];
        if (femaleArr.count) {
            LNClassifyGroupModel *group = [[LNClassifyGroupModel alloc] init];
            group.name = [self nameForKey:@"female"];
            group.key = @"female";
            [rightArray addObject:[NSArray modelArrayWithClass:[LNClassifyModel class] json:femaleArr]];
            group.selected = NO;
            [dataArray addObject:group];
        }
//        NSArray *pressArr = [result objectForKey:@"press"];
//        if (pressArr.count) {
//            LNClassifyGroupModel *group = [[LNClassifyGroupModel alloc] init];
//            group.name = [self nameForKey:@"press"];
//            group.key = @"press";
//            [rightArray addObject:[NSArray modelArrayWithClass:[LNClassifyModel class] json:pressArr]];
//            group.selected = NO;
//            [dataArray addObject:group];
//        }
        
        LNClassifyGroupModel *first = (LNClassifyGroupModel *)dataArray.firstObject;
        first.selected = YES;
        self.lastGroupModel = first;
        self.leftDataArray = dataArray;
        self.rightDataArray = rightArray;
        [self reloadData];
        [MBProgressHUD dismissHUD];
    }];
}

-(void)loadapi
{
    // 1.获得请求管理者
          static AFHTTPSessionManager *mgr = nil;
          static dispatch_once_t onceToken;
          dispatch_once(&onceToken, ^{
              mgr = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
              mgr.requestSerializer = [AFJSONRequestSerializer serializer];
              mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json", @"text/plain", @"text/javascript", nil];
          });
        mgr.responseSerializer=[AFHTTPResponseSerializer serializer];
          [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
          
          // 2.发送GET请求
    NSString* urlclssify=@"http://api.smaoxs.com/book/by-categories?gender=male&major=玄幻&start=0&limit=50";
    NSString *encodedValue = [urlclssify stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

          [mgr GET:[NSString stringWithFormat:@"%@", encodedValue] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
              
              NSJSONSerialization *object = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
              NSDictionary *dict = (NSDictionary *)object;
//              NSArray* countArr=dict[@"books"];

              NSMutableArray *dataArray = [NSMutableArray array];
              NSMutableArray *rightArray = [NSMutableArray array];
              NSLog(@"");
              NSArray *maleArr = [dict objectForKey:@"books"];
              if (maleArr.count) {
                  LNClassifyGroupModel *group = [[LNClassifyGroupModel alloc] init];
                  group.name = [self nameForKey:@"male"];
                  group.key = @"male";
                  [rightArray addObject:[NSArray modelArrayWithClass:[LNClassifyModel class] json:maleArr]];
                  group.selected = NO;
                  [dataArray addObject:group];
              }
              NSArray *femaleArr = [dict objectForKey:@"books"];
              if (femaleArr.count) {
                  LNClassifyGroupModel *group = [[LNClassifyGroupModel alloc] init];
                  group.name = [self nameForKey:@"female"];
                  group.key = @"female";
                  [rightArray addObject:[NSArray modelArrayWithClass:[LNClassifyModel class] json:femaleArr]];
                  group.selected = NO;
                  [dataArray addObject:group];
              }
//              NSArray *pressArr = [result objectForKey:@"press"];
//              if (pressArr.count) {
//                  LNClassifyGroupModel *group = [[LNClassifyGroupModel alloc] init];
//                  group.name = [self nameForKey:@"press"];
//                  group.key = @"press";
//                  [rightArray addObject:[NSArray modelArrayWithClass:[LNClassifyModel class] json:pressArr]];
//                  group.selected = NO;
//                  [dataArray addObject:group];
//              }
              
              LNClassifyGroupModel *first = (LNClassifyGroupModel *)dataArray.firstObject;
              first.selected = YES;
//              self.lastGroupModel = first;
//              self.leftDataArray = dataArray;
//              self.rightDataArray = rightArray;
//              [self reloadData];
              
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"");

          }];
    
}
- (NSString *)nameForKey:(NSString *)key
{
    if ([key isEqualToString:@"male"])
        return @"男生";
    else if ([key isEqualToString:@"female"])
        return @"女生";
    else if ([key isEqualToString:@"press"])
        return @"出版物";
    else
        return @"";
}

- (void)changeGroupAtIndex:(NSInteger)index needScroll:(BOOL)need
{
    LNClassifyGroupModel *groupModel = self.leftDataArray[index];
    if (self.lastGroupModel == groupModel) {
        return;
    }
    groupModel.selected = YES;
    self.lastGroupModel.selected = NO;
    self.lastGroupModel = groupModel;
    [self.leftTableView reloadData];
    
    if (need) {
//        UICollectionReusableView *cell = [self.rightCollectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:1 inSection:index]];
//        CGFloat top = - self.rightCollectionView.contentInset.top;
//        if (cell) {
//            top = CGRectGetMinY(cell.frame) - self.rightCollectionView.contentInset.top + 10;
//        }
//        [self.rightCollectionView setContentOffset:CGPointMake(-self.rightCollectionView.contentInset.left, top) animated:YES];
        [self.rightCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:index] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}

- (void)clickItemAtIndexPath:(NSIndexPath *)indexPath
{
    LNClassifyModel *model = self.rightDataArray[indexPath.section][indexPath.row];
    LNClassifyGroupModel *group = self.leftDataArray[indexPath.section];
    LNClassifyListViewController *listVc = [[LNClassifyListViewController alloc] init];
    listVc.itemName = model.name;
    listVc.groupKey = group.key;
    [self.classifyVc.navigationController pushViewController:listVc animated:YES];
}

- (void)reloadData
{
    [self.leftTableView reloadData];
    [self.rightCollectionView reloadData];
}

- (void)startSearch
{
    LNSearchViewController *searchVc = [[LNSearchViewController alloc] init];
    [self.classifyVc.navigationController pushViewController:searchVc animated:YES];
}
@end
