//
//  LNSearchResultViewModel.m
//  LookNovel
//
//  Created by wangchengshan on 2019/5/21.
//  Copyright © 2019 wcs Co.,ltd. All rights reserved.
//

#import "LNSearchResultViewModel.h"
#import "LNAPI.h"
#import "LNBookDetailViewController.h"

@implementation LNSearchResultViewModel

- (void)startSearchWithText:(NSString *)text complete:(httpCompleteBlock)completeBlock
{
//    [LNAPI getSearchBooksWithKeyword:text complete:^(id result, BOOL cache, NSError *error) {
//        if (error) {
//            [MBProgressHUD showMessageHUD:error.domain];
//            completeBlock(result,cache,error);
//        }
//        else{
//            NSArray *modelArray = [NSArray modelArrayWithClass:[LNClassifyBookModel class] json:result];
//            completeBlock(modelArray,cache, error);
//        }
//    }];
    
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
    NSString* urlclssify=[NSString stringWithFormat:@"http://api.smaoxs.com/book/fuzzy-search?query=%@",text];
    NSString *encodedValue = [urlclssify stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

              [mgr GET:[NSString stringWithFormat:@"%@", encodedValue] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

                  NSJSONSerialization *object = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                  NSDictionary *dict = (NSDictionary *)object;
    //              NSArray* countArr=dict[@"books"];

                  NSLog(@"");
                  NSArray *maleArr = [dict objectForKey:@"books"];
                  
                  NSArray *modelArray = [NSArray modelArrayWithClass:[LNClassifyBookModel class] json:maleArr];
                    completeBlock(modelArray,YES, nil);


              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  NSLog(@"");

              }];
}

- (void)enterBookDetailAtIndex:(NSInteger)index
{
    LNClassifyBookModel *model = [self.resultVc.dataArray objectAtIndex:index];
    LNBookDetailViewController *detailVc = [[LNBookDetailViewController alloc] init];
    detailVc.bookId = model._id;
    [self.resultVc.navigationController pushViewController:detailVc animated:YES];
}

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    NSIndexPath *indexPath = [self.resultVc.tableView indexPathForRowAtPoint:location];
    LNClassifyBookModel *model = [self.resultVc.dataArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [self.resultVc.tableView cellForRowAtIndexPath:indexPath];
    LNBookDetailViewController *detailVc = [[LNBookDetailViewController alloc] init];
    detailVc.bookId = model._id;
    CGRect rect = cell.frame;
    previewingContext.sourceRect = rect;
    return detailVc;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self.resultVc.navigationController pushViewController:viewControllerToCommit animated:YES];
}
@end
