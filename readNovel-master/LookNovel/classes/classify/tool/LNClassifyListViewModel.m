//
//  LNClassifyListViewModel.m
//  LookNovel
//
//  Created by wangchengshan on 2019/5/16.
//  Copyright © 2019 wcs Co.,ltd. All rights reserved.
//

#import "LNClassifyListViewModel.h"
#import "LNAPI.h"
#import "LNBookDetailViewController.h"
#import "LNReaderViewController.h"

@implementation LNClassifyListViewModel

- (NSInteger)pageSize
{
    return 20;
}

- (void)getBooksWithGroupName:(NSString *)group itemName:(NSString *)item page:(NSInteger)page complete:(nonnull httpCompleteBlock)completeBlock
{
//    [LNAPI getClassifyBooksWithGroupKey:group major:item pageIndex:page pageSize:self.pageSize complete:^(NSArray *result, BOOL cache, NSError *error) {
//        if (!error) {
//            NSArray *modelArray = [NSArray modelArrayWithClass:[LNClassifyBookModel class] json:result];
//            completeBlock(modelArray, cache, error);
//        }
//        else
//            completeBlock(result, cache, error);
//    }];
//
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
    NSString* urlc=[NSString stringWithFormat:@"http://api.smaoxs.com/book/by-categories?gender=male&major=%@&start=0&limit=50",item];
//        NSString* urlclssify=@"http://api.smaoxs.com/book/by-categories?gender=male&major=玄幻&start=0&limit=50";
        NSString *encodedValue = [urlc stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

              [mgr GET:[NSString stringWithFormat:@"%@", encodedValue] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                  
                  NSJSONSerialization *object = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                  NSDictionary *dict = (NSDictionary *)object;
    //              NSArray* countArr=dict[@"books"];

                  NSLog(@"");
                  NSArray *maleArr = [dict objectForKey:@"books"];
                  if (maleArr.count) {

                  

                      NSArray *modelArray = [NSArray modelArrayWithClass:[LNClassifyBookModel class] json:maleArr];
                      completeBlock(modelArray, YES, nil);
//                      completeBlock(result, cache, error);
                  }
                  
              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  NSLog(@"");

              }];
}

- (UIViewController *)mainVc
{
    return self.listVc;
}

- (void)enterBookDetailAtIndex:(NSInteger)index
{
    LNClassifyBookModel *model = [self.listVc.dataArray objectAtIndex:index];
    LNBookDetailViewController *detailVc = [[LNBookDetailViewController alloc] init];
    detailVc.bookId = model._id;
    [self.listVc.navigationController pushViewController:detailVc animated:YES];
//    [self startToReadBook:model];
}

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    NSIndexPath *indexPath = [self.listVc.tableView indexPathForRowAtPoint:location];
    LNClassifyBookModel *model = [self.listVc.dataArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [self.listVc.tableView cellForRowAtIndexPath:indexPath];
    LNBookDetailViewController *detailVc = [[LNBookDetailViewController alloc] init];
    detailVc.bookId = model._id;
    CGRect rect = cell.frame;
    previewingContext.sourceRect = rect;
    return detailVc;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self.listVc.navigationController pushViewController:viewControllerToCommit animated:YES];
}
@end
