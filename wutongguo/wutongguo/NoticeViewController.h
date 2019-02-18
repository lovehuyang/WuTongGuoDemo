//
//  NoticeViewController.h
//  wutongguo
//
//  Created by Lucifer on 15/6/2.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoticeViewController : UIViewController

@property (nonatomic, strong) NSString *noticeId;
@property (nonatomic, strong) NSString *replyStauts;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *lbTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imgType;
@property (strong, nonatomic) IBOutlet UILabel *lbDate;
@property (strong, nonatomic) IBOutlet UILabel *lbSeparate;
@property (strong, nonatomic) IBOutlet UIView *viewReply;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintImgTypeWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintSeparateHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintScrollToBottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintScrollBottom;
@end
