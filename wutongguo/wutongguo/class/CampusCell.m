//
//  CampusCell.m
//  wutongguo
//
//  Created by Lucifer on 15-5-14.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "CampusCell.h"
#import "CommonMacro.h"
#import "CustomLabel.h"
#import "CommonFunc.h"
#import "VideoViewController.h"

@implementation CampusCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillCell:(NSDictionary *)data searchType:(NSInteger)searchType fromSchool:(BOOL)fromSchool viewController:(UIViewController *)viewController {
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    self.cellData = data;
    self.superViewController = viewController;
    self.attentionId = [data objectForKey:@"ID"];
    if (self.attentionId == nil) {
        self.attentionId = [data objectForKey:@"id"];
    }
    self.attentionId = [self.attentionId stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if (searchType == 1) {
        self.attentionType = @"4";
    }
    else {
        self.attentionType = @"5";
        if ([[data objectForKey:@"IsSchool"] isEqualToString:@"1"]) {
            self.attentionType = @"6";
        }
    }
    NSDate *endDate = [CommonFunc dateFromString:[data objectForKey:@"EndDate"]];
    NSDate *now = [NSDate date];
    NSDate *today = [now dateByAddingTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMTForDate:now]];
    endDate = [endDate dateByAddingTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMTForDate:endDate]];
    UIColor *dateColor;
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *tomorrow;
    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * tomorrowString = [[tomorrow description] substringToIndex:10];
    NSString * dateString = [[endDate description] substringToIndex:10];
    //过期的不显示关注按钮
    if ([endDate compare:today] == NSOrderedAscending) {
        CustomLabel *lbFavorite = [[CustomLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 50, 35, 40, 20) content:@"已举办" size:12 color:TEXTGRAYCOLOR];
        [lbFavorite setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:lbFavorite];
        if ([[data objectForKey:@"Url"] length] > 0) {
            CGRect framelbFavorite = lbFavorite.frame;
            framelbFavorite.origin.y = 25;
            [lbFavorite setFrame:framelbFavorite];
            UIButton *btnVideo = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_X(lbFavorite) - 15, VIEW_BY(lbFavorite) + 3, 60, 30)];
            [btnVideo setTag:[[data objectForKey:@"ID"] intValue]];
            [btnVideo addTarget:self action:@selector(videoClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:btnVideo];
            UIImageView *imgVideo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 16, 10)];
            [imgVideo setImage:[UIImage imageNamed:@"coCampusVideo.png"]];
            [btnVideo addSubview:imgVideo];
            CustomLabel *lbVideo = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgVideo) + 2, 0, 200, 20) content:@"现场视频" size:10 color:UIColorWithRGBA(1, 104, 183, 1)];
            [btnVideo addSubview:lbVideo];
        }
    }
    else if ([dateString isEqualToString:todayString] && [endDate compare:today] == NSOrderedDescending) {
        CustomLabel *lbFavorite = [[CustomLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 50, 35, 40, 20) content:@"进行中" size:12 color:NAVBARCOLOR];
        [lbFavorite setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:lbFavorite];
    }
    else {
        //关注按钮
        NSInteger IsAttention = [[data objectForKey:@"IsAttention"] integerValue];
        UIButton *btnFavorite = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40, 22, 30, 45)];
        [btnFavorite setTag:IsAttention];
        [btnFavorite addTarget:self action:@selector(favoriteClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btnFavorite];
        UIImageView *imgFavorite = [[UIImageView alloc] initWithFrame:CGRectMake(0, 3, 25, 25)];
        [imgFavorite setImage:[UIImage imageNamed:(IsAttention == 1 ? @"coFavorite.png" : @"coUnFavorite.png")]];
        [btnFavorite addSubview:imgFavorite];
        CustomLabel *lbFavorite = [[CustomLabel alloc] initWithFrame:CGRectMake(-8, 28, 41, 20) content:(IsAttention == 1 ? @"已关注" : @"关注") size:12 color:(IsAttention == 1 ? UIColorWithRGBA(255, 12, 92, 1) : NAVBARCOLOR)];
        [lbFavorite setTextAlignment:NSTextAlignmentCenter];
        [btnFavorite addSubview:lbFavorite];
    }
    NSString *content = [data objectForKey:(searchType == 1 ? @"CpMainName" : @"RecruitmentName")];
    float fontSize = 14;
    //宣讲会名称
    BOOL isSchool = [[data objectForKey:@"IsSchool"] isEqualToString:@"1"];
    CustomLabel *lbCampus = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10, 10, SCREEN_WIDTH - (isSchool ? 85 : 55), 20) content:content size:fontSize color:nil];
    [self.contentView addSubview:lbCampus];
    if (isSchool) {
        UIImageView *imgSchool = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbCampus), VIEW_Y(lbCampus) + 2, 30, 16)];
        [imgSchool setImage:[UIImage imageNamed:@"coCampus.png"]];
        [self.contentView addSubview:imgSchool];
    }
    //宣讲会时间 日期
    if ([dateString isEqualToString:todayString]) {
        content = @"今天";
        dateColor = UIColorWithRGBA(255, 0, 78, 1);
    }
    else if ([dateString isEqualToString:tomorrowString]) {
        content = @"明天";
        dateColor = UIColorWithRGBA(255, 0, 78, 1);
    }
    else {
        content = [CommonFunc stringFromDate:endDate formatType:@"M-d"];
        if (searchType == 1) {
            int endYear = [[CommonFunc stringFromDate:endDate formatType:@"yyyy"] intValue];
            int nowYear = [[CommonFunc stringFromDate:today formatType:@"yyyy"] intValue];
            if (endYear < nowYear) {
                content = [CommonFunc stringFromDate:endDate formatType:@"yyyy-M-d"];
            }
        }
        if ([endDate compare:today] == NSOrderedAscending) {
            dateColor = TEXTGRAYCOLOR;
        }
        else {
            dateColor = NAVBARCOLOR;
        }
    }
    fontSize = 14;
    CustomLabel *lbDate = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbCampus), VIEW_BY(lbCampus) + 5, 100, 20) content:content size:fontSize color:dateColor];
    [self.contentView addSubview:lbDate];
    //宣讲会时间 星期+时分
    content = [NSString stringWithFormat:@"（%@）%@-%@", [CommonFunc getWeek:[data objectForKey:@"EndDate"]], [CommonFunc stringFromDateString:[data objectForKey:@"BeginDate"] formatType:@"HH:mm"], [CommonFunc stringFromDateString:[data objectForKey:@"EndDate"] formatType:@"HH:mm"]];
    fontSize = 12;
    CustomLabel *lbTime = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(lbDate), VIEW_Y(lbDate), 200, 20) content:content size:fontSize color:TEXTGRAYCOLOR];
    [self.contentView addSubview:lbTime];
    if (fromSchool) {
        //宣讲会地点 详细地址
        content = [data objectForKey:(searchType == 1 ? @"AddRess" : @"PlaceName")];
        CustomLabel *lbAddress = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_X(lbDate), VIEW_BY(lbDate) + 5, SCREEN_WIDTH - VIEW_X(lbDate) - 50, 100) content:content size:fontSize color:TEXTGRAYCOLOR];
        [lbAddress setNumberOfLines:0];
        [self.contentView addSubview:lbAddress];
        [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(lbAddress) + 10)];
    }
    else {
        //宣讲会地点 地区学校
        content = [NSString stringWithFormat:@"[%@] %@", [data objectForKey:(searchType == 1 ? @"RegionName" : @"City")], [data objectForKey:(searchType == 1 ? @"SchoolName" : @"PlaceName")]];
        CustomLabel *lbSchool = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbDate), VIEW_BY(lbDate) + 5, 200, 20) content:content size:fontSize color:nil];
        [self.contentView addSubview:lbSchool];
        //宣讲会地点 地标图片
//        UIImageView *imgMap = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbSchool) + 1, VIEW_Y(lbSchool) + 3, 15, 15)];
//        [imgMap setImage:[UIImage imageNamed:@"coMap.png"]];
//        [self.contentView addSubview:imgMap];
        if (searchType == 1) {
            //宣讲会地点 详细地址
            content = [data objectForKey:@"AddRess"];
            if ([content isEqualToString:@"待定"]) {
                content = @"详细地点待定";
            }
            CustomLabel *lbAddress = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(lbSchool) + 1, VIEW_Y(lbSchool), SCREEN_WIDTH - VIEW_BX(lbSchool) - 50, 20) content:content size:fontSize color:TEXTGRAYCOLOR];
            [self.contentView addSubview:lbAddress];
        }
        [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(lbSchool) + 10)];
    }
}

- (void)favoriteClick:(UIButton *)sender {
    if (![CommonFunc checkLogin]) {
        UIViewController *loginCtrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
        [self.superViewController.navigationController pushViewController:loginCtrl animated:true];
        return;
    }
    if (sender.tag == 0) {
        for (UIView *view in sender.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                [(UIImageView *)view setImage:[UIImage imageNamed:@"coFavorite.png"]];
            }
            else if ([view isKindOfClass:[UILabel class]]) {
                [(UILabel *)view setText:@"已关注"];
                [(UILabel *)view setTextColor:UIColorWithRGBA(255, 12, 92, 1)];
            }
        }
        [sender setTag:1];
        UIImageView *imgFavoriteAnimate = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coBigHeart.png"]];
        imgFavoriteAnimate.center = self.superview.window.center;
        [imgFavoriteAnimate setFrame:CGRectMake((SCREEN_WIDTH - 100) / 2, SCREEN_HEIGHT, 100, 80)];
        [self.superview.window addSubview:imgFavoriteAnimate];
        [UIView animateWithDuration:0.6 animations:^{
            imgFavoriteAnimate.center = self.superview.window.center;
            [imgFavoriteAnimate setFrame:CGRectMake(VIEW_X(imgFavoriteAnimate), VIEW_Y(imgFavoriteAnimate) - 30, VIEW_W(imgFavoriteAnimate), VIEW_H(imgFavoriteAnimate))];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                imgFavoriteAnimate.center = self.superview.window.center;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:1 animations:^{
                    [imgFavoriteAnimate setFrame:CGRectMake(VIEW_X(imgFavoriteAnimate), VIEW_Y(imgFavoriteAnimate), SCREEN_HEIGHT, (SCREEN_HEIGHT * 4) / 5)];
                    imgFavoriteAnimate.center = self.superview.window.center;
                    [imgFavoriteAnimate setAlpha:0];
                } completion:^(BOOL finished) {
                    [imgFavoriteAnimate removeFromSuperview];
                }];
            }];
        }];
        [self insertAttention];
    }
    else {
        for (UIView *view in sender.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                [(UIImageView *)view setImage:[UIImage imageNamed:@"coUnFavorite.png"]];
            }
            else if ([view isKindOfClass:[UILabel class]]) {
                [(UILabel *)view setText:@"关注"];
                [(UILabel *)view setTextColor:NAVBARCOLOR];
            }
        }
        [sender setTag:0];
        [self deleteAttention];
    }
}

- (void)insertAttention {
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"InsertPaAttention" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", self.attentionType, @"attentionType", self.attentionId, @"attentionID", [CommonFunc getCode], @"code", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
    [self.cellData setValue:@"1" forKey:@"IsAttention"];
    [USER_DEFAULT setValue:[NSString stringWithFormat:@"%d", [self.attentionType intValue] - 1] forKey:@"attentionType"];
}

- (void)deleteAttention {
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"DeletePaAttention" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", self.attentionType, @"attentionType", self.attentionId, @"attentionID", [CommonFunc getCode], @"code", nil] tag:2];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
    [self.cellData setValue:@"0" forKey:@"IsAttention"];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    
}

- (void)videoClick:(UIButton *)sender {
    VideoViewController *videoCtrl = [[VideoViewController alloc] init];
    videoCtrl.title = @"现场视频";
    videoCtrl.url = [NSString stringWithFormat:@"http://m.wutongguo.com/cpfront/video/%ld_1?fromApp=1", (long)sender.tag];
    [self.superViewController.navigationController pushViewController:videoCtrl animated:YES];
}

@end
