//
//  LNBookDetailViewModel.m
//  LookNovel
//
//  Created by wangchengshan on 2019/5/20.
//  Copyright © 2019 wcs Co.,ltd. All rights reserved.
//

#import "LNBookDetailViewModel.h"
#import "LNAPI.h"
#import "NSDate+LNAdd.h"
#import "LNChapterListViewController.h"

@implementation LNBookDetailViewModel

- (void)loadDetailData
{
//    [MBProgressHUD showWaitingViewText:nil detailText:nil inView:self.detailVc.view];
//    [LNAPI getBookDetailWithId:self.detailVc.bookId complete:^(id result, BOOL cache, NSError *error) {
//        [MBProgressHUD dismissHUDInView:self.detailVc.view];
//        if (error) {
//            [MBProgressHUD showMessageHUD:error.domain];
//        }
//        else{
//            LNBookDetail *detail = [LNBookDetail modelWithDictionary:result];
//            self.detail = detail;
//            [self handleData];
//            [self setupData];
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
          [mgr GET:[NSString stringWithFormat:@"%@%@", @"http://api.smaoxs.com/book/",self.detailVc.bookId] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
              NSJSONSerialization *object = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
              NSDictionary *dict = (NSDictionary *)object;
              NSInteger bid=[dict[@"bid"] integerValue];
              NSString* b=[NSString stringWithFormat:@"%d",bid];
              NSLog(@"");
              LNBookDetail *detail = [LNBookDetail modelWithDictionary:dict];
                          self.detail = detail;
                          [self handleData];
                          [self setupData];
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"");

          }];
}

- (void)setupData
{
    self.infoView.detail = self.detail;
    self.introView.detail = self.detail;
    self.scrollView.hidden = NO;
    self.bottomView.hidden = NO;
}

- (void)handleData
{
    NSDate *date = [NSDate dateWithString:self.detail.updated format:@"yyyy-MM-dd'T'HH:mm:ss.SSSX"];
    NSInteger hours = [NSDate numberOfHoursWithFromDate:date toDate:[NSDate date]];
    if (hours > 24) {
        hours = hours / 24;
        self.detail.updated = [NSString stringWithFormat:@"%ld天前更新",hours];
    }
    else
        self.detail.updated = [NSString stringWithFormat:@"%ld小时前更新",hours];
    
    NSAttributedString *attribute = [[NSAttributedString alloc] initWithString:self.detail.longIntro attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:UIColorHex(@"666666")}];
    self.detail.longIntroAttribute = attribute;
}

- (void)startReadBook
{
    [self startToReadBookDetail:self.detail];
}

- (UIViewController *)mainVc
{
    return self.detailVc;
}

#pragma mark - LNBookDetailIntroViewDelegate
- (void)introViewDidClickChapterList:(LNBookDetailIntroView *)view
{
//    LNChapterListViewController *listVc = [[LNChapterListViewController alloc] init];
//    [self.detailVc.navigationController pushViewController:listVc animated:YES];
}
@end
