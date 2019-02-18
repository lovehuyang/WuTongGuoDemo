//
//  NoticeViewController.m
//  wutongguo
//
//  Created by Lucifer on 15/6/2.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "NoticeViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "CustomLabel.h"
#import "MJRefresh.h"
#import "CompanyViewController.h"
#import "Toast+UIView.h"
#import<CoreText/CoreText.h>

@interface NoticeViewController ()<NetWebServiceRequestDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSDictionary *msgNoticeData;
@end

@implementation NoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.lbSeparate setBackgroundColor:SEPARATECOLOR];
    [self.constraintSeparateHeight setConstant:0.5];
    //等待动画
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetCpMsgEmailSendLogByID" params:[NSDictionary dictionaryWithObjectsAndKeys:self.noticeId, @"id", [CommonFunc getPaMainId], @"paMainID", [CommonFunc getCode], @"code", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        NSDictionary *noticeData = [[CommonFunc getArrayFromXml:requestData tableName:@"Table"] objectAtIndex:0];
        self.replyStauts = [noticeData objectForKey:@"ReplyStatus"];
        if ([[noticeData objectForKey:@"ReplyStatus"] length] > 0) {
            [self setReply:self.replyStauts];
        }
        self.title = [noticeData objectForKey:@"CpName"];
        self.lbTitle.text = [[noticeData objectForKey:@"Title"] length] > 0 ? [noticeData objectForKey:@"Title"] : [noticeData objectForKey:@"Body"];
        NSString *moduleType;
        if ([[noticeData objectForKey:@"MouldType"] isEqualToString:@"1"]) {
            moduleType = @"正式通知";
        }
        else if ([[noticeData objectForKey:@"MouldType"] isEqualToString:@"2"]) {
            moduleType = @"结果通知";
            [self setReply:self.replyStauts];
        }
        else if ([[noticeData objectForKey:@"MouldType"] isEqualToString:@"3"]) {
            moduleType = @"其他通知";
            [self setReply:self.replyStauts];
        }
        self.lbDate.text = [NSString stringWithFormat:@"%@  %@", moduleType, [CommonFunc stringFromDateString:[noticeData objectForKey:@"AddDate"] formatType:@"MM-dd HH:mm"]];
        [self.lbDate setTextColor:TEXTGRAYCOLOR];
        NSMutableAttributedString *attrDate = [[NSMutableAttributedString alloc] initWithString:self.lbDate.text];
        [attrDate addAttribute:NSFontAttributeName value:FONT(10) range:NSMakeRange(self.lbDate.text.length - 11, 11)];
        [self.lbDate setAttributedText:attrDate];
        
        if ([[noticeData objectForKey:@"SendType"] isEqualToString:@"1"]) {
            [self.constraintImgTypeWidth setConstant:17];
            [self.imgType setImage:[UIImage imageNamed:@"coEmail.png"]];
        }
        else {
            [self.imgType setImage:[UIImage imageNamed:@"ucMobile.png"]];
        }
        CustomLabel *lbContent = [[CustomLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(self.lbSeparate), VIEW_BY(self.lbSeparate) + 10, VIEW_W(self.lbSeparate), 800) content:[noticeData objectForKey:@"Body"] size:14 color:nil];
        NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[[noticeData objectForKey:@"Body"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [lbContent setAttributedText:attrStr];
        [lbContent sizeToFit];
        [self.scrollView addSubview:lbContent];
        [self.constraintScrollToBottom setConstant:VIEW_BY(lbContent) + 10];
        self.msgNoticeData = noticeData;
    }
    else if (request.tag == 2) {
        [self.view.window makeToast:@"答复成功"];
        [self setReply:self.replyStauts];
    }
}

- (void)setReply:(NSString *)replyStatus {
    if (replyStatus.length > 0) {
        for (UIView *view in self.viewReply.subviews) {
            [view removeFromSuperview];
        }
        NSString *replyMsg = @"";
        if ([replyStatus isEqualToString:@"1"]) {
            replyMsg = @"已回复：我确认";
        }
        else if ([replyStatus isEqualToString:@"2"]) {
            replyMsg = @"已回复：我调整";
        }
        else if ([replyStatus isEqualToString:@"3"]) {
            replyMsg = @"已回复：我放弃";
        }
        CustomLabel *lbReply = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(0, 25, SCREEN_WIDTH, 20) content:replyMsg size:16 color:NAVBARCOLOR];
        [lbReply setCenter:CGPointMake(self.viewReply.center.x, lbReply.center.y)];
        [self.viewReply addSubview:lbReply];
    }
    else {
        [self.viewReply removeFromSuperview];
        [self.constraintScrollBottom setConstant:0];
    }
}

- (IBAction)confirmClick:(UIButton *)sender {
    [sender setTag:1];
    [self replyMessage:sender];
}

- (IBAction)adjustClick:(UIButton *)sender {
    [sender setTag:2];
    [self replyMessage:sender];
}

- (IBAction)cancelClick:(UIButton *)sender {
    [sender setTag:3];
    [self replyMessage:sender];
}

- (void)replyMessage:(UIButton *)sender {
    [self.loadingView startAnimating];
    self.replyStauts = [NSString stringWithFormat:@"%ld", (long)[sender tag]];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"UpdateApplyFormLogReplyStatus" params:[NSDictionary dictionaryWithObjectsAndKeys:[self.msgNoticeData objectForKey:@"ID"], @"CpMsgEmailSendLogID", [self.msgNoticeData objectForKey:@"ApplyFormLogID"], @"ApplyFormLogID", [self.msgNoticeData objectForKey:@"UniqueID"], @"RankID", [NSString stringWithFormat:@"%ld", (long)[sender tag]], @"ReplySatus", [CommonFunc getPaMainId], @"paMainID", [CommonFunc getCode], @"code", nil] tag:2];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

@end
